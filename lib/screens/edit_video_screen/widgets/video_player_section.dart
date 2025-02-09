import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../state/subtitle_controller.dart';

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
            // Subtitle overlay
            Consumer(
              builder: (context, ref, _) {
                final subtitleState = ref.watch(subtitleControllerProvider);
                if (!subtitleState.isEnabled ||
                    subtitleState.currentText == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 48.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subtitleState.currentText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
