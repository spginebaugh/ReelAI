import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../state/subtitle_controller.dart';
import '../../../widgets/subtitle_display.dart';

class VideoPlayerSection extends ConsumerWidget {
  final ChewieController chewieController;
  final String videoId;

  const VideoPlayerSection({
    Key? key,
    required this.chewieController,
    required this.videoId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Chewie(controller: chewieController),
            // Subtitle overlay using our new system
            Consumer(
              builder: (context, ref, _) {
                final videoSize =
                    chewieController.videoPlayerController.value.size;
                return SubtitleDisplay(
                  videoWidth: videoSize.width,
                  videoHeight: videoSize.height,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
