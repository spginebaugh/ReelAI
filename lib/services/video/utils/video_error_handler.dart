import 'dart:io';
import '../../../utils/error_handler.dart';
import 'video_file_utils.dart';

/// Handles video-specific error handling and validation
class VideoErrorHandler {
  /// Handles processing errors with appropriate error types
  static void handleProcessingError(
    Object error, {
    String? operation,
    bool throwProcessingException = true,
    Map<String, dynamic>? context,
  }) {
    try {
      throw error;
    } catch (e) {
      if (e is ProcessingException || e is AppError) {
        rethrow;
      }

      final errorMessage =
          'Video processing failed${operation != null ? ' during $operation' : ''}: ${e.toString()}';

      if (throwProcessingException) {
        throw ProcessingException(
          errorMessage,
          isCritical: true,
        );
      } else {
        throw AppError(
          title: 'Video Processing Error',
          message: errorMessage,
          category: ErrorCategory.video,
          severity: ErrorSeverity.error,
          context: context,
        );
      }
    }
  }

  /// Validates video operation parameters
  static Future<void> validateVideoOperation({
    required File? input,
    Map<String, dynamic>? params,
    Map<String, String Function(dynamic)>? validators,
  }) async {
    if (input != null) {
      await VideoFileUtils.validateVideoFile(input);
    }

    if (params != null && validators != null) {
      final errors = <String>[];

      for (final entry in validators.entries) {
        final value = params[entry.key];
        final error = entry.value(value);
        if (error.isNotEmpty) {
          errors.add(error);
        }
      }

      if (errors.isNotEmpty) {
        throw ProcessingException(
          'Invalid video operation parameters:\n${errors.join('\n')}',
          isCritical: true,
        );
      }
    }
  }

  /// Creates a standard video processing error
  static AppError createVideoError(
    String message, {
    String? title,
    Map<String, dynamic>? context,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    return AppError(
      title: title ?? 'Video Processing Error',
      message: message,
      category: ErrorCategory.video,
      severity: severity,
      context: context,
    );
  }
}
