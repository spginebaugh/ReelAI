import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../utils/error_handler.dart';

/// Utility class for common video file operations
class VideoFileUtils {
  /// Validates that a video file exists and is readable
  static Future<bool> validateVideoFile(File file) async {
    if (!await file.exists()) {
      throw ProcessingException(
        'Video file not found: ${file.path}',
        isCritical: true,
      );
    }

    try {
      final stat = await file.stat();
      if (stat.size == 0) {
        throw ProcessingException(
          'Video file is empty: ${file.path}',
          isCritical: true,
        );
      }
      return true;
    } catch (e) {
      throw ProcessingException(
        'Cannot read video file: ${file.path}',
        isCritical: true,
      );
    }
  }

  /// Creates a temporary video file with a unique name
  static Future<File> createTempVideoFile(
      {String prefix = 'temp', String extension = 'mp4'}) async {
    final tempDir = await getTemporaryDirectory();
    return File(
      '${tempDir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
  }

  /// Verifies that an output file exists and has content
  static Future<void> verifyOutputFile(
    File file, {
    bool throwProcessingException = true,
  }) async {
    if (!await file.exists()) {
      final error = 'Output file was not created: ${file.path}';
      if (throwProcessingException) {
        throw ProcessingException(error, isCritical: true);
      } else {
        throw AppError(
          title: 'Video Processing Error',
          message: error,
          category: ErrorCategory.video,
          severity: ErrorSeverity.error,
        );
      }
    }

    final fileSize = await file.length();
    if (fileSize == 0) {
      final error = 'Output file is empty: ${file.path}';
      if (throwProcessingException) {
        throw ProcessingException(error, isCritical: true);
      } else {
        throw AppError(
          title: 'Video Processing Error',
          message: error,
          category: ErrorCategory.video,
          severity: ErrorSeverity.error,
          context: {'outputPath': file.path},
        );
      }
    }
  }

  /// Safely deletes a file if it exists
  static Future<void> safeDelete(String? filePath) async {
    if (filePath == null) return;

    final file = File(filePath);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        // Ignore deletion errors
      }
    }
  }
}
