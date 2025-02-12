import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/features/videos/providers/subtitle_controller.dart';
import 'subtitle_menu.dart';

class SubtitleButton extends ConsumerWidget {
  final Video video;

  const SubtitleButton({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleState = ref.watch(subtitleControllerProvider);

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        Icons.closed_caption,
        color: subtitleState.isVisible
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
      itemBuilder: (context) => [
        SubtitleMenu(video: video),
      ],
    );
  }
}
