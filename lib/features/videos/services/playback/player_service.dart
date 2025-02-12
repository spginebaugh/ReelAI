import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:reel_ai/common/utils/error_handler.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/features/videos/services/utils/video_error_handler.dart';

/// Service for managing video playback
class PlayerService extends BaseService {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  /// Initialize player with a video file
  Future<ChewieController> initializePlayer(
    File video, {
    bool autoPlay = false,
    bool showControls = true,
    bool allowFullScreen = false,
  }) async {
    return executeOperation<ChewieController>(
      operation: () async {
        await VideoErrorHandler.validateVideoOperation(input: video);

        // Dispose existing controllers
        await _disposeControllers();

        try {
          _controller = VideoPlayerController.file(video);
          await _controller!.initialize();

          _chewieController = ChewieController(
            videoPlayerController: _controller!,
            autoPlay: autoPlay,
            showControls: showControls,
            allowFullScreen: allowFullScreen,
          );

          return _chewieController!;
        } catch (e) {
          await _disposeControllers();
          VideoErrorHandler.handleProcessingError(
            e,
            operation: 'initializePlayer',
            throwProcessingException: false,
          );
          rethrow;
        }
      },
      operationName: 'initializePlayer',
      errorCategory: ErrorCategory.video,
    );
  }

  /// Get video duration in milliseconds
  Future<double> getVideoDuration(File video) async {
    return executeOperation<double>(
      operation: () async {
        await VideoErrorHandler.validateVideoOperation(input: video);

        VideoPlayerController? tempController;
        try {
          tempController = VideoPlayerController.file(video);
          await tempController.initialize();
          return tempController.value.duration.inMilliseconds.toDouble();
        } finally {
          if (tempController != null) {
            try {
              tempController.dispose();
            } catch (e) {
              // Ignore disposal errors
            }
          }
        }
      },
      operationName: 'getVideoDuration',
      errorCategory: ErrorCategory.video,
    );
  }

  /// Dispose of controllers
  Future<void> dispose() async {
    await _disposeControllers();
  }

  /// Internal method to dispose of controllers
  Future<void> _disposeControllers() async {
    // First dispose chewie controller if it exists
    if (_chewieController != null) {
      try {
        final controller = _chewieController!;
        _chewieController = null;
        controller.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    }

    // Then dispose video controller if it exists
    if (_controller != null) {
      try {
        final controller = _controller!;
        _controller = null;
        controller.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    }
  }
}
