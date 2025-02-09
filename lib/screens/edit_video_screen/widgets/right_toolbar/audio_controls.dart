import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../models/video.dart';
import '../../../../state/audio_language_provider.dart';
import '../../../../state/audio_player_provider.dart';
import '../../../../utils/language_utils.dart';

class AudioControls extends ConsumerWidget {
  final Video video;

  const AudioControls({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(audioLanguageControllerProvider(video.id));
    final audioState = ref.watch(audioPlayerControllerProvider);

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: audioState.isSyncing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.translate),
      onPressed: languages.when(
        data: (availableLanguages) {
          if (availableLanguages.length <= 1 || audioState.isSyncing) {
            return null;
          }
          return () {
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay = Navigator.of(context)
                .overlay!
                .context
                .findRenderObject() as RenderBox;
            final position = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(
                  Offset.zero,
                  ancestor: overlay,
                ),
                button.localToGlobal(
                  button.size.bottomRight(Offset.zero),
                  ancestor: overlay,
                ),
              ),
              Offset.zero & overlay.size,
            );

            showMenu<String>(
              context: context,
              position: position,
              items: availableLanguages.map((lang) {
                final isSelected = lang == audioState.currentLanguage;
                return PopupMenuItem<String>(
                  value: lang,
                  child: Row(
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Text(getLanguageDisplayName(lang)),
                    ],
                  ),
                );
              }).toList(),
            ).then((selectedLanguage) async {
              if (selectedLanguage != null) {
                try {
                  await ref
                      .read(audioPlayerControllerProvider.notifier)
                      .switchLanguage(video.id, selectedLanguage);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to switch language: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              }
            });
          };
        },
        loading: () => null,
        error: (_, __) =>
            () => ref.invalidate(audioLanguageControllerProvider(video.id)),
      ),
    );
  }
}
