import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/subtitle_state.dart';
import '../utils/storage_paths.dart';
import 'auth_provider.dart';

part 'subtitle_controller.g.dart';

@riverpod
class SubtitleController extends _$SubtitleController {
  Timer? _updateTimer;
  VideoPlayerController? _videoController;

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
    _updateTimer?.cancel();
    _videoController?.removeListener(_onVideoStateChanged);

    _videoController = controller;
    _videoController!.addListener(_onVideoStateChanged);

    // Load initial subtitles
    final subtitles = await _loadSubtitlesFromUrl(subtitleUrl);
    state = state.copyWith(subtitles: subtitles);

    // Start position tracking
    _startPositionTracking();
  }

  Future<List<SubtitleCue>> _loadSubtitlesFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load subtitles');
    }

    // Explicitly decode the response body as UTF-8
    final String decodedContent = utf8.decode(response.bodyBytes);
    final List<SubtitleCue> subtitles = [];
    final lines = const LineSplitter().convert(decodedContent);

    int i = 0;
    while (i < lines.length) {
      final line = lines[i].trim();

      // Skip empty lines and WEBVTT header
      if (line.isEmpty || line == 'WEBVTT') {
        i++;
        continue;
      }

      // Parse timestamp line
      if (line.contains('-->')) {
        final times = line.split('-->');
        final startTime = times[0].trim();
        final endTime = times[1].trim();

        // Get subtitle text (may be multiple lines)
        i++;
        String text = '';
        while (i < lines.length && lines[i].trim().isNotEmpty) {
          text += lines[i].trim() + '\n';
          i++;
        }
        text = text.trim();

        subtitles.add(SubtitleCue.fromVTT(startTime, endTime, text));
      } else {
        i++;
      }
    }

    return subtitles;
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
    try {
      final user = ref.read(authStateProvider).requireValue!;
      final storage = FirebaseStorage.instance;
      final subtitlePath = StoragePaths.subtitlesFile(
        user.uid,
        videoId,
        lang: language,
        format: 'vtt',
      );

      // Get the subtitle URL from Firebase Storage
      final subtitleUrl = await storage.ref(subtitlePath).getDownloadURL();

      // Load the subtitles for this language
      final subtitles = await _loadSubtitlesFromUrl(subtitleUrl);

      // Update state with new subtitles and language, and turn visibility on
      state = state.copyWith(
        subtitles: subtitles,
        language: language,
        isVisible: true, // Turn visibility on when loading a language
      );

      // Restart position tracking since we turned visibility on
      _startPositionTracking();
    } catch (e) {
      debugPrint('Error loading subtitles: $e');
      rethrow;
    }
  }

  Future<void> loadAvailableLanguages(String videoId, String userId) async {
    try {
      final storage = FirebaseStorage.instance;
      final subtitlesDir =
          '${StoragePaths.videoDirectory(userId, videoId)}/subtitles';

      debugPrint('🎬 Subtitles: Listing files in $subtitlesDir');
      final result = await storage.ref(subtitlesDir).listAll();

      debugPrint('🎬 Subtitles: Found ${result.items.length} files:');
      for (final ref in result.items) {
        debugPrint('   - ${ref.name}');
      }

      debugPrint('🎬 Subtitles: Filtering for .vtt files...');
      final vttFiles =
          result.items.where((ref) => ref.name.endsWith('.vtt')).toList();
      debugPrint('🎬 Subtitles: Found ${vttFiles.length} .vtt files:');
      for (final ref in vttFiles) {
        debugPrint('   - ${ref.name}');
      }

      debugPrint('🎬 Subtitles: Extracting languages...');
      final languages = vttFiles
          .map((ref) {
            final parts = ref.name.split('_');
            debugPrint('   - Processing ${ref.name}:');
            debugPrint('     * Parts: ${parts.join(" | ")}');
            if (parts.length != 2) {
              debugPrint('     * Skipped: Wrong number of parts');
              return null;
            }
            final lang = parts[1].split('.')[0];
            debugPrint('     * Extracted language: $lang');
            return lang;
          })
          .where((lang) => lang != null)
          .map((lang) => lang!)
          .toList();

      debugPrint('🎬 Subtitles: Extracted languages: $languages');

      // Ensure English is first if available
      if (languages.contains('english')) {
        languages.remove('english');
        languages.insert(0, 'english');
        debugPrint('🎬 Subtitles: Reordered with English first: $languages');
      }

      // Update state with available languages
      state = state.copyWith(availableLanguages: languages);
      debugPrint(
          '🎬 Subtitles: Updated state with languages: ${state.availableLanguages}');
    } catch (e, st) {
      debugPrint('❌ Subtitles: Error loading available languages:');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $st');
      rethrow;
    }
  }
}
