import 'dart:io';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/video.dart';
import '../models/video_edit_state.dart';
import '../models/filter_option.dart';
import '../services/video_processing_service.dart';
import '../utils/storage_paths.dart';
import '../utils/json_utils.dart';
import 'auth_provider.dart';
import 'audio_player_provider.dart';
import 'subtitle_controller.dart';
import 'package:flutter/foundation.dart';
import 'video_controller_provider.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

part 'video_edit_provider.g.dart';

@riverpod
class VideoEditController extends _$VideoEditController {
  VideoProcessingService get _videoService => VideoProcessingService();

  @override
  Future<VideoEditState> build() async {
    ref.onDispose(() {
      state.whenData((state) {
        Logger.state('Disposing video edit state');
        ref.read(videoControllerManagerProvider).disposeControllers(
              videoPlayerController: state.videoPlayerController,
              chewieController: state.chewieController,
            );
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

  void _updateState(VideoEditState Function(VideoEditState) updater) {
    state.whenData((currentState) {
      state = AsyncValue.data(updater(currentState));

      // Verify muting after state update
      if (currentState.videoPlayerController != null) {
        ref
            .read(videoControllerManagerProvider)
            .verifyMuting(currentState.videoPlayerController);
      }
    });
  }

  Future<void> _cleanupPreviousFiles(List<String?> paths) async {
    for (final path in paths) {
      if (path != null) {
        try {
          await _videoService.cleanup([path]);
        } catch (e) {
          Logger.warning('Error cleaning up file', {'path': path, 'error': e});
        }
      }
    }
  }

  // Initialize Video System
  Future<void> _initializeVideoPlayer(File videoFile) async {
    Logger.video('Initializing video player system', {'path': videoFile.path});

    final (videoPlayerController, chewieController) = await ref
        .read(videoControllerManagerProvider)
        .createAndVerifyControllers(videoFile);

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

    Logger.success('Video player initialized successfully');
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
      Logger.group('Video Initialization', () {
        Logger.video('Starting video initialization', {'videoId': video.id});
      });

      final tempFile = await _videoService.downloadVideo(video.videoUrl);

      // Log the state before initialization
      Logger.debug('State before initialization', {
        'tempFile': tempFile.path,
        'isInitialized': state.value?.isInitialized,
        'hasVideoController': state.value?.videoPlayerController != null,
        'hasChewieController': state.value?.chewieController != null,
      });

      try {
        await _initializeVideoPlayer(tempFile);
      } catch (e, st) {
        Logger.error('Failed to initialize video player', {
          'error': e.toString(),
          'stackTrace': st.toString(),
          'tempFile': tempFile.path,
        });
        rethrow;
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
        Logger.subtitle('Got subtitle URL', {'url': subtitleUrl});
      } catch (e) {
        Logger.warning('No subtitles found', {
          'error': e.toString(),
          'path': subtitlePath,
        });
      }

      // Initialize audio and subtitles
      final videoPlayerController = state.value!.videoPlayerController!;

      try {
        await _initializeAudioSystem(videoPlayerController, video.id);
      } catch (e, st) {
        Logger.error('Failed to initialize audio system', {
          'error': e.toString(),
          'stackTrace': st.toString(),
          'videoId': video.id,
        });
        rethrow;
      }

      if (subtitleUrl != null) {
        try {
          await _initializeSubtitleSystem(
            videoPlayerController,
            video.id,
            user.uid,
            subtitleUrl,
          );
        } catch (e, st) {
          Logger.error('Failed to initialize subtitle system', {
            'error': e.toString(),
            'stackTrace': st.toString(),
            'subtitleUrl': subtitleUrl,
          });
          rethrow;
        }
      }

      Logger.success('Video initialization completed successfully');
    } catch (e, st) {
      // Log the full state when error occurs
      try {
        final currentState = state.value;
        Logger.error('Video initialization failed - Current State', {
          'isProcessing': currentState?.isProcessing,
          'isLoading': currentState?.isLoading,
          'isPlaying': currentState?.isPlaying,
          'isInitialized': currentState?.isInitialized,
          'currentMode': currentState?.currentMode.toString(),
          'startValue': currentState?.startValue,
          'endValue': currentState?.endValue,
          'brightness': currentState?.brightness,
          'selectedFilter': currentState?.selectedFilter.toString(),
          'tempVideoFile': currentState?.tempVideoFile?.path,
          'currentPreviewPath': currentState?.currentPreviewPath,
          'processedVideoPath': currentState?.processedVideoPath,
          'hasVideoController': currentState?.videoPlayerController != null,
          'hasChewieController': currentState?.chewieController != null,
        });
      } catch (logError) {
        Logger.error('Failed to log state during error', {
          'logError': logError.toString(),
        });
      }

      if (e is JsonUnsupportedObjectError) {
        Logger.error('JSON Serialization Error Details', {
          'unsupportedObject': e.unsupportedObject?.runtimeType.toString(),
          'cause': e.cause,
          'stackTrace': st.toString(),
        });
      }

      final appError = ErrorHandler.handleError(e, st);
      Logger.error('Error initializing video', {
        'error': appError.toString(),
        'originalError': e.toString(),
        'errorType': e.runtimeType.toString(),
        'stackTrace': st.toString(),
      });
      state = AsyncValue.error(appError, st);
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
      Logger.group('Applying Filters', () {
        Logger.video('Starting filter application', {
          'filter': currentState.selectedFilter,
          'brightness': currentState.brightness,
        });
      });

      await _prepareFilterApplication(currentState);

      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final filteredPath = await _createFilteredVideo(currentState, outputPath);

      final (videoPlayerController, chewieController) = await ref
          .read(videoControllerManagerProvider)
          .createAndVerifyControllers(File(filteredPath));

      _updateState((state) => state.copyWith(
            currentPreviewPath: filteredPath,
            isProcessing: false,
            videoPlayerController: videoPlayerController,
            chewieController: chewieController,
          ));

      Logger.success('Filters applied successfully');
    } catch (e, st) {
      final appError = ErrorHandler.handleError(e, st);
      Logger.error('Error applying filters', {
        'error': appError.toString(),
        'originalError': e,
        'stackTrace': st,
      });
      state = AsyncValue.error(appError, st);
    }
  }

  Future<void> _prepareTrimming(VideoEditState currentState) async {
    ref.read(videoControllerManagerProvider).disposeControllers(
          videoPlayerController: currentState.videoPlayerController,
          chewieController: currentState.chewieController,
        );
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
        final (videoPlayerController, chewieController) = await ref
            .read(videoControllerManagerProvider)
            .createAndVerifyControllers(trimmedFile);

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
    Logger.audio('Muting all audio sources');

    final currentState = state.value;
    if (currentState == null) return;

    try {
      if (currentState.videoPlayerController != null) {
        await ref
            .read(videoControllerManagerProvider)
            .ensureControllersMuted(currentState.videoPlayerController!);
      }

      if (currentState.chewieController != null) {
        currentState.chewieController!.setVolume(0);
      }

      await ref.read(audioPlayerControllerProvider.notifier).muteEverything();
      Logger.success('All audio sources muted successfully');
    } catch (e, st) {
      final appError = ErrorHandler.handleError(e, st);
      Logger.error('Error muting audio', {
        'error': appError.toString(),
        'originalError': e,
        'stackTrace': st,
      });
      throw appError;
    }
  }
}
