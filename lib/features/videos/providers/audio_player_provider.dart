import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:reel_ai/common/utils/storage_paths.dart';
import 'package:reel_ai/common/utils/json_utils.dart';
import 'package:reel_ai/common/utils/logger.dart';
import 'package:reel_ai/features/auth/providers/auth_provider.dart';
import 'package:reel_ai/features/videos/services/media/video_media_service.dart';
import 'audio_language_provider.dart';
import 'video_media_provider.dart';

part 'audio_player_provider.g.dart';
part 'audio_player_provider.freezed.dart';

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState({
    @JsonKey(toJson: _audioPlayerToJson, fromJson: _audioPlayerFromJson)
    AudioPlayer? audioPlayer,
    @Default(false) bool isInitialized,
    @Default(false) bool isPlaying,
    @JsonKey(toJson: _durationToJson, fromJson: _durationFromJson)
    @Default(Duration.zero)
    Duration position,
    @Default('english') String currentLanguage,
    @Default(false) bool isSyncing,
  }) = _AudioPlayerState;

  factory AudioPlayerState.fromJson(Map<String, dynamic> json) =>
      _$AudioPlayerStateFromJson(json);
}

// Helper functions for Duration serialization
int _durationToJson(Duration duration) => duration.inMilliseconds;
Duration _durationFromJson(int milliseconds) =>
    Duration(milliseconds: milliseconds);

// Helper functions for AudioPlayer serialization
AudioPlayer? _audioPlayerFromJson(dynamic _) => null;
dynamic _audioPlayerToJson(AudioPlayer? _) => null;

/// Provider that manages audio playback and synchronization with video
@Riverpod(keepAlive: true)
class AudioPlayerController extends _$AudioPlayerController {
  VideoPlayerController? _videoController;
  VideoMediaService get _mediaService => ref.read(videoMediaProvider);

  @override
  AudioPlayerState build() {
    ref.onDispose(() {
      Logger.debug('AudioPlayer: Provider disposing');
      dispose();
    });
    return const AudioPlayerState();
  }

  Future<void> initialize(VideoPlayerController videoController) async {
    Logger.debug('AudioPlayer: Initializing with video controller');

    if (!videoController.value.isInitialized) {
      Logger.error('Video controller must be initialized first');
      throw Exception('Video controller must be initialized first');
    }

    try {
      // Clean up existing resources
      Logger.debug('AudioPlayer: Cleaning up existing resources');
      await dispose();

      // Create new audio player
      Logger.debug('AudioPlayer: Creating new audio player');
      final audioPlayer = AudioPlayer();

      // Set up video controller
      Logger.debug('AudioPlayer: Setting up video controller');
      _videoController = videoController;
      await _mediaService.ensureVideoMuted(videoController);

      Logger.debug('AudioPlayer: Configuring audio player settings');
      await audioPlayer.setVolume(1.0);
      await audioPlayer.setLoopMode(LoopMode.off);

      // Update state
      state = state.copyWith(
        audioPlayer: audioPlayer,
        isInitialized: true,
        isPlaying: false,
        position: Duration.zero,
        currentLanguage: 'english',
      );

      // Set up listeners
      _videoController!.addListener(_onVideoPositionChanged);
      _videoController!.addListener(_onVideoPlayStateChanged);

      Logger.success('AudioPlayer: Initialization complete');
    } catch (e) {
      Logger.error(
          'AudioPlayer: Initialization failed', {'error': e.toString()});
      await dispose();
      rethrow;
    }
  }

  Future<void> switchLanguage(String videoId, String language) async {
    if (state.isSyncing) {
      Logger.debug('AudioPlayer: Already syncing, ignoring request');
      return;
    }

    if (!state.isInitialized || state.audioPlayer == null) {
      Logger.error('Audio player not initialized');
      throw Exception(
          'Audio player must be initialized before switching languages');
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      Logger.error('No valid video controller');
      throw Exception('Video controller not initialized');
    }

    try {
      Logger.debug('AudioPlayer: Starting language switch', {
        'language': language,
        'videoId': videoId,
      });

      state = state.copyWith(isSyncing: true);

      // Store current playback state
      final wasPlaying = _videoController!.value.isPlaying;
      final currentPosition = _videoController!.value.position;

      // Get the current user
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) {
        Logger.error('No authenticated user found');
        state = state.copyWith(isSyncing: false);
        throw Exception('User must be authenticated to switch languages');
      }

      // Get audio URL and stop current playback
      final audioUrl = await _mediaService.fetchMediaUrl(
        userId: user.uid,
        videoId: videoId,
        type: 'audio',
        language: language,
        format: 'mp3',
      );

      // Stop current playback
      await state.audioPlayer!.stop();

      // Set up new audio
      await state.audioPlayer!.setUrl(audioUrl);
      await state.audioPlayer!.setVolume(1.0);

      // Sync positions
      await _mediaService.syncAudioVideo(
        videoController: _videoController!,
        audioPlayer: state.audioPlayer!,
        targetPosition: currentPosition,
      );

      // Update state
      state = state.copyWith(
        currentLanguage: language,
        isInitialized: true,
        isSyncing: false,
        position: currentPosition,
        isPlaying: false,
      );

      // Resume if needed
      if (wasPlaying) {
        await _mediaService.updatePlaybackState(
          videoController: _videoController!,
          audioPlayer: state.audioPlayer!,
          shouldPlay: true,
        );
        state = state.copyWith(isPlaying: true);
      }

      // Ensure video is still muted
      await _mediaService.ensureVideoMuted(_videoController!);

      // Update language provider
      ref.read(currentLanguageProvider(videoId).notifier).setLanguage(language);

      Logger.success('AudioPlayer: Successfully switched to $language audio');
    } catch (e) {
      Logger.error(
          'AudioPlayer: Language switch failed', {'error': e.toString()});
      state = state.copyWith(isSyncing: false);
      rethrow;
    }
  }

  void _onVideoPositionChanged() {
    if (_videoController == null ||
        !_videoController!.value.isPlaying ||
        !state.isInitialized) return;

    final videoPosition = _videoController!.value.position;
    final audioPosition = state.audioPlayer?.position ?? Duration.zero;

    // If the difference is more than 50ms, sync the audio
    if ((videoPosition - audioPosition).abs() >
        const Duration(milliseconds: 50)) {
      Logger.debug('AudioPlayer: Syncing position', {
        'video': videoPosition.inMilliseconds,
        'audio': audioPosition.inMilliseconds,
      });

      state.audioPlayer?.seek(videoPosition);
      state = state.copyWith(position: videoPosition);
    }
  }

  void _onVideoPlayStateChanged() {
    if (_videoController == null || !state.isInitialized) return;

    final isVideoPlaying = _videoController!.value.isPlaying;
    final audioPlayer = state.audioPlayer;

    if (audioPlayer == null) {
      Logger.warning('AudioPlayer is null when handling play state change');
      return;
    }

    if (isVideoPlaying && !state.isPlaying) {
      Logger.debug('AudioPlayer: Starting playback');
      _mediaService
          .updatePlaybackState(
        videoController: _videoController!,
        audioPlayer: audioPlayer,
        shouldPlay: true,
      )
          .then((_) {
        state = state.copyWith(isPlaying: true);
      }).catchError((error) {
        Logger.error('Failed to start playback', {'error': error.toString()});
      });
    } else if (!isVideoPlaying && state.isPlaying) {
      Logger.debug('AudioPlayer: Pausing playback');
      _mediaService
          .updatePlaybackState(
        videoController: _videoController!,
        audioPlayer: audioPlayer,
        shouldPlay: false,
      )
          .then((_) {
        state = state.copyWith(isPlaying: false);
      }).catchError((error) {
        Logger.error('Failed to pause playback', {'error': error.toString()});
      });
    }
  }

  Future<void> dispose() async {
    Logger.debug('AudioPlayer: Disposing resources');
    _videoController?.removeListener(_onVideoPositionChanged);
    _videoController?.removeListener(_onVideoPlayStateChanged);
    await state.audioPlayer?.dispose();
    _videoController = null;
    state = const AudioPlayerState();
    Logger.debug('AudioPlayer: Resources disposed');
  }
}
