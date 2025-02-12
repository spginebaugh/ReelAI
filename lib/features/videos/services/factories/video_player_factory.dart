import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

/// Factory class for creating and configuring VideoPlayerController instances.
///
/// This factory ensures consistent initialization and configuration of video players
/// across the application, particularly focusing on audio handling for our custom
/// implementation where we want the video player to be always muted.
class VideoPlayerFactory {
  /// Creates a new VideoPlayerController with standard configuration.
  ///
  /// [videoFile] The video file to play.
  ///
  /// Returns a fully initialized and muted VideoPlayerController.
  /// Throws an exception if muting fails.
  static Future<VideoPlayerController> create(File videoFile) async {
    final controller = VideoPlayerController.file(
      videoFile,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    await controller.initialize();
    await _ensureMuted(controller);
    return controller;
  }

  /// Ensures the video player is muted by attempting to set volume to 0.
  ///
  /// Makes multiple attempts to ensure muting worked, throws if unsuccessful.
  static Future<void> _ensureMuted(VideoPlayerController controller) async {
    await controller.setVolume(0);
    if (controller.value.volume > 0) {
      debugPrint('⚠️ VideoPlayer: First mute attempt failed, retrying...');
      await controller.setVolume(0);
      if (controller.value.volume > 0) {
        throw Exception('Failed to mute video player after multiple attempts');
      }
    }
  }
}
