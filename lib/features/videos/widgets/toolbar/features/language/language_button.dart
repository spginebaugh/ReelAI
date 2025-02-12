import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/models/video_player_state.dart';
import 'package:reel_ai/features/videos/providers/video_player_facade.dart';

class LanguageButton extends ConsumerWidget {
  final String videoId;

  const LanguageButton({
    Key? key,
    required this.videoId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoPlayerFacadeProvider);

    return videoState.when(
      data: (state) {
        final availableLanguages = state.audio.availableLanguages;
        final currentLanguage = state.audio.currentLanguage;
        final isLoading = state.audio.isLoading;

        return Stack(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip:
                  'Change Language (${_getLanguageDisplayName(currentLanguage)})',
              icon: Icon(
                Icons.translate,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: isLoading
                  ? null
                  : () => _showLanguageMenu(
                        context,
                        ref,
                        availableLanguages.isEmpty
                            ? [currentLanguage]
                            : availableLanguages,
                        currentLanguage,
                      ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: null,
        icon: Icon(
          Icons.translate,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
      error: (error, _) => IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: 'Error loading languages: $error',
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        ),
        onPressed: () => ref.invalidate(videoPlayerFacadeProvider),
      ),
    );
  }

  void _showLanguageMenu(
    BuildContext context,
    WidgetRef ref,
    List<String> languages,
    String currentLanguage,
  ) {
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
            mainAxisSize: MainAxisSize.min,
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
        try {
          await ref
              .read(videoPlayerFacadeProvider.notifier)
              .switchAudioLanguage(selectedLanguage);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: SelectableText.rich(
                  TextSpan(
                    text: 'Failed to switch language: ',
                    children: [
                      TextSpan(
                        text: e.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
            );
          }
        }
      }
    });
  }

  String _getLanguageDisplayName(String languageCode) {
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
