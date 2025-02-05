// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_edit_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoEditStateImpl _$$VideoEditStateImplFromJson(Map<String, dynamic> json) =>
    _$VideoEditStateImpl(
      isProcessing: json['isProcessing'] as bool,
      isLoading: json['isLoading'] as bool,
      processedVideoPath: json['processedVideoPath'] as String?,
      startValue: (json['startValue'] as num).toDouble(),
      endValue: (json['endValue'] as num).toDouble(),
      isPlaying: json['isPlaying'] as bool,
      brightness: (json['brightness'] as num).toDouble(),
      selectedFilter:
          FilterOption.fromJson(json['selectedFilter'] as Map<String, dynamic>),
      currentMode: $enumDecode(_$EditingModeEnumMap, json['currentMode']),
      tempVideoFile:
          const FileConverter().fromJson(json['tempVideoFile'] as String?),
      currentPreviewPath: json['currentPreviewPath'] as String?,
    );

Map<String, dynamic> _$$VideoEditStateImplToJson(
        _$VideoEditStateImpl instance) =>
    <String, dynamic>{
      'isProcessing': instance.isProcessing,
      'isLoading': instance.isLoading,
      'processedVideoPath': instance.processedVideoPath,
      'startValue': instance.startValue,
      'endValue': instance.endValue,
      'isPlaying': instance.isPlaying,
      'brightness': instance.brightness,
      'selectedFilter': instance.selectedFilter,
      'currentMode': _$EditingModeEnumMap[instance.currentMode]!,
      'tempVideoFile': const FileConverter().toJson(instance.tempVideoFile),
      'currentPreviewPath': instance.currentPreviewPath,
    };

const _$EditingModeEnumMap = {
  EditingMode.none: 'none',
  EditingMode.trim: 'trim',
  EditingMode.filter: 'filter',
  EditingMode.brightness: 'brightness',
};
