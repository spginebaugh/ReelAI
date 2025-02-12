import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/providers/video_edit_provider.dart';
import 'package:reel_ai/features/videos/models/video_edit_state.dart';
import 'features/brightness/brightness_panel.dart';
import 'features/filter/filter_panel.dart';
import 'features/trim/trim_panel.dart';

class PanelContainer extends ConsumerWidget {
  const PanelContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
      data: (state) {
        if (state.currentMode == EditingMode.none) {
          return const SizedBox.shrink();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildPanelForMode(state.currentMode),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPanelForMode(EditingMode mode) {
    switch (mode) {
      case EditingMode.brightness:
        return const BrightnessPanel();
      case EditingMode.filter:
        return const FilterPanel();
      case EditingMode.trim:
        return const TrimPanel();
      case EditingMode.none:
      case EditingMode.metadata:
        return const SizedBox.shrink();
    }
  }
}
