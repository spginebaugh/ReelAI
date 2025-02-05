import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video.dart';
import '../models/video_edit_state.dart';
import '../models/filter_option.dart';
import '../services/video_processing_service.dart';

part 'video_edit_provider.g.dart';

@riverpod
class VideoEditController extends _$VideoEditController {
  VideoProcessingService get _videoService => VideoProcessingService();

  @override
  Future<VideoEditState> build() async {
    ref.onDispose(() {
      state.whenData((state) {
        state.chewieController?.dispose();
        state.videoPlayerController?.dispose();
        _videoService.cleanup([
          state.tempVideoFile?.path,
          state.currentPreviewPath,
          state.processedVideoPath,
        ]);
      });
      _videoService.dispose();
    });

    return VideoEditState.initial();
  }

  Future<void> initializeVideo(Video video) async {
    if (state.value?.isInitialized ?? false) return;

    state = const AsyncValue.loading();

    try {
      // Download and save the original video
      final tempFile = await _videoService.downloadVideo(video.videoUrl);

      // Initialize video player
      final videoPlayerController = VideoPlayerController.file(tempFile);
      await videoPlayerController.initialize();

      final chewieController = await _videoService.initializePlayer(tempFile);
      final duration = await _videoService.getVideoDuration(tempFile);

      state = AsyncValue.data(
        VideoEditState(
          isProcessing: false,
          isLoading: false,
          isPlaying: false,
          isInitialized: true,
          currentMode: EditingMode.none,
          startValue: 0,
          endValue: duration,
          brightness: 1.0,
          selectedFilter: FilterOption.none,
          tempVideoFile: tempFile,
          currentPreviewPath: null,
          processedVideoPath: null,
          videoPlayerController: videoPlayerController,
          chewieController: chewieController,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setMode(EditingMode mode) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(currentMode: mode));
    });
  }

  Future<void> applyFilters() async {
    final currentState = state.value;
    if (currentState == null || currentState.isProcessing) return;

    state = AsyncValue.data(currentState.copyWith(isProcessing: true));

    try {
      currentState.chewieController?.pause();

      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final filteredPath = await _videoService.applyFilters(
        inputFile: currentState.tempVideoFile!,
        filter: currentState.selectedFilter,
        brightness: currentState.brightness,
        outputPath: outputPath,
      );

      // Clean up previous preview file
      await _videoService.cleanup([currentState.currentPreviewPath]);

      final newChewieController =
          await _videoService.initializePlayer(File(filteredPath));

      state = AsyncValue.data(currentState.copyWith(
        currentPreviewPath: filteredPath,
        isProcessing: false,
        chewieController: newChewieController,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> processVideo() async {
    final currentState = state.value;
    if (currentState == null || currentState.isProcessing) return;

    state = AsyncValue.data(currentState.copyWith(isProcessing: true));

    try {
      final outputPath = await _videoService.trimVideo(
        inputFile: currentState.tempVideoFile!,
        startValue: currentState.startValue,
        endValue: currentState.endValue,
      );

      if (outputPath != null) {
        state = AsyncValue.data(currentState.copyWith(
          processedVideoPath: outputPath,
          isProcessing: false,
          tempVideoFile: File(outputPath),
        ));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateStartValue(double value) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(startValue: value));
    });
  }

  void updateEndValue(double value) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(endValue: value));
    });
  }

  void updatePlaybackState(bool isPlaying) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(isPlaying: isPlaying));
    });
  }

  void updateFilter(FilterOption filter) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(selectedFilter: filter));
      applyFilters();
    });
  }

  void updateBrightness(double value) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(brightness: value));
    });
  }
}
