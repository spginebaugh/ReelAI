import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/models/video_edit_state.dart';
import 'package:reel_ai/features/videos/providers/video_edit_provider.dart';

class TrimButton extends ConsumerWidget {
  const TrimButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
      data: (state) => IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.content_cut,
          color: state.currentMode == EditingMode.trim
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        onPressed: () {
          final currentMode = state.currentMode;
          ref.read(videoEditControllerProvider.notifier).setMode(
                currentMode == EditingMode.trim
                    ? EditingMode.none
                    : EditingMode.trim,
              );
        },
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
