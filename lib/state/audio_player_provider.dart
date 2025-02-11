import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/storage_paths.dart';
import '../utils/json_utils.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';
import 'audio_language_provider.dart';

part 'audio_player_provider.g.dart';
part 'audio_player_provider.freezed.dart';

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState({
    @JsonKey(toJson: toJsonSafe, fromJson: _audioPlayerFromJson)
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

// Helper function for AudioPlayer deserialization
AudioPlayer? _audioPlayerFromJson(dynamic _) => null;

/// Provider that manages audio playback and synchronization with video
@Riverpod(keepAlive: true)
class AudioPlayerController extends _$AudioPlayerController {
  VideoPlayerController? _videoController;

  @override
  AudioPlayerState build() {
    ref.onDispose(() {
      debugPrint('🎵 AudioPlayer: Provider disposing');
      dispose();
    });

    return const AudioPlayerState();
  }

  /// Initialize the audio player with a video controller for sync
  Future<void> initialize(VideoPlayerController videoController) async {
    debugPrint('🎵 AudioPlayer: Initializing with video controller');

    if (videoController.value.isInitialized == false) {
      debugPrint('❌ AudioPlayer: Video controller must be initialized first');
      throw Exception('Video controller must be initialized first');
    }

    try {
      // Clean up any existing resources
      debugPrint('🎵 AudioPlayer: Cleaning up existing resources');
      await dispose(); // This will handle all cleanup

      // Create new audio player
      debugPrint('🎵 AudioPlayer: Creating new audio player');
      final audioPlayer = AudioPlayer();

      // Set up video controller
      debugPrint('🎵 AudioPlayer: Setting up video controller');
      _videoController = videoController;
      await _ensureVideoMuted();

      debugPrint('🎵 AudioPlayer: Configuring audio player settings');
      await audioPlayer.setVolume(1.0); // Maximum volume for audio player
      await audioPlayer.setLoopMode(LoopMode.off);

      // Update state with new audio player
      debugPrint('🎵 AudioPlayer: Updating state');
      state = state.copyWith(
        audioPlayer: audioPlayer,
        isInitialized: true,
        isPlaying: false,
        position: Duration.zero,
        currentLanguage: 'english', // Set default language to english
      );

      // Set up listeners
      debugPrint('🎵 AudioPlayer: Setting up video controller listeners');
      _videoController!.addListener(_onVideoPositionChanged);
      _videoController!.addListener(_onVideoPlayStateChanged);
      _videoController!.addListener(_onVideoVolumeChanged);

      debugPrint('✅ AudioPlayer: Initialization complete');
    } catch (e) {
      debugPrint('❌ AudioPlayer: Initialization failed: $e');
      // Clean up on failure
      await dispose();
      rethrow;
    }
  }

  /// Ensures the video player's audio is always muted
  Future<void> _ensureVideoMuted() async {
    if (_videoController == null) return;

    debugPrint('🎵 AudioPlayer: Ensuring video is completely muted');

    // Force mute the video player multiple ways
    await _videoController!.setVolume(0);
    await _videoController!.setPlaybackSpeed(_videoController!
        .value.playbackSpeed); // Reset speed to ensure audio state

    // Verify mute took effect
    if (_videoController!.value.volume > 0) {
      debugPrint('⚠️ AudioPlayer: Video not muted, retrying aggressively...');
      // Try multiple times with different approaches
      await Future.wait([
        _videoController!.setVolume(0),
        _videoController!
            .setPlaybackSpeed(_videoController!.value.playbackSpeed),
      ]);

      // Final verification
      if (_videoController!.value.volume > 0) {
        debugPrint(
            '❌ AudioPlayer: Failed to mute video after multiple attempts');
        throw Exception('Failed to mute video audio track');
      }
    }
    debugPrint('✅ AudioPlayer: Video completely muted');
  }

  /// Listener for video volume changes to ensure it stays muted
  void _onVideoVolumeChanged() {
    if (_videoController == null) return;

    // If volume somehow got changed, mute it aggressively
    if (_videoController!.value.volume > 0) {
      debugPrint('⚠️ AudioPlayer: Video volume changed, re-muting...');
      _videoController!.setVolume(0);
      _videoController!.setPlaybackSpeed(_videoController!.value.playbackSpeed);
    }
  }

  /// Switch to a different audio language
  Future<void> switchLanguage(String videoId, String language) async {
    debugPrint('');
    debugPrint('🚨 [AUDIO_DEBUG] ========================================');
    debugPrint('🚨 [AUDIO_DEBUG] Starting switchLanguage');
    debugPrint('🚨 [AUDIO_DEBUG] Params:');
    debugPrint('🚨 [AUDIO_DEBUG] - videoId: $videoId');
    debugPrint('🚨 [AUDIO_DEBUG] - language: $language');
    debugPrint('🚨 [AUDIO_DEBUG] ========================================');
    debugPrint('');

    if (state.isSyncing) {
      debugPrint('🚨 [AUDIO_DEBUG] Already syncing, ignoring request');
      return;
    }

    if (!state.isInitialized || state.audioPlayer == null) {
      debugPrint('🚨 [AUDIO_DEBUG] Audio player not initialized');
      throw Exception(
          'Audio player must be initialized before switching languages');
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      debugPrint('🚨 [AUDIO_DEBUG] No valid video controller');
      throw Exception('Video controller not initialized');
    }

    try {
      debugPrint('🚨 [AUDIO_DEBUG] Starting language switch process');
      state = state.copyWith(isSyncing: true);

      // Store current video state
      final wasPlaying = _videoController!.value.isPlaying;
      final currentPosition = _videoController!.value.position;
      debugPrint('🚨 [AUDIO_DEBUG] Current state:');
      debugPrint('🚨 [AUDIO_DEBUG] - wasPlaying: $wasPlaying');
      debugPrint('🚨 [AUDIO_DEBUG] - position: $currentPosition');

      // Get the current user
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) {
        debugPrint('🚨 [AUDIO_DEBUG] No authenticated user found');
        state = state.copyWith(isSyncing: false);
        throw Exception('User must be authenticated to switch languages');
      }
      debugPrint('🚨 [AUDIO_DEBUG] Found user: ${user.uid}');

      // Get audio URL using StoragePaths
      final storage = FirebaseStorage.instance;
      final audioPath = StoragePaths.audioFile(
        user.uid,
        videoId,
        lang: language,
        ext: 'mp3',
      );

      debugPrint('');
      debugPrint('🚨 [AUDIO_DEBUG] ========================================');
      debugPrint('🚨 [AUDIO_DEBUG] ATTEMPTING TO DOWNLOAD AUDIO');
      debugPrint('🚨 [AUDIO_DEBUG] Relative path: $audioPath');
      debugPrint(
          '🚨 [AUDIO_DEBUG] Full storage URL: gs://reel-ai-cd001.appspot.com/$audioPath');
      debugPrint('🚨 [AUDIO_DEBUG] ========================================');
      debugPrint('');

      late final String audioUrl;
      try {
        audioUrl = await storage.ref(audioPath).getDownloadURL();
        Logger.audio('Successfully retrieved audio URL', {
          'audioUrl': audioUrl,
          'path': audioPath,
        });
        debugPrint('🎵 AudioPlayer: Loading audio from URL: $audioUrl');
      } catch (e) {
        Logger.error('Failed to get audio download URL', {
          'error': e.toString(),
          'path': audioPath,
          'userId': user.uid,
          'videoId': videoId,
          'language': language,
        });
        state = state.copyWith(isSyncing: false);
        rethrow;
      }

      // Reset positions and load new audio
      await state.audioPlayer!.stop();

      try {
        await state.audioPlayer!.setUrl(audioUrl);
      } catch (e) {
        debugPrint('❌ AudioPlayer: Failed to load audio URL: $e');
        state = state.copyWith(isSyncing: false);
        rethrow;
      }

      // Set up audio player
      await state.audioPlayer!.setVolume(1.0);
      final duration = await state.audioPlayer!.duration;
      if (duration == null) {
        state = state.copyWith(isSyncing: false);
        throw Exception('Failed to load audio file');
      }

      // Seek both to the current position
      await Future.wait([
        _videoController!.seekTo(currentPosition),
        state.audioPlayer!.seek(currentPosition),
      ]);

      // Update state
      state = state.copyWith(
        currentLanguage: language,
        isInitialized: true,
        isSyncing: false,
        position: currentPosition,
        isPlaying: false,
      );

      // Resume playback if it was playing before
      if (wasPlaying) {
        await state.audioPlayer!.play();
        await Future.delayed(const Duration(milliseconds: 50));
        await _videoController!.play();
        state = state.copyWith(isPlaying: true);
      }

      // Double check video is still muted
      await _ensureVideoMuted();

      // Update language provider
      ref.read(currentLanguageProvider(videoId).notifier).setLanguage(language);
    } catch (e) {
      debugPrint('❌ AudioPlayer: Language switch failed: $e');
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
      debugPrint(
          '🎵 AudioPlayer: Syncing position - Video: ${videoPosition.inMilliseconds}ms, Audio: ${audioPosition.inMilliseconds}ms');
      state.audioPlayer?.seek(videoPosition);
      state = state.copyWith(position: videoPosition);
    }
  }

  void _onVideoPlayStateChanged() {
    if (_videoController == null || !state.isInitialized) return;

    final isVideoPlaying = _videoController!.value.isPlaying;
    debugPrint(
        '🎵 AudioPlayer: Video play state changed - Playing: $isVideoPlaying');

    if (isVideoPlaying && !state.isPlaying) {
      debugPrint('🎵 AudioPlayer: Starting audio playback');
      final audioPlayer = state.audioPlayer;
      if (audioPlayer == null) {
        debugPrint('❌ AudioPlayer: Audio player is null when trying to play');
        return;
      }

      debugPrint('🎵 AudioPlayer: Current volume: ${audioPlayer.volume}');
      debugPrint('🎵 AudioPlayer: Current position: ${audioPlayer.position}');
      debugPrint('🎵 AudioPlayer: Is playing: ${audioPlayer.playing}');

      audioPlayer.play().then((_) {
        debugPrint('✅ AudioPlayer: Play command sent successfully');
        debugPrint('🎵 AudioPlayer: New volume: ${audioPlayer.volume}');
        debugPrint('🎵 AudioPlayer: Is now playing: ${audioPlayer.playing}');
      }).catchError((error) {
        debugPrint('❌ AudioPlayer: Failed to start playback: $error');
      });

      state = state.copyWith(isPlaying: true);
    } else if (!isVideoPlaying && state.isPlaying) {
      debugPrint('🎵 AudioPlayer: Pausing audio playback');
      final audioPlayer = state.audioPlayer;
      if (audioPlayer == null) {
        debugPrint('❌ AudioPlayer: Audio player is null when trying to pause');
        return;
      }

      audioPlayer.pause().then((_) {
        debugPrint('✅ AudioPlayer: Pause command sent successfully');
      }).catchError((error) {
        debugPrint('❌ AudioPlayer: Failed to pause playback: $error');
      });

      state = state.copyWith(
        isPlaying: false,
        isInitialized: state.isInitialized,
        audioPlayer: state.audioPlayer,
        position: state.position,
        currentLanguage: state.currentLanguage,
      );
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    debugPrint('🎵 AudioPlayer: Disposing resources');
    _videoController?.removeListener(_onVideoPositionChanged);
    _videoController?.removeListener(_onVideoPlayStateChanged);
    _videoController?.removeListener(_onVideoVolumeChanged);
    await state.audioPlayer?.dispose();
    _videoController = null;
    state = const AudioPlayerState();
    debugPrint('✅ AudioPlayer: Resources disposed');
  }

  /// Test function to completely mute all audio
  Future<void> muteEverything() async {
    debugPrint('🔇 AudioPlayer: MUTING ALL AUDIO SOURCES');

    // Mute video player if it exists
    if (_videoController != null) {
      debugPrint('🔇 AudioPlayer: Muting video player');
      await _videoController!.setVolume(0);
      if (_videoController!.value.volume > 0) {
        debugPrint('⚠️ AudioPlayer: Video still not muted, trying again');
        await _videoController!.setVolume(0);
      }
    }

    // Mute audio player if it exists
    if (state.audioPlayer != null) {
      debugPrint('🔇 AudioPlayer: Muting just_audio player');
      await state.audioPlayer!.setVolume(0);

      // Verify audio player is muted
      if (state.audioPlayer!.volume > 0) {
        debugPrint(
            '⚠️ AudioPlayer: Audio player still not muted, trying again');
        await state.audioPlayer!.setVolume(0);
      }
    }

    debugPrint('🔇 AudioPlayer: All audio sources should now be muted');
  }
}
