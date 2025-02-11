import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'playback_speed_controller.dart';

class PlaybackSpeedMenu extends ConsumerWidget {
  const PlaybackSpeedMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<double>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.speed),
      itemBuilder: (context) => PlaybackSpeedController.speeds
          .map(
            (speed) => PopupMenuItem(
              value: speed,
              child: Text('${speed}x'),
            ),
          )
          .toList(),
      onSelected: (speed) =>
          ref.read(playbackSpeedControllerProvider.notifier).setSpeed(speed),
    );
  }
}
