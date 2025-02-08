import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../state/audio_language_provider.dart';
import '../state/audio_player_provider.dart';

/// A button that shows a popup menu for selecting the audio language
class LanguageSelectorButton extends HookConsumerWidget {
  final String videoId;
  final bool showLabel;

  const LanguageSelectorButton({
    super.key,
    required this.videoId,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(audioLanguageControllerProvider(videoId));
    final currentLanguage = ref.watch(currentLanguageProvider(videoId));
    final audioState = ref.watch(audioPlayerControllerProvider);

    return languages.when(
      data: (availableLanguages) {
        // If only English is available, disable the button
        if (availableLanguages.length <= 1) {
          return FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.translate),
            label: showLabel ? const Text('No Translations') : const SizedBox(),
          );
        }

        return FilledButton.icon(
          onPressed: audioState.isSyncing
              ? null
              : () => _showLanguageMenu(
                    context,
                    ref,
                    availableLanguages,
                    currentLanguage,
                  ),
          icon: audioState.isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.translate),
          label: showLabel
              ? Text(audioState.isSyncing
                  ? 'Switching...'
                  : _getLanguageDisplayName(currentLanguage))
              : const SizedBox(),
        );
      },
      loading: () => FilledButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        label: showLabel ? const Text('Loading...') : const SizedBox(),
      ),
      error: (error, stack) => FilledButton.icon(
        onPressed: () =>
            ref.invalidate(audioLanguageControllerProvider(videoId)),
        icon: const Icon(Icons.error_outline),
        label: showLabel ? const Text('Error Loading') : const SizedBox(),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
      ),
    );
  }

  void _showLanguageMenu(
    BuildContext context,
    WidgetRef ref,
    List<String> languages,
    String currentLanguage,
  ) {
    debugPrint('🌐 LanguageSelector: Opening language menu');
    debugPrint('🌐 LanguageSelector: Available languages: $languages');
    debugPrint('🌐 LanguageSelector: Current language: $currentLanguage');

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: languages.map((lang) {
        final isSelected = lang == currentLanguage;
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
              Text(_getLanguageDisplayName(lang)),
            ],
          ),
        );
      }).toList(),
    ).then((selectedLanguage) async {
      if (selectedLanguage != null && context.mounted) {
        debugPrint('🌐 LanguageSelector: Language selected: $selectedLanguage');
        try {
          debugPrint(
              '🌐 LanguageSelector: Switching to language: $selectedLanguage');
          await ref
              .read(audioPlayerControllerProvider.notifier)
              .switchLanguage(videoId, selectedLanguage);
          debugPrint('✅ LanguageSelector: Language switch successful');
        } catch (e) {
          debugPrint('❌ LanguageSelector: Failed to switch language: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to switch language: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      } else {
        debugPrint(
            '🌐 LanguageSelector: No language selected or context not mounted');
      }
    });
  }

  String _getLanguageDisplayName(String languageCode) {
    // Map of language codes to their display names
    const languageNames = {
      'english': 'English',
      'spanish': 'Spanish',
      'french': 'French',
      'german': 'German',
      'italian': 'Italian',
      'portuguese': 'Portuguese',
      'russian': 'Russian',
      'japanese': 'Japanese',
      'korean': 'Korean',
      'chinese': 'Chinese',
      'hindi': 'Hindi',
      'arabic': 'Arabic',
    };

    return languageNames[languageCode.toLowerCase()] ??
        languageCode.substring(0, 1).toUpperCase() +
            languageCode.substring(1).toLowerCase();
  }
}
