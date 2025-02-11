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
      availableFilters: (json['availableFilters'] as List<dynamic>)
          .map((e) => FilterOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      tempVideoFile:
          const FileConverter().fromJson(json['tempVideoFile'] as String?),
      currentPreviewPath: json['currentPreviewPath'] as String?,
      processedVideoPath: json['processedVideoPath'] as String?,
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
      'availableFilters': instance.availableFilters,
      'tempVideoFile': const FileConverter().toJson(instance.tempVideoFile),
      'currentPreviewPath': instance.currentPreviewPath,
      'processedVideoPath': instance.processedVideoPath,
    };

const _$EditingModeEnumMap = {
  EditingMode.none: 'none',
  EditingMode.trim: 'trim',
  EditingMode.filter: 'filter',
  EditingMode.brightness: 'brightness',
  EditingMode.metadata: 'metadata',
};
