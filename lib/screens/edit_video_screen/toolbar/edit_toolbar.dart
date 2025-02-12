import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/models/video.dart';
import 'package:reel_ai/models/video_edit_state.dart';
import 'package:reel_ai/features/videos/providers/video_edit_provider.dart';
import '../features/brightness/brightness_button.dart';
import '../features/filter/filter_button.dart';
import '../features/trim/trim_button.dart';
import '../features/metadata/metadata_button.dart';
import '../features/audio/audio_button.dart';
import '../features/subtitles/subtitle_button.dart';

class EditToolbar extends ConsumerWidget {
  final Video video;

  const EditToolbar({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
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
                  color: state.currentMode == EditingMode.none
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
                onPressed: () => ref
                    .read(videoEditControllerProvider.notifier)
                    .setMode(EditingMode.none),
              ),
              const SizedBox(height: 16),
              MetadataButton(video: video),
              const SizedBox(height: 100),
              const TrimButton(),
              const SizedBox(height: 16),
              const FilterButton(),
              const SizedBox(height: 16),
              const BrightnessButton(),
              const SizedBox(height: 100),
              AudioButton(video: video),
              const SizedBox(height: 16),
              SubtitleButton(video: video),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
