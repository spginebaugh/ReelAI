import 'dart:io';
import 'package:reel_ai/common/utils/logger.dart';
import 'package:reel_ai/common/utils/error_handler.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/features/videos/services/utils/video_error_handler.dart';
import 'package:reel_ai/features/videos/services/utils/video_file_utils.dart';
import 'package:reel_ai/features/videos/services/utils/ffmpeg_executor.dart';

/// Processor for FFmpeg operations
class FFmpegProcessor extends BaseService {
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

  /// Creates a muxed stream combining video (without audio) and a separate audio file
  Future<String> createMuxedStream({
    required String videoPath,
    required String audioPath,
    required String outputPath,
  }) async {
    return executeOperation<String>(
      operation: () async {
        // Command to mux video and audio while ensuring video audio is removed
        // -c:v copy -> Copy video stream without re-encoding
        // -map 0:v -> Take video from first input
        // -map 1:a -> Take audio from second input
        // -shortest -> End when shortest input ends
        // -avoid_negative_ts make_zero -> Ensure proper timestamp handling
        // -max_interleave_delta 0 -> Minimize audio/video sync issues
        // -af aresample=async=1 -> Handle audio sync issues
        // -movflags +faststart -> Enable streaming optimization
        final command = '-i "$videoPath" -i "$audioPath" '
            '-c:v copy -c:a aac -b:a 192k ' // Convert MP3 to AAC with good quality
            '-af aresample=async=1 ' // Handle potential audio sync issues
            '-map 0:v -map 1:a '
            '-shortest -avoid_negative_ts make_zero '
            '-max_interleave_delta 0 '
            '-movflags +faststart ' // Optimize for streaming
            '"$outputPath"';

        await executeFFmpegCommand(
          command: command,
          operationName: 'createMuxedStream',
          outputPath: outputPath,
        );

        // Verify the output file was created successfully
        final outputFile = File(outputPath);
        await VideoFileUtils.verifyOutputFile(outputFile);

        return outputPath;
      },
      operationName: 'createMuxedStream',
      errorCategory: ErrorCategory.processing,
    );
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
