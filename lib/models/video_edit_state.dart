import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_video_trimmer/flutter_video_trimmer.dart';
import 'filter_option.dart';

part 'video_edit_state.freezed.dart';
part 'video_edit_state.g.dart';

enum EditingMode {
  none,
  trim,
  filter,
  brightness,
}

class FileConverter implements JsonConverter<File?, String?> {
  const FileConverter();

  @override
  File? fromJson(String? json) {
    return json != null ? File(json) : null;
  }

  @override
  String? toJson(File? file) {
    return file?.path;
  }
}

@freezed
class VideoEditState with _$VideoEditState {
  const factory VideoEditState({
    required bool isProcessing,
    required bool isLoading,
    String? processedVideoPath,
    required double startValue,
    required double endValue,
    required bool isPlaying,
    required double brightness,
    required FilterOption selectedFilter,
    required EditingMode currentMode,
    @FileConverter() File? tempVideoFile,
    String? currentPreviewPath,
  }) = _VideoEditState;

  factory VideoEditState.initial() => VideoEditState(
        isProcessing: false,
        isLoading: true,
        startValue: 0.0,
        endValue: 0.0,
        isPlaying: false,
        brightness: 1.0,
        selectedFilter: FilterOption.none,
        currentMode: EditingMode.none,
      );

  factory VideoEditState.fromJson(Map<String, dynamic> json) =>
      _$VideoEditStateFromJson(json);
}
