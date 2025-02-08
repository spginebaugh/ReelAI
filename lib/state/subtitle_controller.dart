import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../models/subtitle_state.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/storage_paths.dart';

part 'subtitle_controller.g.dart';

@riverpod
class SubtitleController extends _$SubtitleController {
  Timer? _subtitleTimer;
  VideoPlayerController? _videoController;

  @override
  SubtitleState build() {
    ref.onDispose(() {
      debugPrint('🎬 Subtitles: Provider disposing');
      _cleanup();
    });
    return const SubtitleState();
  }

  void _cleanup() {
    debugPrint('🎬 Subtitles: Cleaning up resources');
    _subtitleTimer?.cancel();
    _videoController = null;
    state = const SubtitleState();
  }

  void toggleSubtitles() {
    state = state.copyWith(isEnabled: !state.isEnabled);
    if (!state.isEnabled) {
      state = state.copyWith(currentText: null);
    }
  }

  Future<void> loadAvailableLanguages(String videoId, String userId) async {
    if (!state.isInitialized) {
      debugPrint('❌ Subtitles: Cannot load languages before initialization');
      return;
    }

    try {
      debugPrint('🎬 Subtitles: Loading available languages');
      state = state.copyWith(isLoading: true);

      final languages = await _loadAvailableSubtitleLanguages(videoId, userId);
      state = state.copyWith(
        availableLanguages: languages,
        isLoading: false,
      );
      debugPrint('✅ Subtitles: Loaded ${languages.length} available languages');
    } catch (e) {
      debugPrint('❌ Subtitles: Error loading available languages: $e');
      state = state.copyWith(
        availableLanguages: ['english'],
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to load subtitle languages',
      );
    }
  }

  Future<void> switchLanguage(
      String videoId, String userId, String language) async {
    if (!state.isInitialized) {
      debugPrint('❌ Subtitles: Cannot switch language before initialization');
      throw Exception('Subtitle controller not initialized');
    }

    if (state.isSwitching) {
      debugPrint('🎬 Subtitles: Already switching languages, ignoring request');
      return;
    }

    try {
      debugPrint('🎬 Subtitles: Switching to language: $language');
      state = state.copyWith(isSwitching: true, hasError: false);

      final storage = FirebaseStorage.instance;
      final subtitlePath = StoragePaths.subtitlesFile(
        userId,
        videoId,
        lang: language,
        format: 'vtt',
      );

      // Verify subtitle file exists
      debugPrint('🎬 Subtitles: Verifying subtitle file exists');
      try {
        await storage.ref(subtitlePath).getMetadata();
      } catch (e) {
        throw Exception('Subtitle file not found for language: $language');
      }

      final subtitleUrl = await storage.ref(subtitlePath).getDownloadURL();
      final response = await http.get(Uri.parse(subtitleUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load subtitles for language: $language');
      }

      final entries = _parseVTT(response.body);
      state = state.copyWith(
        entries: entries,
        currentLanguage: language,
        isSwitching: false,
      );

      debugPrint(
          '✅ Subtitles: Switched to $language with ${entries.length} entries');
    } catch (e) {
      debugPrint('❌ Subtitles: Error switching language: $e');
      state = state.copyWith(
        isSwitching: false,
        hasError: true,
        errorMessage: 'Failed to switch subtitle language',
      );
      rethrow;
    }
  }

  Future<List<String>> _loadAvailableSubtitleLanguages(
      String videoId, String userId) async {
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

      if (languages.isEmpty) {
        debugPrint('⚠️ Subtitles: No subtitle files found');
        return ['english'];
      }

      // Ensure English is first if available
      if (languages.contains('english')) {
        languages.remove('english');
        languages.insert(0, 'english');
      }

      return languages;
    } catch (e) {
      debugPrint('❌ Subtitles: Error loading available languages: $e');
      return ['english'];
    }
  }

  Future<void> initialize(
      VideoPlayerController controller, String subtitleUrl) async {
    debugPrint('🎬 Subtitles: Initializing controller');

    if (!controller.value.isInitialized) {
      debugPrint('❌ Subtitles: Video controller must be initialized first');
      throw Exception('Video controller must be initialized first');
    }

    try {
      // Clean up existing resources
      _cleanup();

      // Set up video controller
      _videoController = controller;

      final response = await http.get(Uri.parse(subtitleUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load initial subtitles');
      }

      final entries = _parseVTT(response.body);
      state = state.copyWith(
        entries: entries,
        currentLanguage: 'english',
        isInitialized: true,
        hasError: false,
        errorMessage: null,
      );

      debugPrint('🎬 Subtitles: Parsed ${entries.length} subtitle entries');

      // Start subtitle sync timer
      _startSubtitleSync();

      debugPrint('✅ Subtitles: Initialization complete');
    } catch (e) {
      debugPrint('❌ Subtitles: Initialization failed: $e');
      _cleanup();
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Failed to initialize subtitles',
      );
      rethrow;
    }
  }

  void _startSubtitleSync() {
    _subtitleTimer?.cancel();
    _subtitleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_videoController == null || !state.isEnabled) return;

      final position = _videoController!.value.position;
      final currentEntry = state.entries.cast<SubtitleEntry?>().firstWhere(
            (entry) => entry!.start <= position && entry.end >= position,
            orElse: () => null,
          );

      if (currentEntry != null && currentEntry.text != state.currentText) {
        state = state.copyWith(currentText: currentEntry.text);
      } else if (currentEntry == null && state.currentText != null) {
        state = state.copyWith(currentText: null);
      }
    });
  }

  List<SubtitleEntry> _parseVTT(String vttContent) {
    final entries = <SubtitleEntry>[];
    final lines = vttContent.split('\n');

    // Skip WEBVTT header
    var i = 1;
    while (i < lines.length) {
      // Skip empty lines and comments
      while (i < lines.length &&
          (lines[i].trim().isEmpty || lines[i].startsWith('NOTE'))) {
        i++;
      }

      if (i >= lines.length) break;

      // Parse timestamp line
      final timeLine = lines[i].trim();
      i++;

      if (timeLine.contains('-->')) {
        final times = timeLine.split('-->');
        if (times.length == 2) {
          final start = _parseTimestamp(times[0].trim());
          final end = _parseTimestamp(times[1].trim());

          // Parse subtitle text
          var text = StringBuffer();
          while (i < lines.length && lines[i].trim().isNotEmpty) {
            if (text.isNotEmpty) text.write('\n');
            text.write(lines[i].trim());
            i++;
          }

          if (text.isNotEmpty) {
            entries.add(SubtitleEntry(
              start: start,
              end: end,
              text: text.toString(),
            ));
          }
        }
      }
      i++;
    }

    return entries;
  }

  Duration _parseTimestamp(String timestamp) {
    final parts = timestamp.split(':');
    if (parts.length != 3) return Duration.zero;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final secondsAndMillis = parts[2].split('.');
    final seconds = int.tryParse(secondsAndMillis[0]) ?? 0;
    final milliseconds = int.tryParse(secondsAndMillis[1]) ?? 0;

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }
}
