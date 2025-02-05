import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import '../models/filter_option.dart';
import 'ffmpeg_service.dart';

class VideoProcessingService {
  final FFmpegService _ffmpegService;
  final VideoPlayerController? previewController;

  VideoProcessingService({
    FFmpegService? ffmpegService,
    this.previewController,
  }) : _ffmpegService = ffmpegService ?? FFmpegService();

  /// Downloads a video from a URL and saves it to a temporary file
  Future<File> downloadVideo(String videoUrl) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
        '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.mp4');

    final videoBytes =
        await NetworkAssetBundle(Uri.parse(videoUrl)).load(videoUrl);
    await tempFile.writeAsBytes(videoBytes.buffer
        .asUint8List(videoBytes.offsetInBytes, videoBytes.lengthInBytes));

    return tempFile;
  }

  /// Initializes video player controller
  Future<ChewieController> initializePlayer(File videoFile) async {
    final videoController = VideoPlayerController.file(videoFile);
    await videoController.initialize();

    return ChewieController(
      videoPlayerController: videoController,
      autoPlay: false,
      looping: false,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      aspectRatio: videoController.value.aspectRatio,
      allowedScreenSleep: false,
    );
  }

  /// Gets video duration in milliseconds
  Future<double> getVideoDuration(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    final duration = controller.value.duration.inMilliseconds.toDouble();
    await controller.dispose();
    return duration;
  }

  /// Applies filters to video
  Future<String> applyFilters({
    required File inputFile,
    required FilterOption filter,
    required double brightness,
    required String outputPath,
  }) async {
    return _ffmpegService.applyFilters(
      inputFile: inputFile,
      filter: filter,
      brightness: brightness,
      outputPath: outputPath,
    );
  }

  /// Trims video and returns the output path
  Future<String?> trimVideo({
    required File inputFile,
    required double startValue,
    required double endValue,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Convert milliseconds to seconds for FFmpeg
    final startSeconds = startValue / 1000;
    final endSeconds = endValue / 1000;
    final duration = endSeconds - startSeconds;

    final command =
        '-i "${inputFile.path}" -ss $startSeconds -t $duration -c copy "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final output = await session.getOutput();
      throw Exception('Failed to trim video: ${output ?? 'Unknown error'}');
    }

    return outputPath;
  }

  /// Cleans up resources
  Future<void> cleanup(List<String?> filePaths) async {
    for (final path in filePaths) {
      await _ffmpegService.cleanupFile(path);
    }
  }

  /// Disposes of resources
  void dispose() {
    previewController?.dispose();
  }
}
