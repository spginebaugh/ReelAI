import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/features/videos/models/video_edit_state.dart';
import 'package:reel_ai/features/videos/services/processing/video_processor.dart';
import 'package:reel_ai/features/auth/providers/auth_provider.dart';
import 'package:reel_ai/common/utils/logger.dart';
import 'package:reel_ai/features/videos/services/media/video_media_service.dart';
import 'audio_player_provider.dart';
import 'subtitle_controller.dart';
import 'video_controller_provider.dart';
import 'video_media_provider.dart';

part 'video_edit_provider.g.dart';

@riverpod
class VideoEditController extends _$VideoEditController {
  VideoProcessor get _videoService => VideoProcessor();
  VideoMediaService get _mediaService => ref.read(videoMediaProvider);

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

  Future<void> _initializeVideoPlayer(File videoFile) async {
    Logger.video('Initializing video player system', {'path': videoFile.path});

    final (videoPlayerController, chewieController) = await ref
        .read(videoControllerManagerProvider)
        .createAndVerifyControllers(videoFile);

    _updateState((currentState) => currentState.copyWith(
          status: VideoEditStatus.ready,
          currentMode: EditingMode.none,
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
    Logger.debug('Initializing audio system');
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
    String? subtitleUrl,
  ) async {
    Logger.debug('Initializing subtitle system');
    await ref
        .read(subtitleControllerProvider.notifier)
        .initialize(controller, subtitleUrl);

    await ref
        .read(subtitleControllerProvider.notifier)
        .loadAvailableLanguages(videoId, userId);
  }

  Future<void> initializeVideo(Video video) async {
    if (state.value?.status == VideoEditStatus.ready) return;

    state = AsyncValue.data(VideoEditState.initial().copyWith(
      status: VideoEditStatus.loading,
    ));

    try {
      Logger.group('Video Initialization', () {
        Logger.video('Starting video initialization', {'videoId': video.id});
      });

      // Get user
      final user = ref.read(authStateProvider).requireValue!;

      // Start all resource fetching in parallel
      Logger.debug('Starting parallel resource fetching', {
        'videoId': video.id,
        'userId': user.uid,
      });

      // 1. Start video download
      final videoDownloadFuture = _videoService.downloadVideo(video.videoUrl);

      // 2. Start subtitle URL fetch
      final subtitleUrlFuture = _mediaService
          .fetchMediaUrl(
        userId: user.uid,
        videoId: video.id,
        type: 'subtitles',
        format: 'vtt',
      )
          .catchError((e) {
        Logger.warning('No subtitles found', {'error': e.toString()});
        return null;
      });

      // 3. Start audio URL fetch
      final audioUrlFuture = _mediaService
          .fetchMediaUrl(
        userId: user.uid,
        videoId: video.id,
        type: 'audio',
        format: 'mp3',
      )
          .catchError((e) {
        Logger.warning('No audio found', {'error': e.toString()});
        return null;
      });

      // Wait for video download to complete first (we need this to proceed)
      Logger.debug('Waiting for video download to complete');
      final videoFile = await videoDownloadFuture;

      // Initialize video player
      Logger.debug('Initializing video player');
      try {
        await _initializeVideoPlayer(videoFile);
      } catch (e, st) {
        Logger.error('Failed to initialize video player', {
          'error': e.toString(),
          'stackTrace': st.toString(),
          'tempFile': videoFile.path,
        });
        state = AsyncValue.data(state.value!.copyWith(
          status: VideoEditStatus.error,
          errorMessage: 'Failed to initialize video player: ${e.toString()}',
        ));
        rethrow;
      }

      // Get the initialized video controller
      final videoPlayerController = state.value!.videoPlayerController!;

      // Wait for remaining resources and initialize systems in parallel
      Logger.debug('Waiting for remaining resources and initializing systems');
      try {
        await Future.wait([
          // Wait for subtitle URL and initialize subtitles
          subtitleUrlFuture.then((subtitleUrl) async {
            if (subtitleUrl != null) {
              try {
                Logger.subtitle('Got subtitle URL', {'url': subtitleUrl});
                await _initializeSubtitleSystem(
                  videoPlayerController,
                  video.id,
                  user.uid,
                  subtitleUrl,
                );
              } catch (e) {
                Logger.warning(
                    'Failed to initialize subtitles', {'error': e.toString()});
                // Don't rethrow - allow video to continue without subtitles
              }
            }
          }).catchError((e) {
            Logger.warning(
                'Error processing subtitles', {'error': e.toString()});
            // Don't rethrow - allow video to continue without subtitles
          }),

          // Wait for audio URL and initialize audio
          audioUrlFuture.then((audioUrl) async {
            if (audioUrl != null) {
              try {
                Logger.audio('Got audio URL', {'url': audioUrl});
                await _initializeAudioSystem(videoPlayerController, video.id);
              } catch (e) {
                Logger.warning(
                    'Failed to initialize audio', {'error': e.toString()});
                // Don't rethrow - allow video to continue without audio
              }
            }
          }).catchError((e) {
            Logger.warning('Error processing audio', {'error': e.toString()});
            // Don't rethrow - allow video to continue without audio
          }),
        ]);
      } catch (e) {
        // Log the error but don't fail video initialization
        Logger.warning(
            'Error initializing additional resources', {'error': e.toString()});
      }

      // If we get here, video is ready even if subtitles/audio failed
      if (state.value?.status != VideoEditStatus.error) {
        _updateState((currentState) => currentState.copyWith(
              status: VideoEditStatus.ready,
            ));
      }

      Logger.success('Video initialization completed');
    } catch (e, st) {
      Logger.error('Video initialization failed', {
        'error': e.toString(),
        'stackTrace': st.toString(),
      });
      state = AsyncValue.error(e, st);
    }
  }

  void setMode(EditingMode mode) {
    _updateState((state) => state.copyWith(currentMode: mode));
  }

  void togglePlayback() {
    _updateState((currentState) {
      if (currentState.status == VideoEditStatus.playing) {
        currentState.videoPlayerController?.pause();
        return currentState.copyWith(status: VideoEditStatus.ready);
      } else if (currentState.status == VideoEditStatus.ready) {
        currentState.videoPlayerController?.play();
        return currentState.copyWith(status: VideoEditStatus.playing);
      }
      return currentState;
    });
  }
}
