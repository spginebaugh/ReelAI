import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/providers/video_player_facade.dart';

class SubtitleDisplay extends HookConsumerWidget {
  const SubtitleDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoPlayerFacadeProvider);

    return videoState.when(
      data: (state) {
        if (!state.subtitles.isEnabled || state.subtitles.isLoading) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          alignment: Alignment.bottomCenter,
          child: Text(
            state.subtitles.currentText ?? '',
            style: defaultStyle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
