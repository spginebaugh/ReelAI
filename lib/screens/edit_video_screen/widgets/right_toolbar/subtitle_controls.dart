import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../models/video.dart';
import '../../../../state/subtitle_controller.dart';
import '../../../../state/auth_provider.dart';
import '../../../../utils/language_utils.dart';

class SubtitleControls extends ConsumerWidget {
  final Video video;

  const SubtitleControls({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleState = ref.watch(subtitleControllerProvider);
    final user = ref.watch(authStateProvider).requireValue!;

    return PopupMenuButton<String?>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        Icons.closed_caption,
        color: subtitleState.isEnabled
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
      onSelected: (language) async {
        if (language == null) {
          // Off selected
          if (subtitleState.isEnabled) {
            ref.read(subtitleControllerProvider.notifier).toggleSubtitles();
          }
        } else {
          // Language selected
          if (!subtitleState.isEnabled) {
            ref.read(subtitleControllerProvider.notifier).toggleSubtitles();
          }
          // Switch to selected language
          try {
            await ref
                .read(subtitleControllerProvider.notifier)
                .switchLanguage(video.id, user.uid, language);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to switch subtitle language: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String?>(
          value: null,
          child: Row(
            children: [
              if (!subtitleState.isEnabled)
                Icon(
                  Icons.check,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                )
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              const Text('Off'),
            ],
          ),
        ),
        ...subtitleState.availableLanguages.map(
          (lang) => PopupMenuItem<String?>(
            value: lang,
            child: Row(
              children: [
                if (subtitleState.isEnabled &&
                    subtitleState.currentLanguage == lang)
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
          ),
        ),
      ],
    );
  }
}
