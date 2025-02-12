import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:reel_ai/common/utils/error_handler.dart';

/// A utility class to handle FFmpeg command execution and error handling
class FFmpegExecutor {
  /// Executes an FFmpeg command and handles common error cases
  /// Returns the session output if successful
  /// Throws ProcessingException if the command fails
  static Future<String?> executeCommand(
    String command, {
    bool throwProcessingException = true,
    String? operationName,
  }) async {
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final logs = await session.getLogs();
    final output = await session.getOutput();
    final failStackTrace = await session.getFailStackTrace();

    if (!ReturnCode.isSuccess(returnCode)) {
      final errorMessage = StringBuffer()
        ..writeln(
            'FFmpeg operation failed${operationName != null ? ' ($operationName)' : ''}:')
        ..writeln('Return code: ${returnCode?.getValue() ?? "unknown"}')
        ..writeln('Logs:')
        ..writeln(logs?.take(1000).join('\n') ?? 'No logs available')
        ..writeln('Stack trace:')
        ..writeln(failStackTrace ?? 'No stack trace available');

      if (throwProcessingException) {
        throw ProcessingException(
          errorMessage.toString(),
          isCritical: true,
        );
      } else {
        throw AppError(
          title: 'Video Processing Error',
          message:
              'FFmpeg operation failed${operationName != null ? ': $operationName' : ''}',
          category: ErrorCategory.video,
          severity: ErrorSeverity.error,
          context: {
            'logs': logs?.take(1000).join('\n') ?? 'No logs available',
            'stackTrace': failStackTrace,
            'command': command,
          },
        );
      }
    }

    return output;
  }
}
