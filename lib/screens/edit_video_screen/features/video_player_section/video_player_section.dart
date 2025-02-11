import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../models/video_edit_state.dart';

class VideoPlayerSection extends ConsumerWidget {
  const VideoPlayerSection({
    super.key,
    required this.editState,
  });

  final VideoEditState editState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (editState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (editState.chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate the video dimensions to maintain aspect ratio while filling the screen
    final screenSize = MediaQuery.of(context).size;
    final videoAspectRatio =
        editState.chewieController!.videoPlayerController.value.aspectRatio;

    double videoWidth = screenSize.width;
    double videoHeight = screenSize.width / videoAspectRatio;

    if (videoHeight < screenSize.height) {
      videoHeight = screenSize.height;
      videoWidth = videoHeight * videoAspectRatio;
    }

    return Center(
      child: SizedBox.fromSize(
        size: Size(videoWidth, videoHeight),
        child: Chewie(
          controller: editState.chewieController!,
        ),
      ),
    );
  }
}
