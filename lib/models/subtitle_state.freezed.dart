// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtitle_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SubtitleEntry _$SubtitleEntryFromJson(Map<String, dynamic> json) {
  return _SubtitleEntry.fromJson(json);
}

/// @nodoc
mixin _$SubtitleEntry {
  @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
  Duration get start => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
  Duration get end => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this SubtitleEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubtitleEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubtitleEntryCopyWith<SubtitleEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubtitleEntryCopyWith<$Res> {
  factory $SubtitleEntryCopyWith(
          SubtitleEntry value, $Res Function(SubtitleEntry) then) =
      _$SubtitleEntryCopyWithImpl<$Res, SubtitleEntry>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
      Duration start,
      @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
      Duration end,
      String text});
}

/// @nodoc
class _$SubtitleEntryCopyWithImpl<$Res, $Val extends SubtitleEntry>
    implements $SubtitleEntryCopyWith<$Res> {
  _$SubtitleEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubtitleEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as Duration,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as Duration,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubtitleEntryImplCopyWith<$Res>
    implements $SubtitleEntryCopyWith<$Res> {
  factory _$$SubtitleEntryImplCopyWith(
          _$SubtitleEntryImpl value, $Res Function(_$SubtitleEntryImpl) then) =
      __$$SubtitleEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
      Duration start,
      @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
      Duration end,
      String text});
}

/// @nodoc
class __$$SubtitleEntryImplCopyWithImpl<$Res>
    extends _$SubtitleEntryCopyWithImpl<$Res, _$SubtitleEntryImpl>
    implements _$$SubtitleEntryImplCopyWith<$Res> {
  __$$SubtitleEntryImplCopyWithImpl(
      _$SubtitleEntryImpl _value, $Res Function(_$SubtitleEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubtitleEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? text = null,
  }) {
    return _then(_$SubtitleEntryImpl(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as Duration,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as Duration,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubtitleEntryImpl implements _SubtitleEntry {
  const _$SubtitleEntryImpl(
      {@JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
      required this.start,
      @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
      required this.end,
      required this.text});

  factory _$SubtitleEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubtitleEntryImplFromJson(json);

  @override
  @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
  final Duration start;
  @override
  @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
  final Duration end;
  @override
  final String text;

  @override
  String toString() {
    return 'SubtitleEntry(start: $start, end: $end, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtitleEntryImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, start, end, text);

  /// Create a copy of SubtitleEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubtitleEntryImplCopyWith<_$SubtitleEntryImpl> get copyWith =>
      __$$SubtitleEntryImplCopyWithImpl<_$SubtitleEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubtitleEntryImplToJson(
      this,
    );
  }
}

abstract class _SubtitleEntry implements SubtitleEntry {
  const factory _SubtitleEntry(
      {@JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
      required final Duration start,
      @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
      required final Duration end,
      required final String text}) = _$SubtitleEntryImpl;

  factory _SubtitleEntry.fromJson(Map<String, dynamic> json) =
      _$SubtitleEntryImpl.fromJson;

  @override
  @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
  Duration get start;
  @override
  @JsonKey(fromJson: _durationFromMillis, toJson: _millisFromDuration)
  Duration get end;
  @override
  String get text;

  /// Create a copy of SubtitleEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtitleEntryImplCopyWith<_$SubtitleEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubtitleState _$SubtitleStateFromJson(Map<String, dynamic> json) {
  return _SubtitleState.fromJson(json);
}

/// @nodoc
mixin _$SubtitleState {
  List<SubtitleCue> get subtitles => throw _privateConstructorUsedError;
  SubtitleCue? get currentCue => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  bool get isVisible => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  TextStyle? get style => throw _privateConstructorUsedError;

  /// Serializes this SubtitleState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubtitleStateCopyWith<SubtitleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubtitleStateCopyWith<$Res> {
  factory $SubtitleStateCopyWith(
          SubtitleState value, $Res Function(SubtitleState) then) =
      _$SubtitleStateCopyWithImpl<$Res, SubtitleState>;
  @useResult
  $Res call(
      {List<SubtitleCue> subtitles,
      SubtitleCue? currentCue,
      String language,
      bool isVisible,
      @JsonKey(ignore: true) TextStyle? style});

  $SubtitleCueCopyWith<$Res>? get currentCue;
}

/// @nodoc
class _$SubtitleStateCopyWithImpl<$Res, $Val extends SubtitleState>
    implements $SubtitleStateCopyWith<$Res> {
  _$SubtitleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subtitles = null,
    Object? currentCue = freezed,
    Object? language = null,
    Object? isVisible = null,
    Object? style = freezed,
  }) {
    return _then(_value.copyWith(
      subtitles: null == subtitles
          ? _value.subtitles
          : subtitles // ignore: cast_nullable_to_non_nullable
              as List<SubtitleCue>,
      currentCue: freezed == currentCue
          ? _value.currentCue
          : currentCue // ignore: cast_nullable_to_non_nullable
              as SubtitleCue?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as TextStyle?,
    ) as $Val);
  }

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubtitleCueCopyWith<$Res>? get currentCue {
    if (_value.currentCue == null) {
      return null;
    }

    return $SubtitleCueCopyWith<$Res>(_value.currentCue!, (value) {
      return _then(_value.copyWith(currentCue: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubtitleStateImplCopyWith<$Res>
    implements $SubtitleStateCopyWith<$Res> {
  factory _$$SubtitleStateImplCopyWith(
          _$SubtitleStateImpl value, $Res Function(_$SubtitleStateImpl) then) =
      __$$SubtitleStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<SubtitleCue> subtitles,
      SubtitleCue? currentCue,
      String language,
      bool isVisible,
      @JsonKey(ignore: true) TextStyle? style});

  @override
  $SubtitleCueCopyWith<$Res>? get currentCue;
}

/// @nodoc
class __$$SubtitleStateImplCopyWithImpl<$Res>
    extends _$SubtitleStateCopyWithImpl<$Res, _$SubtitleStateImpl>
    implements _$$SubtitleStateImplCopyWith<$Res> {
  __$$SubtitleStateImplCopyWithImpl(
      _$SubtitleStateImpl _value, $Res Function(_$SubtitleStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subtitles = null,
    Object? currentCue = freezed,
    Object? language = null,
    Object? isVisible = null,
    Object? style = freezed,
  }) {
    return _then(_$SubtitleStateImpl(
      subtitles: null == subtitles
          ? _value._subtitles
          : subtitles // ignore: cast_nullable_to_non_nullable
              as List<SubtitleCue>,
      currentCue: freezed == currentCue
          ? _value.currentCue
          : currentCue // ignore: cast_nullable_to_non_nullable
              as SubtitleCue?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      isVisible: null == isVisible
          ? _value.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      style: freezed == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as TextStyle?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubtitleStateImpl implements _SubtitleState {
  const _$SubtitleStateImpl(
      {final List<SubtitleCue> subtitles = const [],
      this.currentCue,
      this.language = 'english',
      this.isVisible = true,
      @JsonKey(ignore: true) this.style})
      : _subtitles = subtitles;

  factory _$SubtitleStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubtitleStateImplFromJson(json);

  final List<SubtitleCue> _subtitles;
  @override
  @JsonKey()
  List<SubtitleCue> get subtitles {
    if (_subtitles is EqualUnmodifiableListView) return _subtitles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subtitles);
  }

  @override
  final SubtitleCue? currentCue;
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final bool isVisible;
  @override
  @JsonKey(ignore: true)
  final TextStyle? style;

  @override
  String toString() {
    return 'SubtitleState(subtitles: $subtitles, currentCue: $currentCue, language: $language, isVisible: $isVisible, style: $style)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtitleStateImpl &&
            const DeepCollectionEquality()
                .equals(other._subtitles, _subtitles) &&
            (identical(other.currentCue, currentCue) ||
                other.currentCue == currentCue) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            const DeepCollectionEquality().equals(other.style, style));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_subtitles),
      currentCue,
      language,
      isVisible,
      const DeepCollectionEquality().hash(style));

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubtitleStateImplCopyWith<_$SubtitleStateImpl> get copyWith =>
      __$$SubtitleStateImplCopyWithImpl<_$SubtitleStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubtitleStateImplToJson(
      this,
    );
  }
}

abstract class _SubtitleState implements SubtitleState {
  const factory _SubtitleState(
      {final List<SubtitleCue> subtitles,
      final SubtitleCue? currentCue,
      final String language,
      final bool isVisible,
      @JsonKey(ignore: true) final TextStyle? style}) = _$SubtitleStateImpl;

  factory _SubtitleState.fromJson(Map<String, dynamic> json) =
      _$SubtitleStateImpl.fromJson;

  @override
  List<SubtitleCue> get subtitles;
  @override
  SubtitleCue? get currentCue;
  @override
  String get language;
  @override
  bool get isVisible;
  @override
  @JsonKey(ignore: true)
  TextStyle? get style;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtitleStateImplCopyWith<_$SubtitleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubtitleCue _$SubtitleCueFromJson(Map<String, dynamic> json) {
  return _SubtitleCue.fromJson(json);
}

/// @nodoc
mixin _$SubtitleCue {
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  Duration get start => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  Duration get end => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  /// Serializes this SubtitleCue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubtitleCue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubtitleCueCopyWith<SubtitleCue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubtitleCueCopyWith<$Res> {
  factory $SubtitleCueCopyWith(
          SubtitleCue value, $Res Function(SubtitleCue) then) =
      _$SubtitleCueCopyWithImpl<$Res, SubtitleCue>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      Duration start,
      @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      Duration end,
      String text});
}

/// @nodoc
class _$SubtitleCueCopyWithImpl<$Res, $Val extends SubtitleCue>
    implements $SubtitleCueCopyWith<$Res> {
  _$SubtitleCueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubtitleCue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as Duration,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as Duration,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubtitleCueImplCopyWith<$Res>
    implements $SubtitleCueCopyWith<$Res> {
  factory _$$SubtitleCueImplCopyWith(
          _$SubtitleCueImpl value, $Res Function(_$SubtitleCueImpl) then) =
      __$$SubtitleCueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      Duration start,
      @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      Duration end,
      String text});
}

/// @nodoc
class __$$SubtitleCueImplCopyWithImpl<$Res>
    extends _$SubtitleCueCopyWithImpl<$Res, _$SubtitleCueImpl>
    implements _$$SubtitleCueImplCopyWith<$Res> {
  __$$SubtitleCueImplCopyWithImpl(
      _$SubtitleCueImpl _value, $Res Function(_$SubtitleCueImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubtitleCue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? text = null,
  }) {
    return _then(_$SubtitleCueImpl(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as Duration,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as Duration,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubtitleCueImpl implements _SubtitleCue {
  const _$SubtitleCueImpl(
      {@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      required this.start,
      @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      required this.end,
      required this.text});

  factory _$SubtitleCueImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubtitleCueImplFromJson(json);

  @override
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration start;
  @override
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  final Duration end;
  @override
  final String text;

  @override
  String toString() {
    return 'SubtitleCue(start: $start, end: $end, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtitleCueImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, start, end, text);

  /// Create a copy of SubtitleCue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubtitleCueImplCopyWith<_$SubtitleCueImpl> get copyWith =>
      __$$SubtitleCueImplCopyWithImpl<_$SubtitleCueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubtitleCueImplToJson(
      this,
    );
  }
}

abstract class _SubtitleCue implements SubtitleCue {
  const factory _SubtitleCue(
      {@JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      required final Duration start,
      @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
      required final Duration end,
      required final String text}) = _$SubtitleCueImpl;

  factory _SubtitleCue.fromJson(Map<String, dynamic> json) =
      _$SubtitleCueImpl.fromJson;

  @override
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  Duration get start;
  @override
  @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
  Duration get end;
  @override
  String get text;

  /// Create a copy of SubtitleCue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtitleCueImplCopyWith<_$SubtitleCueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
