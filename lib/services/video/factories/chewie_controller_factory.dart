import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

/// Factory class for creating and configuring ChewieController instances.
///
/// This factory ensures consistent configuration of Chewie video players
/// across the application, maintaining standardized controls and behavior.
class ChewieControllerFactory {
  /// Creates a ChewieController with configurable options while maintaining core settings.
  ///
  /// Core settings that remain constant:
  /// - allowMuting: false (we handle audio separately)
  /// - showOptions: false (we don't want additional options menu)
  /// - showControlsOnInitialize: false
  /// - isLive: false
  ///
  /// Configurable options:
  /// - [autoPlay] Whether the video should start playing automatically
  /// - [showControls] Whether to show the player controls
  /// - [allowFullScreen] Whether to allow fullscreen mode
  ///
  /// Returns a configured ChewieController instance.
  static ChewieController create(
    VideoPlayerController videoPlayerController, {
    bool autoPlay = false,
    bool showControls = true,
    bool allowFullScreen = false,
  }) {
    return ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: autoPlay,
      allowMuting: false, // Always false - we handle audio separately
      showControls: showControls,
      showOptions: false, // Always false - we don't want additional options
      showControlsOnInitialize: false,
      isLive: false,
      allowFullScreen: allowFullScreen,
    );
  }
}
