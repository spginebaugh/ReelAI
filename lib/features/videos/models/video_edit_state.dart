import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

part 'video_edit_state.freezed.dart';
part 'video_edit_state.g.dart';

/// Represents the current state of video editing
enum VideoEditStatus {
  /// Initial state, no video loaded
  initial,

  /// Video is being loaded or initialized
  loading,

  /// Video is loaded and ready for playback/editing
  ready,

  /// Video is currently playing
  playing,

  /// Video is being processed (e.g., applying effects)
  processing,

  /// An error occurred during video operations
  error
}

/// Represents the current editing mode
enum EditingMode {
  none,
  metadata,
  trim,
  crop,
  text,
  effects,
  audio,
  subtitles,
}

/// Converters for non-serializable types
class FileConverter implements JsonConverter<File?, String?> {
  const FileConverter();

  @override
  File? fromJson(String? json) => json != null ? File(json) : null;

  @override
  String? toJson(File? file) => file?.path;
}

class VideoPlayerControllerConverter
    implements JsonConverter<VideoPlayerController?, Map<String, dynamic>?> {
  const VideoPlayerControllerConverter();

  @override
  VideoPlayerController? fromJson(Map<String, dynamic>? json) => null;

  @override
  Map<String, dynamic>? toJson(VideoPlayerController? controller) => null;
}

class ChewieControllerConverter
    implements JsonConverter<ChewieController?, Map<String, dynamic>?> {
  const ChewieControllerConverter();

  @override
  ChewieController? fromJson(Map<String, dynamic>? json) => null;

  @override
  Map<String, dynamic>? toJson(ChewieController? controller) => null;
}

@freezed
class VideoEditState with _$VideoEditState {
  const factory VideoEditState({
    required VideoEditStatus status,
    required EditingMode currentMode,
    @FileConverter() File? tempVideoFile,
    String? currentPreviewPath,
    String? processedVideoPath,
    @JsonKey(ignore: true)
    @VideoPlayerControllerConverter()
    VideoPlayerController? videoPlayerController,
    @JsonKey(ignore: true)
    @ChewieControllerConverter()
    ChewieController? chewieController,
    String? errorMessage,
  }) = _VideoEditState;

  factory VideoEditState.initial() => const VideoEditState(
        status: VideoEditStatus.initial,
        currentMode: EditingMode.none,
        tempVideoFile: null,
        currentPreviewPath: null,
        processedVideoPath: null,
        videoPlayerController: null,
        chewieController: null,
        errorMessage: null,
      );

  factory VideoEditState.fromJson(Map<String, dynamic> json) =>
      _$VideoEditStateFromJson(json);
}
