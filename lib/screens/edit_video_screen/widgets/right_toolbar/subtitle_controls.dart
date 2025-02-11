import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../models/video.dart';
import '../../../../state/subtitle_controller.dart';
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
    final subtitleController = ref.watch(subtitleControllerProvider.notifier);

    debugPrint('🎬 SubtitleControls: Building with state:');
    debugPrint('   - isVisible: ${subtitleState.isVisible}');
    debugPrint('   - current language: ${subtitleState.language}');
    debugPrint(
        '   - available languages: ${subtitleController.availableLanguages}');

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        Icons.closed_caption,
        color: subtitleState.isVisible
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
      onSelected: (language) async {
        debugPrint('🎬 SubtitleControls: Language selected: $language');
        if (language == 'OFF') {
          // Toggle visibility
          debugPrint('🎬 SubtitleControls: Toggling visibility');
          ref.read(subtitleControllerProvider.notifier).toggleVisibility();
        } else {
          // Switch language
          debugPrint('🎬 SubtitleControls: Switching to language: $language');
          try {
            await ref
                .read(subtitleControllerProvider.notifier)
                .loadLanguage(video.id, language);
            debugPrint('🎬 SubtitleControls: Successfully switched language');
          } catch (e) {
            debugPrint('❌ SubtitleControls: Failed to switch language: $e');
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
      itemBuilder: (context) {
        final items = [
          // Toggle visibility option
          PopupMenuItem<String>(
            value: 'OFF',
            child: Row(
              children: [
                if (!subtitleState.isVisible)
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
          // Language options
          ...subtitleController.availableLanguages.map(
            (lang) => PopupMenuItem<String>(
              value: lang,
              child: Row(
                children: [
                  // Only show checkmark if subtitles are visible and this is the current language
                  if (subtitleState.isVisible && subtitleState.language == lang)
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
        ];
        debugPrint('🎬 SubtitleControls: Built ${items.length} menu items');
        return items;
      },
    );
  }
}
