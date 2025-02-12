import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/features/videos/models/video_player_state.dart';
import 'package:reel_ai/features/videos/providers/video_player_facade.dart';
import 'features/metadata/metadata_button.dart';
import 'features/subtitles/subtitle_button.dart';
import 'features/language/language_button.dart';

class EditToolbar extends ConsumerWidget {
  final Video video;

  const EditToolbar({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoPlayerFacadeProvider);

    return videoState.when(
      data: (state) => SizedBox(
        width: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              // Close button at the top
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.close,
                  color: state.mode == VideoMode.view
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
                onPressed: () => ref
                    .read(videoPlayerFacadeProvider.notifier)
                    .setMode(VideoMode.view),
              ),
              const SizedBox(height: 16),
              // Metadata button
              MetadataButton(video: video),
              const Spacer(),
              // Language and subtitle controls
              SubtitleButton(video: video),
              const SizedBox(height: 16),
              LanguageButton(videoId: video.id),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox(
        width: 56,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox(
        width: 56,
        child: Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
      ),
    );
  }
}
