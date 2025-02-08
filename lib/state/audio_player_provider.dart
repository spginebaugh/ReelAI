import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../utils/storage_paths.dart';
import 'auth_provider.dart';
import 'audio_language_provider.dart';

part 'audio_player_provider.g.dart';

/// State class for audio player
class AudioPlayerState {
  final AudioPlayer? audioPlayer;
  final bool isInitialized;
  final bool isPlaying;
  final Duration position;
  final String currentLanguage;
  final bool isSyncing;

  const AudioPlayerState({
    this.audioPlayer,
    this.isInitialized = false,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.currentLanguage = 'english',
    this.isSyncing = false,
  });

  AudioPlayerState copyWith({
    AudioPlayer? audioPlayer,
    bool? isInitialized,
    bool? isPlaying,
    Duration? position,
    String? currentLanguage,
    bool? isSyncing,
  }) {
    return AudioPlayerState(
      audioPlayer: audioPlayer ?? this.audioPlayer,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

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
        currentLanguage: 'portuguese', // Set default language to Portuguese
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
    debugPrint('🎵 AudioPlayer: Attempting to switch language to: $language');

    if (state.isSyncing) {
      debugPrint('🎵 AudioPlayer: Already syncing, ignoring request');
      return;
    }

    if (!state.isInitialized || state.audioPlayer == null) {
      debugPrint('❌ AudioPlayer: Audio player not initialized');
      throw Exception(
          'Audio player must be initialized before switching languages');
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      debugPrint('❌ AudioPlayer: No valid video controller available');
      throw Exception('Video controller not initialized');
    }

    try {
      debugPrint('🎵 AudioPlayer: Starting language switch process');
      state = state.copyWith(isSyncing: true);

      // Ensure video is muted before proceeding
      await _ensureVideoMuted();

      // Store current video state
      final wasPlaying = _videoController!.value.isPlaying;
      final currentPosition = _videoController!.value.position;
      debugPrint('🎵 AudioPlayer: Current video playing state: $wasPlaying');
      debugPrint(
          '🎵 AudioPlayer: Current position: ${currentPosition.inMilliseconds}ms');

      // Pause everything
      debugPrint('🎵 AudioPlayer: Pausing playback');
      await _videoController!.pause();
      await state.audioPlayer!.pause();

      debugPrint(
          '🎵 AudioPlayer: Getting audio file path for language: $language');
      final storage = FirebaseStorage.instance;
      final userId = ref.read(authStateProvider).requireValue!.uid;
      final audioPath = StoragePaths.audioFile(
        userId,
        videoId,
        lang: language,
        ext: 'mp3',
      );
      debugPrint('🎵 AudioPlayer: Audio path: $audioPath');

      debugPrint('🎵 AudioPlayer: Verifying audio file exists');
      try {
        await storage.ref(audioPath).getMetadata();
      } catch (e) {
        debugPrint('❌ AudioPlayer: Audio file not found: $e');
        throw Exception('Audio file not found for language: $language');
      }

      debugPrint('🎵 AudioPlayer: Getting download URL');
      final audioUrl = await storage.ref(audioPath).getDownloadURL();
      debugPrint(
          '🎵 AudioPlayer: Got audio URL: ${audioUrl.substring(0, 50)}...');

      // Reset positions and load new audio
      debugPrint('🎵 AudioPlayer: Loading new audio');
      await state.audioPlayer!.stop();
      debugPrint(
          '🎵 AudioPlayer: Loading URL: ${audioUrl.substring(0, 50)}...');
      try {
        await state.audioPlayer!.setUrl(audioUrl);
        debugPrint('✅ AudioPlayer: Audio URL loaded successfully');
      } catch (e) {
        debugPrint('❌ AudioPlayer: Failed to load audio URL: $e');
        rethrow;
      }

      // Ensure audio player is ready with high volume
      debugPrint('🎵 AudioPlayer: Setting up audio player with high volume');
      await state.audioPlayer!.setVolume(1.0); // Maximum volume
      final duration = await state.audioPlayer!.duration;
      debugPrint(
          '🎵 AudioPlayer: Audio duration: ${duration?.inMilliseconds}ms');
      if (duration == null) {
        debugPrint('❌ AudioPlayer: Audio duration is null after loading');
        throw Exception('Failed to load audio file');
      }

      // Seek both to the current position
      debugPrint('🎵 AudioPlayer: Seeking to current position');
      await Future.wait([
        _videoController!.seekTo(currentPosition),
        state.audioPlayer!.seek(currentPosition),
      ]);

      // Update state
      debugPrint('🎵 AudioPlayer: Updating state');
      state = state.copyWith(
        currentLanguage: language,
        isInitialized: true,
        isSyncing: false,
        position: currentPosition,
        isPlaying: false,
      );

      // Resume playback if it was playing before
      if (wasPlaying) {
        debugPrint('🎵 AudioPlayer: Resuming playback');
        // Start audio slightly before video to ensure sync
        await state.audioPlayer!.play();
        await Future.delayed(const Duration(milliseconds: 50));
        await _videoController!.play();
        state = state.copyWith(isPlaying: true);
      }

      // Double check video is still muted
      await _ensureVideoMuted();

      debugPrint('🎵 AudioPlayer: Notifying language provider');
      ref.read(currentLanguageProvider(videoId).notifier).setLanguage(language);

      debugPrint('✅ AudioPlayer: Language switch completed successfully');
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
