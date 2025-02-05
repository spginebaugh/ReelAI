import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
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
    required bool isPlaying,
    required EditingMode currentMode,
    required double startValue,
    required double endValue,
    required double brightness,
    required FilterOption selectedFilter,
    @FileConverter() File? tempVideoFile,
    String? currentPreviewPath,
    String? processedVideoPath,
  }) = _VideoEditState;

  factory VideoEditState.initial() => VideoEditState(
        isProcessing: false,
        isLoading: false,
        isPlaying: false,
        currentMode: EditingMode.none,
        startValue: 0,
        endValue: 0,
        brightness: 1.0,
        selectedFilter: FilterOption.none,
        tempVideoFile: null,
        currentPreviewPath: null,
        processedVideoPath: null,
      );

  factory VideoEditState.fromJson(Map<String, dynamic> json) =>
      _$VideoEditStateFromJson(json);
}
