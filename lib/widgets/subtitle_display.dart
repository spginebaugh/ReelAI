import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../state/subtitle_controller.dart';

class SubtitleDisplay extends HookConsumerWidget {
  final double videoWidth;
  final double videoHeight;

  const SubtitleDisplay({
    super.key,
    required this.videoWidth,
    required this.videoHeight,
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
          color: Colors.black.withOpacity(0.8),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );

    return Container(
      width: videoWidth,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          subtitleState.currentCue!.text,
          style: subtitleState.style ?? defaultStyle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
