import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:reel_ai/common/utils/logger.dart';

/// Utility class for safely disposing video controllers
class ControllerDisposer {
  /// Safely disposes both video and chewie controllers
  static Future<void> disposeControllers({
    VideoPlayerController? videoController,
    ChewieController? chewieController,
  }) async {
    try {
      // First dispose chewie controller if it exists
      if (chewieController != null) {
        await Future.microtask(() {
          chewieController.dispose();
        });
      }

      // Then dispose video controller if it exists
      if (videoController != null) {
        await videoController.dispose();
      }
    } catch (e) {
      Logger.warning('Error disposing controllers', {'error': e.toString()});
    }
  }
}
