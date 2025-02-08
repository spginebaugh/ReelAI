import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

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
    @Default(false) bool isEnabled,
    @Default([]) List<SubtitleEntry> entries,
    String? currentText,
    @Default([]) List<String> availableLanguages,
    @Default('english') String currentLanguage,
    @Default(false) bool isInitialized,
    @Default(false) bool isLoading,
    @Default(false) bool isSwitching,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _SubtitleState;

  factory SubtitleState.fromJson(Map<String, dynamic> json) =>
      _$SubtitleStateFromJson(json);
}

// Helper functions for Duration serialization
Duration _durationFromMillis(int millis) => Duration(milliseconds: millis);
int _millisFromDuration(Duration duration) => duration.inMilliseconds;
