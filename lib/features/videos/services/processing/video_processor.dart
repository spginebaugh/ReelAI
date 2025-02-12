import 'dart:io';
import 'package:reel_ai/features/videos/models/filter_option.dart';
import 'package:reel_ai/common/utils/error_handler.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/features/videos/services/processing/ffmpeg_processor.dart';
import 'package:reel_ai/features/videos/services/utils/video_error_handler.dart';
import 'package:reel_ai/features/videos/services/utils/video_file_utils.dart';
import 'package:reel_ai/features/videos/services/utils/network_service.dart';
import 'package:reel_ai/features/videos/services/playback/player_service.dart';

/// High-level video processing service that coordinates video operations
class VideoProcessor extends BaseService {
  final FFmpegProcessor _ffmpeg;
  final NetworkService _network;
  final PlayerService _player;

  VideoProcessor({
    FFmpegProcessor? ffmpeg,
    NetworkService? network,
    PlayerService? player,
  })  : _ffmpeg = ffmpeg ?? FFmpegProcessor(),
        _network = network ?? NetworkService(),
        _player = player ?? PlayerService();

  /// Downloads a video from a URL
  Future<File> downloadVideo(String videoUrl) async {
    return _network.downloadVideo(videoUrl);
  }

  /// Gets video duration in milliseconds
  Future<double> getVideoDuration(File video) async {
    return _player.getVideoDuration(video);
  }

  /// Apply filters to a video file
  Future<String> applyFilters({
    required File inputFile,
    required FilterOption filter,
    required double brightness,
    String? outputPath,
  }) async {
    final output = outputPath ??
        (await VideoFileUtils.createTempVideoFile(prefix: 'filtered')).path;
    return _ffmpeg.applyFilters(
      inputFile: inputFile,
      filter: filter,
      brightness: brightness,
      outputPath: output,
    );
  }

  /// Trim a video file
  Future<String?> trimVideo({
    required File inputFile,
    required double startValue,
    required double endValue,
  }) async {
    final duration = endValue - startValue;
    if (duration <= 0) return null;

    return _ffmpeg.trimVideo(
      inputFile: inputFile,
      startSeconds: startValue,
      duration: duration,
    );
  }

  /// Process a video with optional filters, brightness adjustment, and trimming
  Future<String> processVideo({
    required File video,
    FilterOption? filter,
    double? brightness,
    double? startTime,
    double? duration,
  }) async {
    return executeOperation<String>(
      operation: () async {
        await VideoErrorHandler.validateVideoOperation(
          input: video,
          params: {
            'filter': filter,
            'brightness': brightness,
            'startTime': startTime,
            'duration': duration,
          },
        );

        File currentVideo = video;
        final filesToCleanup = <String>[];

        try {
          // Apply trimming if requested
          if (startTime != null && duration != null) {
            final trimmedPath = await _ffmpeg.trimVideo(
              inputFile: currentVideo,
              startSeconds: startTime,
              duration: duration,
            );

            if (currentVideo.path != video.path) {
              filesToCleanup.add(currentVideo.path);
            }
            currentVideo = File(trimmedPath);
          }

          // Apply filters if requested
          if (filter != null || brightness != null) {
            final filteredPath = await VideoFileUtils.createTempVideoFile(
              prefix: 'filtered',
            );

            await _ffmpeg.applyFilters(
              inputFile: currentVideo,
              filter: filter ?? FilterOption.none,
              brightness: brightness ?? 1.0,
              outputPath: filteredPath.path,
            );

            if (currentVideo.path != video.path) {
              filesToCleanup.add(currentVideo.path);
            }
            currentVideo = filteredPath;
          }

          return currentVideo.path;
        } catch (e) {
          // Clean up any temporary files on error
          for (final path in filesToCleanup) {
            await _ffmpeg.cleanupFile(path);
          }
          if (currentVideo.path != video.path) {
            await _ffmpeg.cleanupFile(currentVideo.path);
          }
          VideoErrorHandler.handleProcessingError(
            e,
            operation: 'processVideo',
            throwProcessingException: false,
          );
          rethrow;
        }
      },
      operationName: 'processVideo',
      errorCategory: ErrorCategory.video,
    );
  }

  /// Extract audio from a video file
  Future<String> extractAudio(File video) async {
    return executeOperation<String>(
      operation: () async {
        await VideoErrorHandler.validateVideoOperation(input: video);
        return _ffmpeg.extractAudio(video.path);
      },
      operationName: 'extractAudio',
      errorCategory: ErrorCategory.processing,
    );
  }

  /// Clean up temporary files
  Future<void> cleanup(List<String?> filePaths) async {
    await executeOperation(
      operation: () async {
        for (final path in filePaths.whereType<String>()) {
          await _ffmpeg.cleanupFile(path);
        }
      },
      operationName: 'cleanup',
      errorCategory: ErrorCategory.video,
    );
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
