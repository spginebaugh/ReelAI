import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../state/video_edit_provider.dart';

class PlaybackSpeedButton extends ConsumerWidget {
  const PlaybackSpeedButton({Key? key}) : super(key: key);

  static const List<double> _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
      data: (state) => PopupMenuButton<double>(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.speed),
        itemBuilder: (context) => _speeds
            .map(
              (speed) => PopupMenuItem(
                value: speed,
                child: Text('${speed}x'),
              ),
            )
            .toList(),
        onSelected: (speed) {
          if (state.videoPlayerController != null) {
            state.videoPlayerController!.setPlaybackSpeed(speed);
          }
        },
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
