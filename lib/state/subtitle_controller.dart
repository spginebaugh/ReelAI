import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../models/subtitle_state.dart';
import 'package:flutter/foundation.dart';

part 'subtitle_controller.g.dart';

@riverpod
class SubtitleController extends _$SubtitleController {
  Timer? _subtitleTimer;
  VideoPlayerController? _videoController;

  @override
  SubtitleState build() {
    ref.onDispose(() {
      _subtitleTimer?.cancel();
    });
    return const SubtitleState();
  }

  void toggleSubtitles() {
    state = state.copyWith(isEnabled: !state.isEnabled);
    if (!state.isEnabled) {
      state = state.copyWith(currentText: null);
    }
  }

  Future<void> initialize(
      VideoPlayerController controller, String subtitleUrl) async {
    _videoController = controller;
    try {
      debugPrint('🎥 Subtitles: Fetching VTT file from $subtitleUrl');
      final response = await http.get(Uri.parse(subtitleUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load subtitles');
      }

      final entries = _parseVTT(response.body);
      state = state.copyWith(entries: entries);
      debugPrint('🎥 Subtitles: Parsed ${entries.length} subtitle entries');

      // Start subtitle sync timer
      _startSubtitleSync();
    } catch (e) {
      debugPrint('❌ Subtitles: Error initializing subtitles: $e');
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
