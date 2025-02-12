// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_edit_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoEditStateImpl _$$VideoEditStateImplFromJson(Map<String, dynamic> json) =>
    _$VideoEditStateImpl(
      status: $enumDecode(_$VideoEditStatusEnumMap, json['status']),
      currentMode: $enumDecode(_$EditingModeEnumMap, json['currentMode']),
      tempVideoFile:
          const FileConverter().fromJson(json['tempVideoFile'] as String?),
      currentPreviewPath: json['currentPreviewPath'] as String?,
      processedVideoPath: json['processedVideoPath'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$VideoEditStateImplToJson(
        _$VideoEditStateImpl instance) =>
    <String, dynamic>{
      'status': _$VideoEditStatusEnumMap[instance.status]!,
      'currentMode': _$EditingModeEnumMap[instance.currentMode]!,
      'tempVideoFile': const FileConverter().toJson(instance.tempVideoFile),
      'currentPreviewPath': instance.currentPreviewPath,
      'processedVideoPath': instance.processedVideoPath,
      'errorMessage': instance.errorMessage,
    };

const _$VideoEditStatusEnumMap = {
  VideoEditStatus.initial: 'initial',
  VideoEditStatus.loading: 'loading',
  VideoEditStatus.ready: 'ready',
  VideoEditStatus.playing: 'playing',
  VideoEditStatus.processing: 'processing',
  VideoEditStatus.error: 'error',
};

const _$EditingModeEnumMap = {
  EditingMode.none: 'none',
  EditingMode.metadata: 'metadata',
  EditingMode.trim: 'trim',
  EditingMode.crop: 'crop',
  EditingMode.text: 'text',
  EditingMode.effects: 'effects',
  EditingMode.audio: 'audio',
  EditingMode.subtitles: 'subtitles',
};
