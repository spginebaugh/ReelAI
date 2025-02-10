import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/video.dart';
import '../models/video_edit_state.dart';
import '../models/filter_option.dart';
import '../services/video_processing_service.dart';
import '../utils/storage_paths.dart';
import '../services/video/factories/chewie_controller_factory.dart';
import '../services/video/factories/video_player_factory.dart';
import 'auth_provider.dart';
import 'audio_player_provider.dart';
import 'subtitle_controller.dart';
import 'package:flutter/foundation.dart';
import '../state/subtitle_controller.dart';

part 'video_edit_provider.g.dart';

@riverpod
class VideoEditController extends _$VideoEditController {
  VideoProcessingService get _videoService => VideoProcessingService();

  @override
  Future<VideoEditState> build() async {
    ref.onDispose(() {
      state.whenData((state) {
        _disposeCurrentControllers(state);
        _videoService.cleanup([
          state.tempVideoFile?.path,
          state.currentPreviewPath,
          state.processedVideoPath,
        ]);
      });
      _videoService.dispose();
      ref.read(audioPlayerControllerProvider.notifier).dispose();
    });

    return VideoEditState.initial();
  }

  // Helper Methods
  void _disposeCurrentControllers(VideoEditState state) {
    state.chewieController?.dispose();
    state.videoPlayerController?.dispose();
  }

  Future<void> _ensureControllersMuted(VideoPlayerController controller) async {
    debugPrint('🔇 Ensuring controllers are muted');
    await controller.setVolume(0);
    if (controller.value.volume > 0) {
      debugPrint('⚠️ Volume not 0, forcing mute');
      await controller.setVolume(0);
      if (controller.value.volume > 0) {
        throw Exception('Failed to mute video player');
      }
    }
  }

  Future<(VideoPlayerController, ChewieController)> _createAndVerifyControllers(
    File videoFile,
  ) async {
    debugPrint('🎥 Creating new video controllers');
    final videoPlayerController = await VideoPlayerFactory.create(videoFile);
    await _ensureControllersMuted(videoPlayerController);

    final chewieController = ChewieControllerFactory.create(
      videoPlayerController,
      showControls: true,
      allowFullScreen: true,
    );

    return (videoPlayerController, chewieController);
  }

  void _updateState(VideoEditState Function(VideoEditState) updater) {
    state.whenData((currentState) {
      state = AsyncValue.data(updater(currentState));

      // Verify muting after state update
      if (currentState.videoPlayerController != null &&
          currentState.videoPlayerController!.value.volume > 0) {
        _ensureControllersMuted(currentState.videoPlayerController!);
      }
    });
  }

  Future<void> _cleanupPreviousFiles(List<String?> paths) async {
    for (final path in paths) {
      if (path != null) {
        try {
          await _videoService.cleanup([path]);
        } catch (e) {
          debugPrint('⚠️ Error cleaning up file: $e');
        }
      }
    }
  }

  // Initialize Video System
  Future<void> _initializeVideoPlayer(File videoFile) async {
    debugPrint('🎥 Initializing video player system');
    final (videoPlayerController, chewieController) =
        await _createAndVerifyControllers(videoFile);

    final duration = await _videoService.getVideoDuration(videoFile);

    _updateState((currentState) => currentState.copyWith(
          isProcessing: false,
          isLoading: false,
          isPlaying: false,
          isInitialized: true,
          currentMode: EditingMode.none,
          startValue: 0,
          endValue: duration,
          brightness: 1.0,
          selectedFilter: FilterOption.none,
          tempVideoFile: videoFile,
          videoPlayerController: videoPlayerController,
          chewieController: chewieController,
        ));
  }

  Future<void> _initializeAudioSystem(
    VideoPlayerController controller,
    String videoId,
  ) async {
    debugPrint('🔊 Initializing audio system');
    await ref
        .read(audioPlayerControllerProvider.notifier)
        .initialize(controller);

    await ref
        .read(audioPlayerControllerProvider.notifier)
        .switchLanguage(videoId, 'english');
  }

  Future<void> _initializeSubtitleSystem(
    VideoPlayerController controller,
    String videoId,
    String userId,
    String subtitleUrl,
  ) async {
    debugPrint('📝 Initializing subtitle system');
    await ref
        .read(subtitleControllerProvider.notifier)
        .initialize(controller, subtitleUrl);

    await ref
        .read(subtitleControllerProvider.notifier)
        .loadAvailableLanguages(videoId, userId);
  }

  // Main Methods
  Future<void> initializeVideo(Video video) async {
    if (state.value?.isInitialized ?? false) return;

    state = const AsyncValue.loading();

    try {
      debugPrint('🎥 Starting video initialization');
      final tempFile = await _videoService.downloadVideo(video.videoUrl);

      await _initializeVideoPlayer(tempFile);

      // Get subtitle URL
      final storage = FirebaseStorage.instance;
      final user = ref.read(authStateProvider).requireValue!;
      final subtitlePath = StoragePaths.subtitlesFile(
        user.uid,
        video.id,
        format: 'vtt',
      );

      String? subtitleUrl;
      try {
        subtitleUrl = await storage.ref(subtitlePath).getDownloadURL();
        debugPrint('🎥 Got subtitle URL: $subtitleUrl');
      } catch (e) {
        debugPrint('⚠️ No subtitles found: $e');
      }

      // Initialize audio and subtitles
      final videoPlayerController = state.value!.videoPlayerController!;
      await _initializeAudioSystem(videoPlayerController, video.id);

      if (subtitleUrl != null) {
        await _initializeSubtitleSystem(
          videoPlayerController,
          video.id,
          user.uid,
          subtitleUrl,
        );
      }
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _prepareFilterApplication(VideoEditState currentState) async {
    currentState.chewieController?.pause();
    await _cleanupPreviousFiles([currentState.currentPreviewPath]);
  }

  Future<String> _createFilteredVideo(
    VideoEditState currentState,
    String outputPath,
  ) async {
    return _videoService.applyFilters(
      inputFile: currentState.tempVideoFile!,
      filter: currentState.selectedFilter,
      brightness: currentState.brightness,
      outputPath: outputPath,
    );
  }

  Future<void> applyFilters() async {
    final currentState = state.value;
    if (currentState == null || currentState.isProcessing) return;

    _updateState((state) => state.copyWith(isProcessing: true));

    try {
      await _prepareFilterApplication(currentState);

      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final filteredPath = await _createFilteredVideo(currentState, outputPath);

      final (videoPlayerController, chewieController) =
          await _createAndVerifyControllers(File(filteredPath));

      _updateState((state) => state.copyWith(
            currentPreviewPath: filteredPath,
            isProcessing: false,
            videoPlayerController: videoPlayerController,
            chewieController: chewieController,
          ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _prepareTrimming(VideoEditState currentState) async {
    _disposeCurrentControllers(currentState);
  }

  Future<String?> _performTrimOperation(VideoEditState currentState) async {
    return _videoService.trimVideo(
      inputFile: currentState.tempVideoFile!,
      startValue: currentState.startValue,
      endValue: currentState.endValue,
    );
  }

  Future<void> processVideo() async {
    final currentState = state.value;
    if (currentState == null || currentState.isProcessing) return;

    _updateState((state) => state.copyWith(isProcessing: true));

    try {
      await _prepareTrimming(currentState);
      final outputPath = await _performTrimOperation(currentState);

      if (outputPath != null) {
        final trimmedFile = File(outputPath);
        final (videoPlayerController, chewieController) =
            await _createAndVerifyControllers(trimmedFile);

        final duration = await _videoService.getVideoDuration(trimmedFile);

        await _cleanupPreviousFiles([currentState.tempVideoFile?.path]);

        _updateState((state) => state.copyWith(
              processedVideoPath: outputPath,
              isProcessing: false,
              tempVideoFile: trimmedFile,
              videoPlayerController: videoPlayerController,
              chewieController: chewieController,
              startValue: 0,
              endValue: duration,
              currentMode: EditingMode.none,
            ));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // State Update Methods
  void setMode(EditingMode mode) {
    _updateState((state) => state.copyWith(currentMode: mode));
  }

  void updateStartValue(double value) {
    _updateState((state) => state.copyWith(startValue: value));
  }

  void updateEndValue(double value) {
    _updateState((state) => state.copyWith(endValue: value));
  }

  void updatePlaybackState(bool isPlaying) {
    _updateState((state) => state.copyWith(isPlaying: isPlaying));
  }

  void updateFilter(FilterOption filter) {
    _updateState((state) => state.copyWith(selectedFilter: filter));
    applyFilters();
  }

  void updateBrightness(double value) {
    _updateState((state) => state.copyWith(brightness: value));
  }

  Future<void> muteAllAudio() async {
    debugPrint('🔇 Muting all audio sources');

    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.videoPlayerController != null) {
      await _ensureControllersMuted(currentState.videoPlayerController!);
    }

    if (currentState.chewieController != null) {
      currentState.chewieController!.setVolume(0);
    }

    await ref.read(audioPlayerControllerProvider.notifier).muteEverything();
    debugPrint('🔇 All audio sources muted');
  }
}
