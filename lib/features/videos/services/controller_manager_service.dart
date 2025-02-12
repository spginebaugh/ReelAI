import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:reel_ai/features/videos/services/factories/chewie_controller_factory.dart';
import 'package:reel_ai/features/videos/services/factories/video_player_factory.dart';
import 'package:reel_ai/features/videos/services/utils/controller_disposer.dart';
import 'package:reel_ai/common/utils/logger.dart';

/// Service responsible for video controller lifecycle management including:
/// - Controller creation and initialization
/// - Muting state management
/// - Controller disposal
///
/// This is the single source of truth for video controller lifecycle operations.
/// For media operations (URLs, languages, synchronization), use [VideoMediaService].
class VideoControllerManager {
  /// Ensures all controllers are properly muted
  /// This is the single source of truth for muting operations
  Future<void> ensureControllersMuted(VideoPlayerController controller) async {
    Logger.debug('🔇 Ensuring controllers are muted');
    if (controller.value.volume > 0) {
      await controller.setVolume(0.0);
      Logger.debug('Successfully muted controller');
    }
  }

  /// Creates and verifies new video controllers
  Future<(VideoPlayerController, ChewieController)> createAndVerifyControllers(
    File videoFile, {
    bool showControls = true,
    bool allowFullScreen = false,
  }) async {
    Logger.debug('🎥 Creating new video controllers');
    final videoPlayerController = await VideoPlayerFactory.create(videoFile);

    // Ensure the controller starts muted
    await ensureControllersMuted(videoPlayerController);

    final chewieController = ChewieControllerFactory.create(
      videoPlayerController,
      showControls: showControls,
      allowFullScreen: allowFullScreen,
    );

    return (videoPlayerController, chewieController);
  }

  /// Safely disposes of video controllers
  Future<void> disposeControllers({
    VideoPlayerController? videoPlayerController,
    ChewieController? chewieController,
  }) async {
    Logger.debug('🧹 Disposing video controllers');
    await ControllerDisposer.disposeControllers(
      videoController: videoPlayerController,
      chewieController: chewieController,
    );
  }

  /// Verifies muting after state updates
  Future<void> verifyMuting(VideoPlayerController? controller) async {
    if (controller != null) {
      await ensureControllersMuted(controller);
    }
  }
}
