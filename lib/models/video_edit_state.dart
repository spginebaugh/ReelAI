import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'filter_option.dart';

part 'video_edit_state.freezed.dart';
part 'video_edit_state.g.dart';

enum EditingMode {
  none,
  trim,
  filter,
  brightness,
  metadata,
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

class VideoPlayerControllerConverter
    implements JsonConverter<VideoPlayerController?, String?> {
  const VideoPlayerControllerConverter();

  @override
  VideoPlayerController? fromJson(String? json) => null;

  @override
  String? toJson(VideoPlayerController? controller) => null;
}

class ChewieControllerConverter
    implements JsonConverter<ChewieController?, String?> {
  const ChewieControllerConverter();

  @override
  ChewieController? fromJson(String? json) => null;

  @override
  String? toJson(ChewieController? controller) => null;
}

@freezed
class VideoEditState with _$VideoEditState {
  const factory VideoEditState({
    required bool isProcessing,
    required bool isLoading,
    required bool isPlaying,
    required bool isInitialized,
    required EditingMode currentMode,
    required double startValue,
    required double endValue,
    required double brightness,
    required FilterOption selectedFilter,
    required List<FilterOption> availableFilters,
    @FileConverter() File? tempVideoFile,
    String? currentPreviewPath,
    String? processedVideoPath,
    @JsonKey(ignore: true)
    @VideoPlayerControllerConverter()
    VideoPlayerController? videoPlayerController,
    @JsonKey(ignore: true)
    @ChewieControllerConverter()
    ChewieController? chewieController,
  }) = _VideoEditState;

  factory VideoEditState.initial() => VideoEditState(
        isProcessing: false,
        isLoading: false,
        isPlaying: false,
        isInitialized: false,
        currentMode: EditingMode.none,
        startValue: 0,
        endValue: 0,
        brightness: 1.0,
        selectedFilter: FilterOption.none,
        availableFilters: [FilterOption.none],
        tempVideoFile: null,
        currentPreviewPath: null,
        processedVideoPath: null,
        videoPlayerController: null,
        chewieController: null,
      );

  factory VideoEditState.fromJson(Map<String, dynamic> json) =>
      _$VideoEditStateFromJson(json);
}
