import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reel_ai/common/utils/error_handler.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/features/videos/services/utils/video_file_utils.dart';

/// Service for handling network operations related to videos
class NetworkService extends BaseService {
  /// Downloads a video from a URL and saves it to a temporary file
  Future<File> downloadVideo(String videoUrl) async {
    return executeOperation(
      operation: () async {
        if (videoUrl.isEmpty) {
          throw ProcessingException(
            'Video URL is required',
            isCritical: true,
          );
        }

        final tempFile = await VideoFileUtils.createTempVideoFile();

        try {
          final videoBytes =
              await NetworkAssetBundle(Uri.parse(videoUrl)).load(videoUrl);

          await tempFile.writeAsBytes(
            videoBytes.buffer.asUint8List(
              videoBytes.offsetInBytes,
              videoBytes.lengthInBytes,
            ),
          );

          await VideoFileUtils.validateVideoFile(tempFile);
          return tempFile;
        } catch (e) {
          await VideoFileUtils.safeDelete(tempFile.path);
          rethrow;
        }
      },
      operationName: 'downloadVideo',
      context: {'videoUrl': videoUrl},
      errorCategory: ErrorCategory.network,
    );
  }
}
