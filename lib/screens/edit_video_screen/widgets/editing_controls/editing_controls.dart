import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../models/video_edit_state.dart';
import '../../../../state/video_edit_provider.dart';
import 'trim_controls_widget.dart';
import 'filter_controls_widget.dart';
import 'brightness_controls_widget.dart';

class EditingControls extends ConsumerWidget {
  final VideoEditState editState;

  const EditingControls({
    Key? key,
    required this.editState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _buildControls(context, ref),
      ),
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref) {
    switch (editState.currentMode) {
      case EditingMode.trim:
        return TrimControlsWidget(
          controller: editState.videoPlayerController!,
          startValue: editState.startValue,
          endValue: editState.endValue,
          onChangeStart: (value) => ref
              .read(videoEditControllerProvider.notifier)
              .updateStartValue(value),
          onChangeEnd: (value) => ref
              .read(videoEditControllerProvider.notifier)
              .updateEndValue(value),
          onChangePlaybackState: (value) => ref
              .read(videoEditControllerProvider.notifier)
              .updatePlaybackState(value),
          onApplyTrim: () =>
              ref.read(videoEditControllerProvider.notifier).processVideo(),
          isProcessing: editState.isProcessing,
        );

      case EditingMode.filter:
        return FilterControlsWidget(
          selectedFilter: editState.selectedFilter,
          availableFilters: editState.availableFilters,
          onFilterSelected: (filter) => ref
              .read(videoEditControllerProvider.notifier)
              .updateFilter(filter),
        );

      case EditingMode.brightness:
        return BrightnessControlsWidget(
          brightness: editState.brightness,
          onChanged: (value) => ref
              .read(videoEditControllerProvider.notifier)
              .updateBrightness(value),
          onChangeEnd: (value) =>
              ref.read(videoEditControllerProvider.notifier).applyFilters(),
        );

      case EditingMode.none:
      case EditingMode.metadata:
        return const SizedBox.shrink();
    }
  }
}
