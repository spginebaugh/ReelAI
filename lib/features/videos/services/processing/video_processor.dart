import 'dart:io';
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

  /// Extract audio from a video file
  Future<String> extractAudio(File video) async {
    return executeOperation<String>(
      operation: () async {
        await VideoErrorHandler.validateVideoOperation(input: video);
        final outputPath = await VideoFileUtils.createTempVideoFile(
          prefix: 'audio',
          extension: 'wav',
        );

        await _ffmpeg.executeFFmpegCommand(
          command:
              '-i "${video.path}" -vn -acodec pcm_s16le -ar 44100 -ac 2 -f wav "${outputPath.path}"',
          operationName: 'extractAudio',
          outputPath: outputPath.path,
        );

        return outputPath.path;
      },
      operationName: 'extractAudio',
      errorCategory: ErrorCategory.processing,
    );
  }

  /// Clean up temporary files
  Future<void> cleanup(List<String?> filePaths) async {
    await executeOperation(
      operation: () async {
        await _ffmpeg.cleanup(filePaths);
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
