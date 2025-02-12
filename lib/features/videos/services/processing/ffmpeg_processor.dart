import 'dart:io';
import 'package:reel_ai/features/videos/models/filter_option.dart';
import 'package:reel_ai/common/utils/error_handler.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/features/videos/services/utils/ffmpeg_executor.dart';
import 'package:reel_ai/features/videos/services/utils/video_error_handler.dart';
import 'package:reel_ai/features/videos/services/utils/video_file_utils.dart';

/// Handles low-level FFmpeg operations for video processing
class FFmpegProcessor extends BaseService {
  /// Applies visual filters and brightness adjustments to a video file
  Future<String> applyFilters({
    required File inputFile,
    required FilterOption filter,
    required double brightness,
    required String outputPath,
  }) async {
    return executeOperation<String>(
      operation: () async {
        await VideoErrorHandler.validateVideoOperation(
          input: inputFile,
          params: {
            'filter': filter,
            'brightness': brightness,
            'outputPath': outputPath,
          },
          validators: {
            'outputPath': (value) => value?.toString().isEmpty == true
                ? 'Output path is required'
                : '',
          },
        );

        final List<String> filterComponents = [];

        // Add selected visual filter
        if (filter != FilterOption.none) {
          filterComponents.add(filter.ffmpegCommand);
        }

        // Add brightness adjustment
        if (brightness != 1.0) {
          final double brightnessValue = (brightness - 1.0).clamp(-1.0, 1.0);
          filterComponents.add(
              'colorlevels=rimin=${-brightnessValue}:rimax=${brightnessValue}:'
              'gimin=${-brightnessValue}:gimax=${brightnessValue}:'
              'bimin=${-brightnessValue}:bimax=${brightnessValue}');
        }

        String command = '-i "${inputFile.path}"';
        if (filterComponents.isNotEmpty) {
          command += ' -vf "${filterComponents.join(',')}"';
        }
        command += ' -c:a copy "$outputPath"';

        await FFmpegExecutor.executeCommand(
          command,
          operationName: 'applyFilters',
        );

        await VideoFileUtils.verifyOutputFile(File(outputPath));
        return outputPath;
      },
      operationName: 'applyFilters',
      errorCategory: ErrorCategory.processing,
    );
  }

  /// Trims a video file to the specified duration
  Future<String> trimVideo({
    required File inputFile,
    required double startSeconds,
    required double duration,
    String? outputPath,
  }) async {
    return executeOperation<String>(
      operation: () async {
        await VideoErrorHandler.validateVideoOperation(
          input: inputFile,
          params: {
            'startSeconds': startSeconds,
            'duration': duration,
          },
          validators: {
            'startSeconds': (value) =>
                value == null || value < 0 ? 'Invalid start time' : '',
            'duration': (value) =>
                value == null || value <= 0 ? 'Invalid duration' : '',
          },
        );

        final String outputFilePath;
        if (outputPath != null) {
          outputFilePath = outputPath;
        } else {
          final tempFile =
              await VideoFileUtils.createTempVideoFile(prefix: 'trimmed');
          outputFilePath = tempFile.path;
        }

        final command =
            '-i "${inputFile.path}" -ss $startSeconds -t $duration -c:v copy -c:a copy "$outputFilePath"';

        await FFmpegExecutor.executeCommand(
          command,
          throwProcessingException: false,
          operationName: 'trimVideo',
        );

        await VideoFileUtils.verifyOutputFile(
          File(outputFilePath),
          throwProcessingException: false,
        );

        return outputFilePath;
      },
      operationName: 'trimVideo',
      errorCategory: ErrorCategory.video,
    );
  }

  /// Extracts audio from a video file and saves it as WAV
  Future<String> extractAudio(String videoPath) async {
    return executeOperation<String>(
      operation: () async {
        final inputFile = File(videoPath);
        await VideoErrorHandler.validateVideoOperation(input: inputFile);

        final outputPath = await VideoFileUtils.createTempVideoFile(
          prefix: 'audio',
          extension: 'wav',
        );

        await FFmpegExecutor.executeCommand(
          '-i "$videoPath" -vn -acodec pcm_s16le -ar 44100 -ac 2 -f wav "${outputPath.path}"',
          operationName: 'extractAudio',
        );

        await VideoFileUtils.verifyOutputFile(outputPath);
        return outputPath.path;
      },
      operationName: 'extractAudio',
      context: {'videoPath': videoPath},
      errorCategory: ErrorCategory.processing,
    );
  }

  /// Cleans up a video file if it exists
  Future<void> cleanupFile(String? filePath) async {
    if (filePath == null) return;

    await executeCleanup(
      cleanup: () => VideoFileUtils.safeDelete(filePath),
      cleanupName: 'cleanupFile',
      context: {'path': filePath},
    );
  }
}
