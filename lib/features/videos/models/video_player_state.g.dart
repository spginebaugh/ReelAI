// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AudioStateImpl _$$AudioStateImplFromJson(Map<String, dynamic> json) =>
    _$AudioStateImpl(
      isEnabled: json['isEnabled'] as bool,
      currentLanguage: json['currentLanguage'] as String,
      availableLanguages: (json['availableLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isLoading: json['isLoading'] as bool,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$AudioStateImplToJson(_$AudioStateImpl instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'currentLanguage': instance.currentLanguage,
      'availableLanguages': instance.availableLanguages,
      'isLoading': instance.isLoading,
      'error': instance.error,
    };

_$SubtitleStateImpl _$$SubtitleStateImplFromJson(Map<String, dynamic> json) =>
    _$SubtitleStateImpl(
      isEnabled: json['isEnabled'] as bool,
      currentLanguage: json['currentLanguage'] as String,
      availableLanguages: (json['availableLanguages'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isLoading: json['isLoading'] as bool,
      currentText: json['currentText'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$SubtitleStateImplToJson(_$SubtitleStateImpl instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'currentLanguage': instance.currentLanguage,
      'availableLanguages': instance.availableLanguages,
      'isLoading': instance.isLoading,
      'currentText': instance.currentText,
      'error': instance.error,
    };

_$VideoPlayerStateImpl _$$VideoPlayerStateImplFromJson(
        Map<String, dynamic> json) =>
    _$VideoPlayerStateImpl(
      status: $enumDecode(_$VideoPlayerStatusEnumMap, json['status']),
      mode: $enumDecode(_$VideoModeEnumMap, json['mode']),
      audio: AudioState.fromJson(json['audio'] as Map<String, dynamic>),
      subtitles:
          SubtitleState.fromJson(json['subtitles'] as Map<String, dynamic>),
      videoFile: const FileConverter().fromJson(json['videoFile'] as String?),
      video: json['video'] == null
          ? null
          : Video.fromJson(json['video'] as Map<String, dynamic>),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$VideoPlayerStateImplToJson(
        _$VideoPlayerStateImpl instance) =>
    <String, dynamic>{
      'status': _$VideoPlayerStatusEnumMap[instance.status]!,
      'mode': _$VideoModeEnumMap[instance.mode]!,
      'audio': instance.audio,
      'subtitles': instance.subtitles,
      'videoFile': const FileConverter().toJson(instance.videoFile),
      'video': instance.video,
      'error': instance.error,
    };

const _$VideoPlayerStatusEnumMap = {
  VideoPlayerStatus.initial: 'initial',
  VideoPlayerStatus.loading: 'loading',
  VideoPlayerStatus.ready: 'ready',
  VideoPlayerStatus.error: 'error',
};

const _$VideoModeEnumMap = {
  VideoMode.view: 'view',
  VideoMode.edit: 'edit',
};
