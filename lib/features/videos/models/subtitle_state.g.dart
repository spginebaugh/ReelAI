// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubtitleStateImpl _$$SubtitleStateImplFromJson(Map<String, dynamic> json) =>
    _$SubtitleStateImpl(
      subtitles: (json['subtitles'] as List<dynamic>?)
              ?.map((e) => SubtitleCue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentCue: json['currentCue'] == null
          ? null
          : SubtitleCue.fromJson(json['currentCue'] as Map<String, dynamic>),
      language: json['language'] as String? ?? 'english',
      isVisible: json['isVisible'] as bool? ?? true,
      availableLanguages: (json['availableLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SubtitleStateImplToJson(_$SubtitleStateImpl instance) =>
    <String, dynamic>{
      'subtitles': instance.subtitles,
      'currentCue': instance.currentCue,
      'language': instance.language,
      'isVisible': instance.isVisible,
      'availableLanguages': instance.availableLanguages,
    };

_$SubtitleCueImpl _$$SubtitleCueImplFromJson(Map<String, dynamic> json) =>
    _$SubtitleCueImpl(
      start: _durationFromJson((json['start'] as num).toInt()),
      end: _durationFromJson((json['end'] as num).toInt()),
      text: json['text'] as String,
    );

Map<String, dynamic> _$$SubtitleCueImplToJson(_$SubtitleCueImpl instance) =>
    <String, dynamic>{
      'start': _durationToJson(instance.start),
      'end': _durationToJson(instance.end),
      'text': instance.text,
    };
