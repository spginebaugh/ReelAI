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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.black,
                child: Chewie(controller: chewieController),
              ),
              // Fixed position subtitle overlay
              const Positioned(
                left: 0,
                right: 0,
                bottom: 80,
                child: SubtitleDisplay(),
              ),
            ],
          );
        },
      ),
    );
  }
}
