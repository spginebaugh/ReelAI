import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'subtitle_state.freezed.dart';
part 'subtitle_state.g.dart';

@freezed
class SubtitleEntry with _$SubtitleEntry {
  const factory SubtitleEntry({
    @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
    required Duration start,
    @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
    required Duration end,
    required String text,
  }) = _SubtitleEntry;

  factory SubtitleEntry.fromJson(Map<String, dynamic> json) =>
      _$SubtitleEntryFromJson(json);
}

@freezed
class SubtitleState with _$SubtitleState {
  const factory SubtitleState({
    @Default([]) List<SubtitleCue> subtitles,
    SubtitleCue? currentCue,
    @Default('english') String language,
    @Default(true) bool isVisible,
    @Default([]) List<String> availableLanguages,
    @JsonKey(ignore: true) TextStyle? style,
  }) = _SubtitleState;

  factory SubtitleState.fromJson(Map<String, dynamic> json) =>
      _$SubtitleStateFromJson(json);
}

@freezed
class SubtitleCue with _$SubtitleCue {
  const factory SubtitleCue({
    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    required Duration start,
    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    required Duration end,
    required String text,
  }) = _SubtitleCue;

  factory SubtitleCue.fromJson(Map<String, dynamic> json) =>
      _$SubtitleCueFromJson(json);

  factory SubtitleCue.fromVTT(String startTime, String endTime, String text) {
    return SubtitleCue(
      start: _parseVTTTime(startTime),
      end: _parseVTTTime(endTime),
      text: text,
    );
  }
}

Duration _durationFromMillis(int millis) => Duration(milliseconds: millis);
int _millisFromDuration(Duration duration) => duration.inMilliseconds;

Duration _parseVTTTime(String timeString) {
  final parts = timeString.split(':');
  final seconds = parts[2].split('.');

  return Duration(
    hours: int.parse(parts[0]),
    minutes: int.parse(parts[1]),
    seconds: int.parse(seconds[0]),
    milliseconds: int.parse(seconds[1]),
  );
}

// JSON converters for Duration
int _durationToJson(Duration duration) => duration.inMilliseconds;
Duration _durationFromJson(int milliseconds) =>
    Duration(milliseconds: milliseconds);
