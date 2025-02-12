import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/models/video_edit_state.dart';
import 'package:reel_ai/features/videos/providers/video_edit_provider.dart';

class FilterButton extends ConsumerWidget {
  const FilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
      data: (state) => IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.filter,
          color: state.currentMode == EditingMode.filter
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        onPressed: () {
          final currentMode = state.currentMode;
          ref.read(videoEditControllerProvider.notifier).setMode(
                currentMode == EditingMode.filter
                    ? EditingMode.none
                    : EditingMode.filter,
              );
        },
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
