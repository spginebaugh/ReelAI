import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import '../models/filter_option.dart';
import 'ffmpeg_service.dart';
import 'video/factories/chewie_controller_factory.dart';
import 'video/factories/video_player_factory.dart';
import 'base_service.dart';
import '../utils/error_handler.dart';

class VideoProcessingService extends BaseService {
  final FFmpegService _ffmpegService;
  final VideoPlayerController? previewController;

  VideoProcessingService({
    FFmpegService? ffmpegService,
    this.previewController,
  }) : _ffmpegService = ffmpegService ?? FFmpegService();

  /// Downloads a video from a URL and saves it to a temporary file
  Future<File> downloadVideo(String videoUrl) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {'videoUrl': videoUrl},
          validators: {
            'videoUrl': (value) => value?.toString().isEmpty == true
                ? 'Video URL is required'
                : '',
          },
        );

        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
            '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.mp4');

        final videoBytes =
            await NetworkAssetBundle(Uri.parse(videoUrl)).load(videoUrl);
        await tempFile.writeAsBytes(videoBytes.buffer
            .asUint8List(videoBytes.offsetInBytes, videoBytes.lengthInBytes));

        return tempFile;
      },
      operationName: 'downloadVideo',
      context: {'videoUrl': videoUrl},
      errorCategory: ErrorCategory.network,
    );
  }

  /// Initializes video player controller
  Future<ChewieController> initializePlayer(File videoFile) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {'videoFile': videoFile},
          validators: {
            'videoFile': (value) =>
                value == null || !File(value.path).existsSync()
                    ? 'Valid video file is required'
                    : '',
          },
        );

        // Use VideoPlayerFactory to create and initialize the controller
        final videoController = await VideoPlayerFactory.create(videoFile);

        // Use ChewieControllerFactory to create the chewie controller
        return ChewieControllerFactory.create(
          videoController,
          autoPlay: false,
          showControls: true,
          allowFullScreen: false,
        );
      },
      operationName: 'initializePlayer',
      context: {'filePath': videoFile.path},
      errorCategory: ErrorCategory.video,
    );
  }

  /// Gets video duration in milliseconds
  Future<double> getVideoDuration(File videoFile) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {'videoFile': videoFile},
          validators: {
            'videoFile': (value) =>
                value == null || !File(value.path).existsSync()
                    ? 'Valid video file is required'
                    : '',
          },
        );

        VideoPlayerController? controller;
        try {
          controller = await VideoPlayerFactory.create(videoFile);
          return controller.value.duration.inMilliseconds.toDouble();
        } finally {
          await controller?.dispose();
        }
      },
      operationName: 'getVideoDuration',
      context: {'filePath': videoFile.path},
      errorCategory: ErrorCategory.video,
    );
  }

  /// Applies filters to video
  Future<String> applyFilters({
    required File inputFile,
    required FilterOption filter,
    required double brightness,
    required String outputPath,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'inputFile': inputFile,
            'filter': filter,
            'brightness': brightness,
            'outputPath': outputPath,
          },
          validators: {
            'inputFile': (value) =>
                value == null || !File(value.path).existsSync()
                    ? 'Valid input file is required'
                    : '',
            'filter': (value) =>
                value == null ? 'Filter option is required' : '',
            'outputPath': (value) => value?.toString().isEmpty == true
                ? 'Output path is required'
                : '',
          },
        );

        return _ffmpegService.applyFilters(
          inputFile: inputFile,
          filter: filter,
          brightness: brightness,
          outputPath: outputPath,
        );
      },
      operationName: 'applyFilters',
      context: {
        'inputPath': inputFile.path,
        'outputPath': outputPath,
        'filter': filter.toString(),
        'brightness': brightness,
      },
      errorCategory: ErrorCategory.video,
    );
  }

  /// Trims video and returns the output path
  Future<String?> trimVideo({
    required File inputFile,
    required double startValue,
    required double endValue,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'inputFile': inputFile,
            'startValue': startValue,
            'endValue': endValue,
          },
          validators: {
            'inputFile': (value) =>
                value == null || !File(value.path).existsSync()
                    ? 'Valid input file is required'
                    : '',
            'startValue': (value) =>
                value == null || value < 0 ? 'Invalid start time' : '',
            'endValue': (value) =>
                value == null || value <= startValue ? 'Invalid end time' : '',
          },
        );

        final tempDir = await getTemporaryDirectory();
        final outputPath =
            '${tempDir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4';

        // Convert milliseconds to seconds for FFmpeg
        final startSeconds = startValue / 1000;
        final endSeconds = endValue / 1000;
        final duration = endSeconds - startSeconds;

        dev.log('Starting video trim:');
        dev.log('Input file exists: ${await inputFile.exists()}');
        dev.log('Input file path: ${inputFile.path}');
        dev.log('Start time: $startSeconds seconds');
        dev.log('Duration: $duration seconds');
        dev.log('Output path: $outputPath');

        try {
          // Simplest possible command for trimming
          final command =
              '-i "${inputFile.path}" -ss $startSeconds -t $duration -c:v copy -c:a copy "$outputPath"';
          dev.log('Executing FFmpeg command: $command');

          final session = await FFmpegKit.execute(command);
          final returnCode = await session.getReturnCode();
          final logs = await session.getOutput() ?? 'No output';
          final failStackTrace = await session.getFailStackTrace();

          dev.log('FFmpeg return code: ${returnCode?.getValue() ?? "null"}');
          dev.log('FFmpeg logs: $logs');
          if (failStackTrace != null) {
            dev.log('FFmpeg failure stack trace: $failStackTrace');
          }

          if (!ReturnCode.isSuccess(returnCode)) {
            throw AppError(
              title: 'Video Processing Error',
              message: 'Failed to trim video',
              category: ErrorCategory.video,
              severity: ErrorSeverity.error,
              context: {'logs': logs, 'stackTrace': failStackTrace},
            );
          }

          // Verify the output file exists and has a non-zero size
          final outputFile = File(outputPath);
          if (!await outputFile.exists()) {
            throw AppError(
              title: 'Video Processing Error',
              message: 'Output file was not created',
              category: ErrorCategory.video,
              severity: ErrorSeverity.error,
            );
          }

          final fileSize = await outputFile.length();
          if (fileSize == 0) {
            throw AppError(
              title: 'Video Processing Error',
              message: 'Output file was created but is empty',
              category: ErrorCategory.video,
              severity: ErrorSeverity.error,
              context: {'outputPath': outputPath},
            );
          }

          dev.log(
              'Video trim completed successfully. Output file size: $fileSize bytes');
          return outputPath;
        } catch (e) {
          // Clean up failed output file if it exists
          await executeCleanup(
            cleanup: () async {
              final outputFile = File(outputPath);
              if (await outputFile.exists()) {
                await outputFile.delete();
              }
            },
            cleanupName: 'cleanupFailedTrimOutput',
            context: {'outputPath': outputPath},
          );
          rethrow;
        }
      },
      operationName: 'trimVideo',
      context: {
        'inputPath': inputFile.path,
        'startValue': startValue,
        'endValue': endValue,
      },
      errorCategory: ErrorCategory.video,
    );
  }

  /// Cleans up resources
  Future<void> cleanup(List<String?> filePaths) async {
    await executeOperation(
      operation: () async {
        for (final path in filePaths) {
          await _ffmpegService.cleanupFile(path);
        }
      },
      operationName: 'cleanup',
      context: {'filePaths': filePaths},
      errorCategory: ErrorCategory.video,
    );
  }

  /// Disposes of resources
  void dispose() {
    previewController?.dispose();
  }
}
