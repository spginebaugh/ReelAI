// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_edit_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoEditStateImpl _$$VideoEditStateImplFromJson(Map<String, dynamic> json) =>
    _$VideoEditStateImpl(
      isProcessing: json['isProcessing'] as bool,
      isLoading: json['isLoading'] as bool,
      isPlaying: json['isPlaying'] as bool,
      isInitialized: json['isInitialized'] as bool,
      currentMode: $enumDecode(_$EditingModeEnumMap, json['currentMode']),
      startValue: (json['startValue'] as num).toDouble(),
      endValue: (json['endValue'] as num).toDouble(),
      brightness: (json['brightness'] as num).toDouble(),
      selectedFilter:
          FilterOption.fromJson(json['selectedFilter'] as Map<String, dynamic>),
      tempVideoFile:
          const FileConverter().fromJson(json['tempVideoFile'] as String?),
      currentPreviewPath: json['currentPreviewPath'] as String?,
      processedVideoPath: json['processedVideoPath'] as String?,
      videoPlayerController: const VideoPlayerControllerConverter()
          .fromJson(json['videoPlayerController'] as String?),
      chewieController: const ChewieControllerConverter()
          .fromJson(json['chewieController'] as String?),
    );

Map<String, dynamic> _$$VideoEditStateImplToJson(
        _$VideoEditStateImpl instance) =>
    <String, dynamic>{
      'isProcessing': instance.isProcessing,
      'isLoading': instance.isLoading,
      'isPlaying': instance.isPlaying,
      'isInitialized': instance.isInitialized,
      'currentMode': _$EditingModeEnumMap[instance.currentMode]!,
      'startValue': instance.startValue,
      'endValue': instance.endValue,
      'brightness': instance.brightness,
      'selectedFilter': instance.selectedFilter,
      'tempVideoFile': const FileConverter().toJson(instance.tempVideoFile),
      'currentPreviewPath': instance.currentPreviewPath,
      'processedVideoPath': instance.processedVideoPath,
      'videoPlayerController': const VideoPlayerControllerConverter()
          .toJson(instance.videoPlayerController),
      'chewieController':
          const ChewieControllerConverter().toJson(instance.chewieController),
    };

const _$EditingModeEnumMap = {
  EditingMode.none: 'none',
  EditingMode.trim: 'trim',
  EditingMode.filter: 'filter',
  EditingMode.brightness: 'brightness',
  EditingMode.metadata: 'metadata',
};
