// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubtitleEntryImpl _$$SubtitleEntryImplFromJson(Map<String, dynamic> json) =>
    _$SubtitleEntryImpl(
      start: _durationFromMillis((json['start'] as num).toInt()),
      end: _durationFromMillis((json['end'] as num).toInt()),
      text: json['text'] as String,
    );

Map<String, dynamic> _$$SubtitleEntryImplToJson(_$SubtitleEntryImpl instance) =>
    <String, dynamic>{
      'start': _millisFromDuration(instance.start),
      'end': _millisFromDuration(instance.end),
      'text': instance.text,
    };

_$SubtitleStateImpl _$$SubtitleStateImplFromJson(Map<String, dynamic> json) =>
    _$SubtitleStateImpl(
      isEnabled: json['isEnabled'] as bool? ?? false,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => SubtitleEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentText: json['currentText'] as String?,
    );

Map<String, dynamic> _$$SubtitleStateImplToJson(_$SubtitleStateImpl instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'entries': instance.entries,
      'currentText': instance.currentText,
    };
