import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/models/video_edit_state.dart';
import 'package:reel_ai/features/videos/providers/video_edit_provider.dart';

class BrightnessButton extends ConsumerWidget {
  const BrightnessButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
      data: (state) => IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.brightness_6,
          color: state.currentMode == EditingMode.brightness
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        onPressed: () {
          final currentMode = state.currentMode;
          ref.read(videoEditControllerProvider.notifier).setMode(
                currentMode == EditingMode.brightness
                    ? EditingMode.none
                    : EditingMode.brightness,
              );
        },
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
