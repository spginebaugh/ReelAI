import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/features/videos/providers/subtitle_controller.dart';
import 'package:reel_ai/common/utils/language_utils.dart';
import 'subtitle_controller.dart';

class SubtitleMenu extends PopupMenuEntry<String> {
  final Video video;

  const SubtitleMenu({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  double get height => 0; // Dynamically sized

  @override
  bool represents(String? value) => false;

  @override
  _SubtitleMenuState createState() => _SubtitleMenuState();
}

class _SubtitleMenuState extends State<SubtitleMenu> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final subtitleState = ref.watch(subtitleControllerProvider);
        final controller =
            ref.watch(subtitleFeatureControllerProvider.notifier);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              onTap: () => controller.toggleVisibility(),
            ),
            // Language options
            ...controller.availableLanguages.map(
              (lang) => PopupMenuItem<String>(
                value: lang,
                child: Row(
                  children: [
                    if (subtitleState.isVisible &&
                        subtitleState.language == lang)
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
                    await controller.loadLanguage(widget.video.id, lang);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Failed to switch subtitle language: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
