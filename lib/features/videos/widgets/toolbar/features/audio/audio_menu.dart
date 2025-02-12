import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/features/videos/providers/audio_language_provider.dart';
import 'package:reel_ai/features/videos/providers/audio_player_provider.dart';
import 'package:reel_ai/common/utils/language_utils.dart';
import 'audio_controller.dart';

class AudioMenu extends PopupMenuEntry<String> {
  final Video video;

  const AudioMenu({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  double get height => 0; // Dynamically sized

  @override
  bool represents(String? value) => false;

  @override
  _AudioMenuState createState() => _AudioMenuState();
}

class _AudioMenuState extends State<AudioMenu> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final languages =
            ref.watch(audioLanguageControllerProvider(widget.video.id));
        final audioState = ref.watch(audioPlayerControllerProvider);

        return languages.when(
          data: (availableLanguages) {
            if (availableLanguages.length <= 1) {
              return const PopupMenuItem<String>(
                enabled: false,
                child: Text('No other languages available'),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: availableLanguages.map((lang) {
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
                  onTap: () async {
                    try {
                      await ref
                          .read(audioControllerProvider.notifier)
                          .switchLanguage(widget.video.id, lang);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to switch language: $e'),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                );
              }).toList(),
            );
          },
          loading: () => const PopupMenuItem<String>(
            enabled: false,
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => PopupMenuItem<String>(
            enabled: false,
            onTap: () => ref
                .read(audioControllerProvider.notifier)
                .refreshLanguages(widget.video.id),
            child: const Text('Error loading languages. Tap to retry.'),
          ),
        );
      },
    );
  }
}
