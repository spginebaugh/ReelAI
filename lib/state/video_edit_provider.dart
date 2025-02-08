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
        state.chewieController?.dispose();
        state.videoPlayerController?.dispose();
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

  Future<void> initializeVideo(Video video) async {
    if (state.value?.isInitialized ?? false) return;

    state = const AsyncValue.loading();

    try {
      debugPrint('🎥 VideoEdit: Starting video initialization');

      // Download and save the original video
      final tempFile = await _videoService.downloadVideo(video.videoUrl);
      debugPrint('🎥 VideoEdit: Video downloaded to temp file');

      // Initialize video player with completely disabled audio
      debugPrint('🎥 VideoEdit: Creating video player with disabled audio');
      final videoPlayerController = VideoPlayerController.file(
        tempFile,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Allow mixing with our audio track
        ),
      );

      // Initialize and ensure audio is disabled
      debugPrint('🎥 VideoEdit: Initializing video player');
      await videoPlayerController.initialize();
      debugPrint('🎥 VideoEdit: Setting volume to 0');
      await videoPlayerController.setVolume(0);

      // Double-check volume is 0
      if (videoPlayerController.value.volume > 0) {
        debugPrint(
            '⚠️ VideoEdit: Volume not 0 after initialization, forcing mute');
        await videoPlayerController.setVolume(0);
        // Verify mute worked
        if (videoPlayerController.value.volume > 0) {
          throw Exception('Failed to mute video player');
        }
      }

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
        debugPrint('🎥 VideoEdit: Got subtitle URL: $subtitleUrl');
      } catch (e) {
        debugPrint('⚠️ VideoEdit: No subtitles found: $e');
      }

      debugPrint('🎥 VideoEdit: Creating Chewie controller with muted audio');
      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
        allowMuting: false, // Prevent user from unmuting
        showControls: true,
        showOptions: false, // Hide additional options
        showControlsOnInitialize: false,
        isLive: false,
        allowFullScreen: true,
      );

      final duration = await _videoService.getVideoDuration(tempFile);
      debugPrint('🎥 VideoEdit: Controllers initialized');

      // First update state with the initialized video controllers
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
      debugPrint('🎥 VideoEdit: State updated with initialized controllers');

      // Verify volume is still 0 after state update
      if (videoPlayerController.value.volume > 0) {
        debugPrint(
            '⚠️ VideoEdit: Volume changed after state update, re-muting');
        await videoPlayerController.setVolume(0);
      }

      // Now initialize the audio player with the initialized video controller
      debugPrint('🎥 VideoEdit: Initializing audio player');
      try {
        await ref
            .read(audioPlayerControllerProvider.notifier)
            .initialize(videoPlayerController);
        debugPrint('🎥 VideoEdit: Audio player initialized');

        // Set up the initial English audio
        debugPrint('🎥 VideoEdit: Setting initial English audio');
        await ref
            .read(audioPlayerControllerProvider.notifier)
            .switchLanguage(video.id, 'english');
        debugPrint('✅ VideoEdit: Video initialization complete');

        // Final volume check
        if (videoPlayerController.value.volume > 0) {
          debugPrint(
              '⚠️ VideoEdit: Volume changed after audio setup, re-muting');
          await videoPlayerController.setVolume(0);
        }

        // Initialize subtitle system if subtitles are available
        if (subtitleUrl != null) {
          debugPrint('🎥 VideoEdit: Initializing subtitle system');
          await ref
              .read(subtitleControllerProvider.notifier)
              .initialize(videoPlayerController, subtitleUrl);

          // Load available subtitle languages
          await ref
              .read(subtitleControllerProvider.notifier)
              .loadAvailableLanguages(video.id, user.uid);

          debugPrint('✅ VideoEdit: Subtitle system initialized');
        }
      } catch (e) {
        debugPrint('❌ VideoEdit: Error initializing audio/subtitles: $e');
        rethrow;
      }
    } catch (e) {
      debugPrint('❌ VideoEdit: Error initializing video: $e');
      state = AsyncValue.error(e, StackTrace.current);
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

      // Initialize new video controller
      final videoPlayerController = VideoPlayerController.file(
        File(filteredPath),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true, // Allow mixing with our audio track
        ),
      );

      // Initialize and verify muted
      await videoPlayerController.initialize();
      await videoPlayerController.setVolume(0);
      if (videoPlayerController.value.volume > 0) {
        debugPrint('⚠️ VideoEdit: New filtered video not muted, forcing mute');
        await videoPlayerController.setVolume(0);
        if (videoPlayerController.value.volume > 0) {
          throw Exception('Failed to mute filtered video');
        }
      }

      // Create new Chewie controller with muted settings
      final newChewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
        allowMuting: false,
        showControls: true,
        showOptions: false,
        showControlsOnInitialize: false,
        isLive: false,
        allowFullScreen: true,
      );

      state = AsyncValue.data(currentState.copyWith(
        currentPreviewPath: filteredPath,
        isProcessing: false,
        videoPlayerController: videoPlayerController,
        chewieController: newChewieController,
      ));

      // Verify volume is still 0 after state update
      if (videoPlayerController.value.volume > 0) {
        debugPrint(
            '⚠️ VideoEdit: Volume changed after filter update, re-muting');
        await videoPlayerController.setVolume(0);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> processVideo() async {
    final currentState = state.value;
    if (currentState == null || currentState.isProcessing) return;

    state = AsyncValue.data(currentState.copyWith(isProcessing: true));

    try {
      // Dispose of existing controllers
      currentState.chewieController?.dispose();
      currentState.videoPlayerController?.dispose();

      final outputPath = await _videoService.trimVideo(
        inputFile: currentState.tempVideoFile!,
        startValue: currentState.startValue,
        endValue: currentState.endValue,
      );

      if (outputPath != null) {
        // Initialize new controllers with the trimmed video
        final trimmedFile = File(outputPath);
        final videoPlayerController = VideoPlayerController.file(
          trimmedFile,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true, // Allow mixing with our audio track
          ),
        );

        // Initialize and verify muted
        await videoPlayerController.initialize();
        await videoPlayerController.setVolume(0);
        if (videoPlayerController.value.volume > 0) {
          debugPrint('⚠️ VideoEdit: New trimmed video not muted, forcing mute');
          await videoPlayerController.setVolume(0);
          if (videoPlayerController.value.volume > 0) {
            throw Exception('Failed to mute trimmed video');
          }
        }

        // Create new Chewie controller with muted settings
        final chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: false,
          allowMuting: false,
          showControls: true,
          showOptions: false,
          showControlsOnInitialize: false,
          isLive: false,
          allowFullScreen: true,
        );

        final duration = await _videoService.getVideoDuration(trimmedFile);

        // Clean up the old temp file
        await _videoService.cleanup([currentState.tempVideoFile?.path]);

        state = AsyncValue.data(currentState.copyWith(
          processedVideoPath: outputPath,
          isProcessing: false,
          tempVideoFile: trimmedFile,
          videoPlayerController: videoPlayerController,
          chewieController: chewieController,
          startValue: 0,
          endValue: duration,
          currentMode: EditingMode.none,
        ));

        // Verify volume is still 0 after state update
        if (videoPlayerController.value.volume > 0) {
          debugPrint(
              '⚠️ VideoEdit: Volume changed after trim update, re-muting');
          await videoPlayerController.setVolume(0);
        }
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

  /// Test function to mute all audio sources
  Future<void> muteAllAudio() async {
    debugPrint('🔇 VideoEdit: Muting all audio sources');

    final currentState = state.value;
    if (currentState == null) return;

    // Mute video player
    if (currentState.videoPlayerController != null) {
      debugPrint('🔇 VideoEdit: Muting video player');
      await currentState.videoPlayerController!.setVolume(0);
    }

    // Mute chewie controller
    if (currentState.chewieController != null) {
      debugPrint('🔇 VideoEdit: Muting chewie controller');
      currentState.chewieController!.setVolume(0);
    }

    // Mute audio player
    debugPrint('🔇 VideoEdit: Muting audio player via provider');
    await ref.read(audioPlayerControllerProvider.notifier).muteEverything();

    debugPrint('🔇 VideoEdit: All audio sources should now be muted');
  }
}
