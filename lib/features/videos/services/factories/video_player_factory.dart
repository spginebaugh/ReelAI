import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

/// Factory class for creating and configuring VideoPlayerController instances.
///
/// This factory ensures consistent initialization and configuration of video players
/// across the application.
class VideoPlayerFactory {
  /// Creates a new VideoPlayerController with standard configuration.
  ///
  /// [videoFile] The video file to play.
  ///
  /// Returns a fully initialized VideoPlayerController.
  static Future<VideoPlayerController> create(File videoFile) async {
    final controller = VideoPlayerController.file(
      videoFile,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    await controller.initialize();
    return controller;
  }
}
