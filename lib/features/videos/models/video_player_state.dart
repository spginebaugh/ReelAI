import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:reel_ai/features/videos/models/video.dart';

part 'video_player_state.freezed.dart';
part 'video_player_state.g.dart';

/// The current status of the video player
enum VideoPlayerStatus {
  initial,
  loading,
  ready,
  error,
}

/// The current mode of video playback/editing
enum VideoMode {
  view,
  edit,
}

/// Converter for File objects
class FileConverter implements JsonConverter<File?, String?> {
  const FileConverter();

  @override
  File? fromJson(String? json) => json != null ? File(json) : null;

  @override
  String? toJson(File? file) => file?.path;
}

/// The current audio state
@freezed
class AudioState with _$AudioState {
  const factory AudioState({
    required bool isEnabled,
    required String currentLanguage,
    required List<String> availableLanguages,
    required bool isLoading,
    String? error,
  }) = _AudioState;

  factory AudioState.initial() => const AudioState(
        isEnabled: false,
        currentLanguage: 'english',
        availableLanguages: [],
        isLoading: false,
      );

  factory AudioState.fromJson(Map<String, dynamic> json) =>
      _$AudioStateFromJson(json);
}

/// The current subtitle state
@freezed
class SubtitleState with _$SubtitleState {
  const factory SubtitleState({
    required bool isEnabled,
    required String currentLanguage,
    required List<String> availableLanguages,
    required bool isLoading,
    String? currentText,
    String? error,
  }) = _SubtitleState;

  factory SubtitleState.initial() => const SubtitleState(
        isEnabled: false,
        currentLanguage: 'english',
        availableLanguages: [],
        isLoading: false,
      );

  factory SubtitleState.fromJson(Map<String, dynamic> json) =>
      _$SubtitleStateFromJson(json);
}

/// Consolidated video player state
@freezed
class VideoPlayerState with _$VideoPlayerState {
  const factory VideoPlayerState({
    required VideoPlayerStatus status,
    required VideoMode mode,
    required AudioState audio,
    required SubtitleState subtitles,
    @JsonKey(ignore: true) VideoPlayerController? videoController,
    @JsonKey(ignore: true) ChewieController? chewieController,
    @FileConverter() File? videoFile,
    Video? video,
    String? error,
  }) = _VideoPlayerState;

  factory VideoPlayerState.initial() => VideoPlayerState(
        status: VideoPlayerStatus.initial,
        mode: VideoMode.view,
        audio: AudioState.initial(),
        subtitles: SubtitleState.initial(),
      );

  factory VideoPlayerState.fromJson(Map<String, dynamic> json) =>
      _$VideoPlayerStateFromJson(json);
}
