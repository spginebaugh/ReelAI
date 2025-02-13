import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/features/videos/models/video_player_state.dart';
import 'package:reel_ai/features/videos/services/processing/video_processor.dart';
import 'package:reel_ai/features/videos/services/media/video_media_service.dart';
import 'package:reel_ai/features/videos/services/factories/chewie_controller_factory.dart';
import 'package:reel_ai/features/videos/services/factories/video_player_factory.dart';
import 'package:reel_ai/features/videos/services/utils/controller_disposer.dart';
import 'package:reel_ai/common/utils/logger.dart';
import 'package:reel_ai/features/auth/providers/auth_provider.dart';

part 'video_player_facade.g.dart';

/// Provider for the VideoMediaService
@Riverpod(keepAlive: true)
VideoMediaService videoMedia(VideoMediaRef ref) => VideoMediaService();

/// Subtitle data structure
class SubtitleEntry {
  final Duration start;
  final Duration end;
  final String text;

  SubtitleEntry({
    required this.start,
    required this.end,
    required this.text,
  });
}

@riverpod
class VideoPlayerFacade extends _$VideoPlayerFacade {
  VideoProcessor get _videoService => VideoProcessor();
  VideoMediaService get _mediaService => ref.read(videoMediaProvider);
  List<SubtitleEntry>? _currentSubtitles;

  @override
  Future<VideoPlayerState> build() async {
    ref.onDispose(() async {
      try {
        final currentState = state.value;
        if (currentState == null) return;

        Logger.state('Disposing video player state');

        // Remove subtitle listener if exists
        if (currentState.videoController != null) {
          currentState.videoController!.removeListener(_updateSubtitleText);
        }

        // Dispose controllers
        await ControllerDisposer.disposeControllers(
          videoController: currentState.videoController,
          chewieController: currentState.chewieController,
        );

        // Cleanup files
        if (currentState.videoFile != null) {
          await currentState.videoFile!.delete().catchError((_) {
            // Ignore file deletion errors during cleanup
          });
        }
      } catch (e) {
        Logger.warning(
            'Error during video player disposal', {'error': e.toString()});
      }
    });

    return VideoPlayerState.initial();
  }

  Future<void> _disposeControllers(VideoPlayerState state) async {
    await ControllerDisposer.disposeControllers(
      videoController: state.videoController,
      chewieController: state.chewieController,
    );
  }

  Future<void> initialize(Video video) async {
    try {
      // If we're already initialized with this video, don't reinitialize
      if (state.value?.status == VideoPlayerStatus.ready &&
          state.value?.video?.id == video.id) {
        return;
      }

      // Set loading state
      state = const AsyncValue.loading();

      // Clean up any existing controllers
      if (state.value?.videoController != null) {
        await _disposeControllers(state.value!);
      }

      // Get user
      final user = ref.read(authStateProvider).requireValue!;

      // Download video
      final videoFile = await _videoService.downloadVideo(video.videoUrl);

      // Fetch available languages first
      final languages = await _mediaService.listAvailableLanguages(
        userId: user.uid,
        videoId: video.id,
        type: 'audio',
        fileExtension: 'mp3',
      );

      // Create initial muxed stream with English audio
      final muxedFile = await _mediaService.createMuxedStreamWithAudio(
        videoFile: videoFile,
        userId: user.uid,
        videoId: video.id,
        language: 'english',
      );

      // Initialize video player with muxed file instead of original video
      final videoController = await VideoPlayerFactory.create(muxedFile);
      final chewieController = ChewieControllerFactory.create(
        videoController,
        autoPlay: false,
        showControls: true,
      );

      // Set initial volume to 1.0 since we're using muxed audio
      await videoController.setVolume(1.0);

      // Update state with initialized controllers and video object
      state = AsyncValue.data(VideoPlayerState(
        status: VideoPlayerStatus.ready,
        mode: VideoMode.view,
        audio: AudioState(
          isEnabled: true,
          currentLanguage: 'english',
          availableLanguages: languages,
          isLoading: false,
        ),
        subtitles: SubtitleState.initial(),
        videoController: videoController,
        chewieController: chewieController,
        videoFile: videoFile,
        video: video,
      ));

      // Initialize subtitles in parallel
      await _initializeSubtitles(video.id, user.uid);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _initializeAudio(String videoId, String userId) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;

      final audioUrl = await _mediaService.fetchMediaUrl(
        userId: userId,
        videoId: videoId,
        type: 'audio',
        format: 'mp3',
      );

      if (audioUrl != null) {
        // Fetch available languages
        final languages = await _mediaService.listAvailableLanguages(
          userId: userId,
          videoId: videoId,
          type: 'audio',
          fileExtension: 'mp3',
        );

        state = AsyncValue.data(currentState.copyWith(
          audio: currentState.audio.copyWith(
            availableLanguages: languages,
          ),
        ));
      }
    } catch (e) {
      Logger.warning('Failed to initialize audio', {'error': e.toString()});
    }
  }

  Future<void> _initializeSubtitles(String videoId, String userId) async {
    try {
      state.whenData((currentState) async {
        final subtitleUrl = await _mediaService.fetchMediaUrl(
          userId: userId,
          videoId: videoId,
          type: 'subtitles',
          format: 'vtt',
        );

        if (subtitleUrl != null) {
          // Fetch available languages
          final languages = await _mediaService.listAvailableLanguages(
            userId: userId,
            videoId: videoId,
            type: 'subtitles',
            fileExtension: 'vtt',
          );

          state = AsyncValue.data(currentState.copyWith(
            subtitles: SubtitleState(
              isEnabled: true,
              currentLanguage: 'english',
              availableLanguages: languages,
              isLoading: false,
            ),
          ));
        }
      });
    } catch (e) {
      Logger.warning('Failed to initialize subtitles', {'error': e.toString()});
    }
  }

  void setMode(VideoMode mode) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(mode: mode));
    });
  }

  Future<void> switchAudioLanguage(String language) async {
    File? oldMuxedFile;
    File? newMuxedFile;

    try {
      final currentState = state.value;
      if (currentState == null) return;

      if (!currentState.audio.availableLanguages.contains(language)) return;

      // Update state to show loading
      state = AsyncValue.data(currentState.copyWith(
        audio: currentState.audio.copyWith(
          currentLanguage: language,
          isLoading: true,
        ),
      ));

      // Get user and validate video file
      final user = ref.read(authStateProvider).requireValue!;
      final videoFile = currentState.videoFile;
      final video = currentState.video; // Get video from state

      if (videoFile == null || video == null) {
        throw Exception('Video file or video object not available');
      }

      // Store reference to current muxed file if it exists
      if (currentState.videoController?.dataSource != videoFile.path) {
        oldMuxedFile = File(currentState.videoController?.dataSource ?? '');
      }

      // Create muxed stream with new audio
      newMuxedFile = await _mediaService.createMuxedStreamWithAudio(
        videoFile: videoFile,
        userId: user.uid,
        videoId: video.id,
        language: language.toLowerCase(),
      );

      // Get current position and playback state before switching
      Duration position = Duration.zero;
      bool wasPlaying = false;

      if (currentState.videoController != null) {
        position = currentState.videoController!.value.position;
        wasPlaying = currentState.videoController!.value.isPlaying;
      }

      // Clean up old controllers before creating new ones
      await _disposeControllers(currentState);

      // Initialize new video player with muxed stream using our factories
      final videoController = await VideoPlayerFactory.create(newMuxedFile);

      // Set initial volume to 1.0 since we're using muxed audio
      await videoController.setVolume(1.0);

      // Restore position before creating Chewie controller
      try {
        await videoController.seekTo(position);
      } catch (e) {
        Logger.warning('Failed to restore video position', {
          'error': e.toString(),
          'position': position.inMilliseconds,
        });
      }

      final chewieController = ChewieControllerFactory.create(
        videoController,
        autoPlay: wasPlaying,
        showControls: true,
      );

      // Update state with new controllers
      state = AsyncValue.data(currentState.copyWith(
        videoController: videoController,
        chewieController: chewieController,
        audio: currentState.audio.copyWith(
          currentLanguage: language,
          isLoading: false,
        ),
      ));

      // Reattach subtitle listener if subtitles are enabled and available
      if (currentState.subtitles.isEnabled && _currentSubtitles != null) {
        videoController.addListener(_updateSubtitleText);
        // Force an immediate subtitle update
        _updateSubtitleText();
      }

      // Clean up old muxed file after successful switch
      if (oldMuxedFile != null && await oldMuxedFile.exists()) {
        try {
          await oldMuxedFile.delete();
        } catch (e) {
          Logger.warning('Failed to delete old muxed file', {
            'error': e.toString(),
            'path': oldMuxedFile.path,
          });
        }
      }
    } catch (e) {
      Logger.error('Failed to switch audio language', {'error': e.toString()});

      // Clean up new muxed file if there was an error
      if (newMuxedFile != null) {
        try {
          await newMuxedFile.delete();
        } catch (e) {
          Logger.warning('Failed to delete new muxed file after error', {
            'error': e.toString(),
          });
        }
      }

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(
          audio: currentState.audio.copyWith(
            isLoading: false,
            error: e.toString(),
          ),
        ));
      }
    }
  }

  void toggleAudio() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        audio: currentState.audio.copyWith(
          isEnabled: !currentState.audio.isEnabled,
        ),
      ));

      // Since we're using muxed streams, we control audio through video player volume
      if (currentState.videoController != null) {
        if (currentState.audio.isEnabled) {
          currentState.videoController!.setVolume(1.0);
        } else {
          currentState.videoController!.setVolume(0.0);
        }
      }
    });
  }

  void toggleSubtitles() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        subtitles: currentState.subtitles.copyWith(
          isEnabled: !currentState.subtitles.isEnabled,
        ),
      ));
    });
  }

  Future<void> switchSubtitleLanguage(String language) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;

      if (!currentState.subtitles.availableLanguages.contains(language)) return;

      // Update state to show loading
      state = AsyncValue.data(currentState.copyWith(
        subtitles: currentState.subtitles.copyWith(
          isEnabled: true,
          currentLanguage: language,
          isLoading: true,
          currentText: null,
        ),
      ));

      // Get user
      final user = ref.read(authStateProvider).requireValue!;
      final video = currentState.video;

      if (video == null) {
        throw Exception('Video object not available');
      }

      // Fetch subtitle content for the selected language
      final subtitleUrl = await _mediaService.fetchMediaUrl(
        userId: user.uid,
        videoId: video.id,
        type: 'subtitles',
        format: 'vtt',
        language: language.toLowerCase(),
      );

      if (subtitleUrl != null) {
        // Download and parse subtitle content with proper encoding
        final response = await http.get(Uri.parse(subtitleUrl));
        if (response.statusCode == 200) {
          // Detect and decode with UTF-8
          final decoded = _decodeVTTContent(response.bodyBytes);
          _currentSubtitles = _parseVTTSubtitles(decoded);

          // Remove existing listener if any
          if (currentState.videoController != null) {
            currentState.videoController!.removeListener(_updateSubtitleText);
          }

          // Set up position listener
          currentState.videoController?.addListener(_updateSubtitleText);

          state = AsyncValue.data(currentState.copyWith(
            subtitles: currentState.subtitles.copyWith(
              isEnabled: true,
              currentLanguage: language,
              isLoading: false,
              currentText: null,
            ),
          ));

          // Explicitly trigger subtitle update after language switch
          _updateSubtitleText();
        }
      }
    } catch (e) {
      Logger.warning(
          'Failed to switch subtitle language', {'error': e.toString()});
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(
          subtitles: currentState.subtitles.copyWith(
            isLoading: false,
            error: e.toString(),
          ),
        ));
      }
    }
  }

  String _decodeVTTContent(List<int> bytes) {
    // Try UTF-8 first
    try {
      return utf8.decode(bytes);
    } catch (_) {
      // If UTF-8 fails, try with Latin1
      try {
        return latin1.decode(bytes);
      } catch (_) {
        // If both fail, try to remove BOM and decode as UTF-8
        if (bytes.length >= 3 &&
            bytes[0] == 0xEF &&
            bytes[1] == 0xBB &&
            bytes[2] == 0xBF) {
          try {
            return utf8.decode(bytes.sublist(3));
          } catch (_) {
            // If all attempts fail, fall back to ASCII
            return ascii.decode(bytes, allowInvalid: true);
          }
        }
        // If no BOM, fall back to ASCII
        return ascii.decode(bytes, allowInvalid: true);
      }
    }
  }

  List<SubtitleEntry> _parseVTTSubtitles(String vttContent) {
    final List<SubtitleEntry> subtitles = [];
    // Normalize line endings
    final normalizedContent =
        vttContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalizedContent.split('\n');
    int i = 0;

    // Skip WEBVTT header and metadata
    while (i < lines.length) {
      final line = lines[i].trim();
      if (line.contains('-->')) break;
      i++;
    }

    while (i < lines.length) {
      final line = lines[i].trim();
      if (line.contains('-->')) {
        final times = line.split('-->');
        if (times.length == 2) {
          final start = _parseVTTTime(times[0].trim());
          final end = _parseVTTTime(times[1].trim());

          i++;
          final textParts = <String>[];
          while (i < lines.length && lines[i].trim().isNotEmpty) {
            textParts.add(lines[i].trim());
            i++;
          }

          final text = textParts.join('\n');
          if (text.isNotEmpty) {
            subtitles.add(SubtitleEntry(
              start: start,
              end: end,
              text: text,
            ));
          }
        }
      }
      i++;
    }

    return subtitles;
  }

  Duration _parseVTTTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 3) return Duration.zero;

    final seconds = parts[2].split('.');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(seconds[0]),
      milliseconds:
          seconds.length > 1 ? int.parse(seconds[1].padRight(3, '0')) : 0,
    );
  }

  void disableSubtitles() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(
        subtitles: currentState.subtitles.copyWith(
          isEnabled: false,
        ),
      ));
    });
  }

  void _updateSubtitleText() {
    final currentState = state.value;
    if (currentState == null ||
        currentState.videoController == null ||
        !currentState.subtitles.isEnabled ||
        _currentSubtitles == null ||
        _currentSubtitles!.isEmpty) return;

    final position = currentState.videoController!.value.position;
    String? newText;

    // Binary search for the correct subtitle
    int low = 0;
    int high = _currentSubtitles!.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final subtitle = _currentSubtitles![mid];

      if (position >= subtitle.start && position <= subtitle.end) {
        newText = subtitle.text;
        break;
      } else if (position < subtitle.start) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    // Only update state if the text has actually changed
    if (newText != currentState.subtitles.currentText) {
      state = AsyncValue.data(currentState.copyWith(
        subtitles: currentState.subtitles.copyWith(
          currentText: newText,
        ),
      ));
    }
  }
}
