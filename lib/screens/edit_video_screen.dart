import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/language_selector_button.dart';
import '../state/video_edit_provider.dart';
import '../state/audio_language_provider.dart';
import '../state/audio_player_provider.dart';

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
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(videoEditControllerProvider.notifier)
          .initializeVideo(widget.video);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _showSpeedDialog() {
    final speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: speeds.length,
            itemBuilder: (context, index) {
              final speed = speeds[index];
              return ListTile(
                dense: true,
                title: Text('${speed}x'),
                onTap: () {
                  final editState = ref.read(videoEditControllerProvider).value;
                  editState?.videoPlayerController?.setPlaybackSpeed(speed);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
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
          onApplyTrim: () =>
              ref.read(videoEditControllerProvider.notifier).processVideo(),
          isProcessing: editState.isProcessing,
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pushReplacementNamed(RouteNames.myVideos),
          ),
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
                child: Row(
                  children: [
                    // Video section
                    Expanded(
                      child: Center(
                        child: Container(
                          color: Colors.black,
                          child:
                              Chewie(controller: editState.chewieController!),
                        ),
                      ),
                    ),
                    // Right side tools
                    Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(-2, 0),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.close,
                                  color: editState.currentMode ==
                                          EditingMode.none
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                onPressed: () => ref
                                    .read(videoEditControllerProvider.notifier)
                                    .setMode(EditingMode.none),
                              ),
                              const SizedBox(height: 16),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.content_cut,
                                  color: editState.currentMode ==
                                          EditingMode.trim
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                onPressed: () => ref
                                    .read(videoEditControllerProvider.notifier)
                                    .setMode(EditingMode.trim),
                              ),
                              const SizedBox(height: 16),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.filter,
                                  color: editState.currentMode ==
                                          EditingMode.filter
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                onPressed: () => ref
                                    .read(videoEditControllerProvider.notifier)
                                    .setMode(EditingMode.filter),
                              ),
                              const SizedBox(height: 16),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.brightness_6,
                                  color: editState.currentMode ==
                                          EditingMode.brightness
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                onPressed: () => ref
                                    .read(videoEditControllerProvider.notifier)
                                    .setMode(EditingMode.brightness),
                              ),
                              const SizedBox(height: 16),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  Icons.edit_note,
                                  color: editState.currentMode ==
                                          EditingMode.metadata
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
                              const SizedBox(height: 16),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.speed),
                                onPressed: _showSpeedDialog,
                              ),
                              const Spacer(),
                              Consumer(
                                builder: (context, ref, _) {
                                  final languages = ref.watch(
                                    audioLanguageControllerProvider(
                                        widget.video.id),
                                  );
                                  final audioState =
                                      ref.watch(audioPlayerControllerProvider);

                                  return IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: audioState.isSyncing
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.translate),
                                    onPressed: languages.when(
                                      data: (availableLanguages) {
                                        if (availableLanguages.length <= 1 ||
                                            audioState.isSyncing) {
                                          return null;
                                        }
                                        return () {
                                          final RenderBox button = context
                                              .findRenderObject() as RenderBox;
                                          final RenderBox overlay =
                                              Navigator.of(context)
                                                      .overlay!
                                                      .context
                                                      .findRenderObject()
                                                  as RenderBox;
                                          final position =
                                              RelativeRect.fromRect(
                                            Rect.fromPoints(
                                              button.localToGlobal(
                                                Offset.zero,
                                                ancestor: overlay,
                                              ),
                                              button.localToGlobal(
                                                button.size
                                                    .bottomRight(Offset.zero),
                                                ancestor: overlay,
                                              ),
                                            ),
                                            Offset.zero & overlay.size,
                                          );

                                          showMenu<String>(
                                            context: context,
                                            position: position,
                                            items:
                                                availableLanguages.map((lang) {
                                              final isSelected = lang ==
                                                  audioState.currentLanguage;
                                              return PopupMenuItem<String>(
                                                value: lang,
                                                child: Row(
                                                  children: [
                                                    if (isSelected)
                                                      Icon(
                                                        Icons.check,
                                                        size: 18,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      )
                                                    else
                                                      const SizedBox(width: 18),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                        _getLanguageDisplayName(
                                                            lang)),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ).then((selectedLanguage) async {
                                            if (selectedLanguage != null) {
                                              try {
                                                await ref
                                                    .read(
                                                        audioPlayerControllerProvider
                                                            .notifier)
                                                    .switchLanguage(
                                                        widget.video.id,
                                                        selectedLanguage);
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Failed to switch language: $e'),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .error,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          });
                                        };
                                      },
                                      loading: () => null,
                                      error: (_, __) => () => ref.invalidate(
                                            audioLanguageControllerProvider(
                                                widget.video.id),
                                          ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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

  String _getLanguageDisplayName(String languageCode) {
    const languageNames = {
      'english': 'English',
      'spanish': 'Spanish',
      'french': 'French',
      'german': 'German',
      'italian': 'Italian',
      'portuguese': 'Portuguese',
      'russian': 'Russian',
      'japanese': 'Japanese',
      'korean': 'Korean',
      'chinese': 'Chinese',
      'hindi': 'Hindi',
      'arabic': 'Arabic',
    };

    return languageNames[languageCode.toLowerCase()] ??
        languageCode.substring(0, 1).toUpperCase() +
            languageCode.substring(1).toLowerCase();
  }
}
