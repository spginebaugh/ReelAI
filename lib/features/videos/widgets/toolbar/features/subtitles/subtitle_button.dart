import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/features/videos/models/video_player_state.dart';
import 'package:reel_ai/features/videos/providers/video_player_facade.dart';

class SubtitleButton extends ConsumerWidget {
  final Video video;

  const SubtitleButton({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoPlayerFacadeProvider);

    return videoState.when(
      data: (state) => PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          state.subtitles.isEnabled ? Icons.subtitles : Icons.subtitles_off,
          color: state.mode == VideoMode.edit
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        itemBuilder: (context) {
          final List<PopupMenuEntry<String>> items = [
            const PopupMenuItem<String>(
              value: 'off',
              child: Text('Off'),
            ),
            if (state.subtitles.availableLanguages.isNotEmpty)
              const PopupMenuDivider(),
            ...state.subtitles.availableLanguages.map(
              (language) => PopupMenuItem<String>(
                value: language,
                child: Row(
                  children: [
                    Text(language),
                    if (state.subtitles.isEnabled &&
                        state.subtitles.currentLanguage == language)
                      const SizedBox(width: 8),
                    if (state.subtitles.isEnabled &&
                        state.subtitles.currentLanguage == language)
                      const Icon(Icons.check, size: 16),
                  ],
                ),
              ),
            ),
          ];
          return items;
        },
        onSelected: (String value) {
          if (value == 'off') {
            ref.read(videoPlayerFacadeProvider.notifier).disableSubtitles();
          } else {
            ref
                .read(videoPlayerFacadeProvider.notifier)
                .switchSubtitleLanguage(value);
          }
        },
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
