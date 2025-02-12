import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:reel_ai/features/videos/services/factories/chewie_controller_factory.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController videoController;
  final bool showControls;
  final bool autoPlay;
  final bool allowFullScreen;

  const VideoPlayerWidget({
    super.key,
    required this.videoController,
    this.showControls = true,
    this.autoPlay = false,
    this.allowFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final videoAspectRatio = videoController.value.aspectRatio;

    double videoWidth = screenSize.width;
    double videoHeight = screenSize.width / videoAspectRatio;

    if (videoHeight < screenSize.height) {
      videoHeight = screenSize.height;
      videoWidth = videoHeight * videoAspectRatio;
    }

    final chewieController = ChewieControllerFactory.create(
      videoController,
      showControls: showControls,
      autoPlay: autoPlay,
      allowFullScreen: allowFullScreen,
    );

    return Center(
      child: SizedBox.fromSize(
        size: Size(videoWidth, videoHeight),
        child: Chewie(controller: chewieController),
      ),
    );
  }
}
