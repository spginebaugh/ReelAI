import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../state/subtitle_controller.dart';

class SubtitleDisplay extends HookConsumerWidget {
  const SubtitleDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleState = ref.watch(subtitleControllerProvider);

    if (!subtitleState.isVisible || subtitleState.currentCue == null) {
      return const SizedBox.shrink();
    }

    final defaultStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
      color: Colors.white,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.9),
          offset: const Offset(1, 1),
          blurRadius: 3,
        ),
        Shadow(
          color: Colors.black.withOpacity(0.9),
          offset: const Offset(-1, -1),
          blurRadius: 3,
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      alignment: Alignment.center,
      child: Text(
        subtitleState.currentCue!.text,
        style: subtitleState.style ?? defaultStyle,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
