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
  bool get isEnabled => throw _privateConstructorUsedError;
  List<SubtitleEntry> get entries => throw _privateConstructorUsedError;
  String? get currentText => throw _privateConstructorUsedError;

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
  $Res call({bool isEnabled, List<SubtitleEntry> entries, String? currentText});
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
    Object? isEnabled = null,
    Object? entries = null,
    Object? currentText = freezed,
  }) {
    return _then(_value.copyWith(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<SubtitleEntry>,
      currentText: freezed == currentText
          ? _value.currentText
          : currentText // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
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
  $Res call({bool isEnabled, List<SubtitleEntry> entries, String? currentText});
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
    Object? isEnabled = null,
    Object? entries = null,
    Object? currentText = freezed,
  }) {
    return _then(_$SubtitleStateImpl(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<SubtitleEntry>,
      currentText: freezed == currentText
          ? _value.currentText
          : currentText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubtitleStateImpl implements _SubtitleState {
  const _$SubtitleStateImpl(
      {this.isEnabled = false,
      final List<SubtitleEntry> entries = const [],
      this.currentText})
      : _entries = entries;

  factory _$SubtitleStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubtitleStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isEnabled;
  final List<SubtitleEntry> _entries;
  @override
  @JsonKey()
  List<SubtitleEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  final String? currentText;

  @override
  String toString() {
    return 'SubtitleState(isEnabled: $isEnabled, entries: $entries, currentText: $currentText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtitleStateImpl &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.currentText, currentText) ||
                other.currentText == currentText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isEnabled,
      const DeepCollectionEquality().hash(_entries), currentText);

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
      {final bool isEnabled,
      final List<SubtitleEntry> entries,
      final String? currentText}) = _$SubtitleStateImpl;

  factory _SubtitleState.fromJson(Map<String, dynamic> json) =
      _$SubtitleStateImpl.fromJson;

  @override
  bool get isEnabled;
  @override
  List<SubtitleEntry> get entries;
  @override
  String? get currentText;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtitleStateImplCopyWith<_$SubtitleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
