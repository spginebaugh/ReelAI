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
      availableLanguages: (json['availableLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentLanguage: json['currentLanguage'] as String? ?? 'english',
      isInitialized: json['isInitialized'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
      isSwitching: json['isSwitching'] as bool? ?? false,
      hasError: json['hasError'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$SubtitleStateImplToJson(_$SubtitleStateImpl instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'entries': instance.entries,
      'currentText': instance.currentText,
      'availableLanguages': instance.availableLanguages,
      'currentLanguage': instance.currentLanguage,
      'isInitialized': instance.isInitialized,
      'isLoading': instance.isLoading,
      'isSwitching': instance.isSwitching,
      'hasError': instance.hasError,
      'errorMessage': instance.errorMessage,
    };
