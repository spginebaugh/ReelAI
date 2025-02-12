import 'dart:io';
import 'package:reel_ai/common/utils/logger.dart';
import 'package:reel_ai/features/videos/services/utils/video_error_handler.dart';
import 'package:reel_ai/features/videos/services/utils/video_file_utils.dart';
import 'package:reel_ai/features/videos/services/utils/ffmpeg_executor.dart';

/// Handles low-level FFmpeg operations for video processing
class FFmpegProcessor {
  /// Executes an FFmpeg command with error handling and logging
  Future<String> executeFFmpegCommand({
    required String command,
    required String operationName,
    required String outputPath,
  }) async {
    try {
      Logger.video('Executing FFmpeg command', {
        'command': command,
        'operation': operationName,
        'outputPath': outputPath,
      });

      await FFmpegExecutor.executeCommand(
        command,
        operationName: operationName,
        throwProcessingException: true,
      );

      return outputPath;
    } catch (e, st) {
      Logger.error('FFmpeg command failed', {
        'error': e.toString(),
        'stackTrace': st.toString(),
        'command': command,
        'operation': operationName,
      });
      VideoErrorHandler.handleProcessingError(
        e,
        operation: operationName,
        context: {
          'command': command,
          'outputPath': outputPath,
        },
      );
      rethrow;
    }
  }

  /// Extracts audio from a video file
  Future<File> extractAudio(File videoFile) async {
    final outputPath = await VideoFileUtils.createTempVideoFile(
      prefix: 'audio',
      extension: 'wav',
    );

    await executeFFmpegCommand(
      command:
          '-i "${videoFile.path}" -vn -acodec pcm_s16le -ar 44100 -ac 2 -f wav "${outputPath.path}"',
      operationName: 'extractAudio',
      outputPath: outputPath.path,
    );

    return outputPath;
  }

  /// Cleans up temporary files
  Future<void> cleanup(List<String?> paths) async {
    for (final path in paths) {
      if (path != null) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          Logger.warning('Failed to delete file', {'path': path, 'error': e});
        }
      }
    }
  }
}
