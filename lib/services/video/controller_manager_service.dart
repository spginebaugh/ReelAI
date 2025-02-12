import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:reel_ai/services/video/factories/chewie_controller_factory.dart';
import 'package:reel_ai/services/video/factories/video_player_factory.dart';

class VideoControllerManager {
  /// Ensures all controllers are properly muted
  Future<void> ensureControllersMuted(VideoPlayerController controller) async {
    debugPrint('🔇 Ensuring controllers are muted');
    await controller.setVolume(0);
    if (controller.value.volume > 0) {
      debugPrint('⚠️ Volume not 0, forcing mute');
      await controller.setVolume(0);
      if (controller.value.volume > 0) {
        throw Exception('Failed to mute video player');
      }
    }
  }

  /// Creates and verifies new video controllers
  Future<(VideoPlayerController, ChewieController)> createAndVerifyControllers(
    File videoFile, {
    bool showControls = true,
    bool allowFullScreen = false,
  }) async {
    debugPrint('🎥 Creating new video controllers');
    final videoPlayerController = await VideoPlayerFactory.create(videoFile);
    await ensureControllersMuted(videoPlayerController);

    final chewieController = ChewieControllerFactory.create(
      videoPlayerController,
      showControls: showControls,
      allowFullScreen: allowFullScreen,
    );

    return (videoPlayerController, chewieController);
  }

  /// Safely disposes of video controllers
  void disposeControllers({
    VideoPlayerController? videoPlayerController,
    ChewieController? chewieController,
  }) {
    debugPrint('🧹 Disposing video controllers');
    chewieController?.dispose();
    videoPlayerController?.dispose();
  }

  /// Verifies muting after state updates
  Future<void> verifyMuting(VideoPlayerController? controller) async {
    if (controller != null && controller.value.volume > 0) {
      await ensureControllersMuted(controller);
    }
  }
}
