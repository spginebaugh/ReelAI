import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';

import 'package:reel_ai/features/videos/models/subtitle_state.dart';
import 'package:reel_ai/common/utils/storage_paths.dart';
import 'package:reel_ai/features/auth/providers/auth_provider.dart';
import 'package:reel_ai/common/utils/logger.dart';
import 'package:reel_ai/features/videos/services/media/video_media_service.dart';
import 'video_media_provider.dart';

part 'subtitle_controller.g.dart';

@riverpod
class SubtitleController extends _$SubtitleController {
  Timer? _updateTimer;
  VideoPlayerController? _videoController;
  VideoMediaService get _mediaService => ref.read(videoMediaProvider);

  List<String> get availableLanguages => state.availableLanguages;

  @override
  SubtitleState build() {
    ref.onDispose(() {
      _updateTimer?.cancel();
      _videoController?.removeListener(_onVideoStateChanged);
    });

    return const SubtitleState();
  }

  Future<void> initialize(
    VideoPlayerController controller,
    String subtitleUrl,
  ) async {
    Logger.debug('Subtitles: Initializing with video controller');

    _updateTimer?.cancel();
    _videoController?.removeListener(_onVideoStateChanged);

    _videoController = controller;
    _videoController!.addListener(_onVideoStateChanged);

    // Load initial subtitles
    final subtitles = await _loadSubtitlesFromUrl(subtitleUrl);
    state = state.copyWith(subtitles: subtitles);

    // Start position tracking
    _startPositionTracking();

    Logger.success('Subtitles: Initialization complete');
  }

  Future<List<SubtitleCue>> _loadSubtitlesFromUrl(String url) async {
    Logger.debug('Subtitles: Loading from URL', {'url': url});

    final stopwatch = Stopwatch()..start();
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      Logger.error('Failed to load subtitles', {
        'statusCode': response.statusCode,
        'url': url,
      });
      throw Exception('Failed to load subtitles: ${response.statusCode}');
    }

    // Ensure proper UTF-8 decoding of the response body
    final content = utf8.decode(response.bodyBytes, allowMalformed: true);
    final lines = const LineSplitter().convert(content);
    final totalLines = lines.length;
    final subtitles = <SubtitleCue>[];

    int i = 0;
    while (i < lines.length) {
      final line = lines[i].trim();

      // Skip empty lines and WebVTT header
      if (line.isEmpty || line.startsWith('WEBVTT')) {
        i++;
        continue;
      }

      // Parse timestamp line
      final timestampMatch =
          RegExp(r'(\d{2}:\d{2}:\d{2}\.\d{3}) --> (\d{2}:\d{2}:\d{2}\.\d{3})')
              .firstMatch(line);

      if (timestampMatch != null) {
        final start = _parseTimestamp(timestampMatch.group(1)!);
        final end = _parseTimestamp(timestampMatch.group(2)!);

        // Collect text lines until next empty line or end
        final textLines = <String>[];
        i++;
        while (i < lines.length && lines[i].trim().isNotEmpty) {
          textLines.add(lines[i].trim());
          i++;
        }

        if (textLines.isNotEmpty) {
          subtitles.add(SubtitleCue(
            start: start,
            end: end,
            text: textLines.join('\n'),
          ));
        }
      }
      i++;
    }

    Logger.debug('Subtitles: Parsed ${subtitles.length} cues', {
      'totalLines': totalLines,
      'parseTime': stopwatch.elapsedMilliseconds,
    });

    return subtitles;
  }

  Duration _parseTimestamp(String timestamp) {
    final parts = timestamp.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final secondsAndMs = parts[2].split('.');
    final seconds = int.parse(secondsAndMs[0]);
    final milliseconds = int.parse(secondsAndMs[1]);

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  void _startPositionTracking() {
    _updateTimer?.cancel();

    // Don't start tracking if subtitles are off
    if (!state.isVisible) {
      return;
    }

    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_videoController == null || !_videoController!.value.isInitialized) {
        return;
      }

      final position = _videoController!.value.position;
      final currentCue = _findCurrentSubtitle(position);

      if (state.currentCue != currentCue) {
        state = state.copyWith(currentCue: currentCue);
      }
    });
  }

  SubtitleCue? _findCurrentSubtitle(Duration position) {
    final subtitles = state.subtitles;
    int low = 0;
    int high = subtitles.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final cue = subtitles[mid];

      if (position >= cue.start && position <= cue.end) {
        return cue;
      } else if (position < cue.start) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }
    return null;
  }

  void _onVideoStateChanged() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    // Handle video state changes if needed
    // For example, pause/resume subtitle updates
    if (!_videoController!.value.isPlaying) {
      _updateTimer?.cancel();
    } else {
      _startPositionTracking();
    }
  }

  void toggleVisibility() {
    state = state.copyWith(
      isVisible: !state.isVisible,
      currentCue: null, // Always clear the current subtitle when toggling
    );

    // If turning off, cancel the timer
    if (!state.isVisible) {
      _updateTimer?.cancel();
    } else {
      _startPositionTracking();
    }
  }

  void updateStyle(TextStyle style) {
    state = state.copyWith(style: style);
  }

  Future<void> loadLanguage(String videoId, String language) async {
    Logger.debug('Subtitles: Loading language', {'language': language});

    try {
      final user = ref.read(authStateProvider).requireValue!;

      // Get the subtitle URL
      final subtitleUrl = await _mediaService.fetchMediaUrl(
        userId: user.uid,
        videoId: videoId,
        type: 'subtitles',
        language: language,
        format: 'vtt',
      );

      // Load the subtitles
      final subtitles = await _loadSubtitlesFromUrl(subtitleUrl);

      // Update state with new subtitles and language, and turn visibility on
      state = state.copyWith(
        subtitles: subtitles,
        language: language,
        isVisible: true,
      );

      // Restart position tracking since we turned visibility on
      _startPositionTracking();

      Logger.success('Subtitles: Successfully switched to $language subtitles');
    } catch (e) {
      Logger.error('Failed to load subtitles', {
        'error': e.toString(),
        'language': language,
      });
      rethrow;
    }
  }

  Future<void> loadAvailableLanguages(String videoId, String userId) async {
    try {
      final languages = await _mediaService.listAvailableLanguages(
        userId: userId,
        videoId: videoId,
        type: 'subtitles',
        fileExtension: 'vtt',
      );

      state = state.copyWith(availableLanguages: languages);

      Logger.success('Subtitles: Loaded available languages', {
        'languages': languages,
      });
    } catch (e) {
      Logger.error('Failed to load available languages', {
        'error': e.toString(),
      });
      rethrow;
    }
  }
}
