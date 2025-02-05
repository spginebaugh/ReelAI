import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chewie/chewie.dart';
import '../models/video.dart';
import '../models/video_edit_state.dart';
import '../models/filter_option.dart';
import '../utils/constants.dart';
import '../router/route_names.dart';
import '../widgets/trim_controls_widget.dart';
import '../widgets/filter_controls_widget.dart';
import '../widgets/brightness_controls_widget.dart';
import '../state/video_edit_provider.dart';

class EditVideoScreen extends ConsumerStatefulWidget {
  final Video video;
  const EditVideoScreen({Key? key, required this.video}) : super(key: key);

  @override
  ConsumerState<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends ConsumerState<EditVideoScreen> {
  final List<FilterOption> _filterOptions =
      VideoConstants.videoFilters.toFilterOptions();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(videoEditControllerProvider.notifier)
          .initializeVideo(widget.video);
    });
  }

  Widget _buildEditingControls(VideoEditState editState) {
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
        );

      case EditingMode.filter:
        return FilterControlsWidget(
          selectedFilter: editState.selectedFilter.name,
          onFilterSelected: (filterName) {
            final filter =
                _filterOptions.firstWhere((f) => f.name == filterName);
            ref.read(videoEditControllerProvider.notifier).updateFilter(filter);
          },
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

  @override
  Widget build(BuildContext context) {
    final editStateAsync = ref.watch(videoEditControllerProvider);

    return editStateAsync.when(
      data: (editState) => Scaffold(
        appBar: AppBar(
          title: Text('Edit: ${widget.video.title}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: editState.isProcessing || editState.isLoading
                  ? null
                  : () => ref
                      .read(videoEditControllerProvider.notifier)
                      .processVideo(),
            ),
          ],
        ),
        body: Column(
          children: [
            if (editState.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (editState.chewieController != null) ...[
              Expanded(
                child: Center(
                  child: Container(
                    color: Colors.black,
                    child: Chewie(controller: editState.chewieController!),
                  ),
                ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (!editState.isLoading &&
                editState.currentMode != EditingMode.none)
              Container(
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
                  child: _buildEditingControls(editState),
                ),
              ),
            if (editState.isProcessing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: editState.currentMode == EditingMode.none
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onPressed: () => ref
                          .read(videoEditControllerProvider.notifier)
                          .setMode(EditingMode.none),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.content_cut,
                        color: editState.currentMode == EditingMode.trim
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onPressed: () => ref
                          .read(videoEditControllerProvider.notifier)
                          .setMode(EditingMode.trim),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.filter,
                        color: editState.currentMode == EditingMode.filter
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onPressed: () => ref
                          .read(videoEditControllerProvider.notifier)
                          .setMode(EditingMode.filter),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.brightness_6,
                        color: editState.currentMode == EditingMode.brightness
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onPressed: () => ref
                          .read(videoEditControllerProvider.notifier)
                          .setMode(EditingMode.brightness),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_note,
                        color: editState.currentMode == EditingMode.metadata
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onPressed: () {
                        context.pushNamed(
                          RouteNames.editVideoMetadata,
                          pathParameters: {'id': widget.video.id},
                          extra: widget.video,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
