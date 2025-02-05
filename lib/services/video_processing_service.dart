import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_video_trimmer/flutter_video_trimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/filter_option.dart';
import 'ffmpeg_service.dart';

class VideoProcessingService {
  final FFmpegService _ffmpegService;
  final Trimmer trimmer;

  VideoProcessingService({
    FFmpegService? ffmpegService,
    Trimmer? trimmer,
  })  : _ffmpegService = ffmpegService ?? FFmpegService(),
        trimmer = trimmer ?? Trimmer();

  /// Downloads a video from a URL and saves it to a temporary file
  Future<File> downloadVideo(String videoUrl) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
        '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.mp4');

    final videoBytes =
        await NetworkAssetBundle(Uri.parse(videoUrl)).load(videoUrl);
    await tempFile.writeAsBytes(videoBytes.buffer.asUint8List());

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

  /// Loads video into trimmer
  Future<void> loadVideoIntoTrimmer(File videoFile) async {
    await trimmer.loadVideo(videoFile: videoFile);
  }

  /// Applies filters to video
  Future<String> applyFilters({
    required File inputFile,
    required FilterOption filter,
    required double brightness,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.mp4';

    return _ffmpegService.applyFilters(
      inputFile: inputFile,
      filter: filter,
      brightness: brightness,
      outputPath: outputPath,
    );
  }

  /// Trims video and returns the output path
  Future<String?> trimVideo({
    required double startValue,
    required double endValue,
  }) async {
    Completer<String?> completer = Completer<String?>();

    await trimmer.saveTrimmedVideo(
      startValue: startValue,
      endValue: endValue,
      onSave: (String? outputPath) {
        completer.complete(outputPath);
      },
    );

    return completer.future;
  }

  /// Cleans up resources
  Future<void> cleanup(List<String?> filePaths) async {
    for (final path in filePaths) {
      await _ffmpegService.cleanupFile(path);
    }
  }

  /// Disposes of the trimmer
  void dispose() {
    trimmer.dispose();
  }
}
