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
  List<String> _availableLanguages = [];

  List<String> get availableLanguages => _availableLanguages;

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

    final List<SubtitleCue> subtitles = [];
    final lines = const LineSplitter().convert(response.body);

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
    state = state.copyWith(isVisible: !state.isVisible);
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

      // Update state with new subtitles and language
      state = state.copyWith(
        subtitles: subtitles,
        language: language,
      );
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

      final languages = result.items
          .where((ref) => ref.name.endsWith('.vtt'))
          .map((ref) {
            final parts = ref.name.split('_');
            if (parts.length != 2) return null;
            return parts[1].split('.')[0];
          })
          .where((lang) => lang != null)
          .map((lang) => lang!)
          .toList();

      // Ensure English is first if available
      if (languages.contains('english')) {
        languages.remove('english');
        languages.insert(0, 'english');
      }

      _availableLanguages = languages;
      debugPrint('✅ Subtitles: Found ${languages.length} available languages');
    } catch (e) {
      debugPrint('❌ Subtitles: Error loading available languages: $e');
      rethrow;
    }
  }
}
