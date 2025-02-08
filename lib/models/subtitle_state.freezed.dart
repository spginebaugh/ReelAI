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
  List<String> get availableLanguages => throw _privateConstructorUsedError;
  String get currentLanguage => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSwitching => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

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
      {bool isEnabled,
      List<SubtitleEntry> entries,
      String? currentText,
      List<String> availableLanguages,
      String currentLanguage,
      bool isInitialized,
      bool isLoading,
      bool isSwitching,
      bool hasError,
      String? errorMessage});
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
    Object? availableLanguages = null,
    Object? currentLanguage = null,
    Object? isInitialized = null,
    Object? isLoading = null,
    Object? isSwitching = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
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
      availableLanguages: null == availableLanguages
          ? _value.availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSwitching: null == isSwitching
          ? _value.isSwitching
          : isSwitching // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
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
  $Res call(
      {bool isEnabled,
      List<SubtitleEntry> entries,
      String? currentText,
      List<String> availableLanguages,
      String currentLanguage,
      bool isInitialized,
      bool isLoading,
      bool isSwitching,
      bool hasError,
      String? errorMessage});
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
    Object? availableLanguages = null,
    Object? currentLanguage = null,
    Object? isInitialized = null,
    Object? isLoading = null,
    Object? isSwitching = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
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
      availableLanguages: null == availableLanguages
          ? _value._availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSwitching: null == isSwitching
          ? _value.isSwitching
          : isSwitching // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
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
      this.currentText,
      final List<String> availableLanguages = const [],
      this.currentLanguage = 'english',
      this.isInitialized = false,
      this.isLoading = false,
      this.isSwitching = false,
      this.hasError = false,
      this.errorMessage})
      : _entries = entries,
        _availableLanguages = availableLanguages;

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
  final List<String> _availableLanguages;
  @override
  @JsonKey()
  List<String> get availableLanguages {
    if (_availableLanguages is EqualUnmodifiableListView)
      return _availableLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableLanguages);
  }

  @override
  @JsonKey()
  final String currentLanguage;
  @override
  @JsonKey()
  final bool isInitialized;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSwitching;
  @override
  @JsonKey()
  final bool hasError;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'SubtitleState(isEnabled: $isEnabled, entries: $entries, currentText: $currentText, availableLanguages: $availableLanguages, currentLanguage: $currentLanguage, isInitialized: $isInitialized, isLoading: $isLoading, isSwitching: $isSwitching, hasError: $hasError, errorMessage: $errorMessage)';
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
                other.currentText == currentText) &&
            const DeepCollectionEquality()
                .equals(other._availableLanguages, _availableLanguages) &&
            (identical(other.currentLanguage, currentLanguage) ||
                other.currentLanguage == currentLanguage) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSwitching, isSwitching) ||
                other.isSwitching == isSwitching) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isEnabled,
      const DeepCollectionEquality().hash(_entries),
      currentText,
      const DeepCollectionEquality().hash(_availableLanguages),
      currentLanguage,
      isInitialized,
      isLoading,
      isSwitching,
      hasError,
      errorMessage);

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
      final String? currentText,
      final List<String> availableLanguages,
      final String currentLanguage,
      final bool isInitialized,
      final bool isLoading,
      final bool isSwitching,
      final bool hasError,
      final String? errorMessage}) = _$SubtitleStateImpl;

  factory _SubtitleState.fromJson(Map<String, dynamic> json) =
      _$SubtitleStateImpl.fromJson;

  @override
  bool get isEnabled;
  @override
  List<SubtitleEntry> get entries;
  @override
  String? get currentText;
  @override
  List<String> get availableLanguages;
  @override
  String get currentLanguage;
  @override
  bool get isInitialized;
  @override
  bool get isLoading;
  @override
  bool get isSwitching;
  @override
  bool get hasError;
  @override
  String? get errorMessage;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtitleStateImplCopyWith<_$SubtitleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
