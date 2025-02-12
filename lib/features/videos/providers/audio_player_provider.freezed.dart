// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_player_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AudioPlayerState _$AudioPlayerStateFromJson(Map<String, dynamic> json) {
  return _AudioPlayerState.fromJson(json);
}

/// @nodoc
mixin _$AudioPlayerState {
  @JsonKey(toJson: _audioPlayerToJson, fromJson: _audioPlayerFromJson)
  AudioPlayer? get audioPlayer => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;
  bool get isPlaying => throw _privateConstructorUsedError;
  @JsonKey(toJson: _durationToJson, fromJson: _durationFromJson)
  Duration get position => throw _privateConstructorUsedError;
  String get currentLanguage => throw _privateConstructorUsedError;
  bool get isSyncing => throw _privateConstructorUsedError;

  /// Serializes this AudioPlayerState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioPlayerStateCopyWith<AudioPlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioPlayerStateCopyWith<$Res> {
  factory $AudioPlayerStateCopyWith(
          AudioPlayerState value, $Res Function(AudioPlayerState) then) =
      _$AudioPlayerStateCopyWithImpl<$Res, AudioPlayerState>;
  @useResult
  $Res call(
      {@JsonKey(toJson: _audioPlayerToJson, fromJson: _audioPlayerFromJson)
      AudioPlayer? audioPlayer,
      bool isInitialized,
      bool isPlaying,
      @JsonKey(toJson: _durationToJson, fromJson: _durationFromJson)
      Duration position,
      String currentLanguage,
      bool isSyncing});
}

/// @nodoc
class _$AudioPlayerStateCopyWithImpl<$Res, $Val extends AudioPlayerState>
    implements $AudioPlayerStateCopyWith<$Res> {
  _$AudioPlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioPlayer = freezed,
    Object? isInitialized = null,
    Object? isPlaying = null,
    Object? position = null,
    Object? currentLanguage = null,
    Object? isSyncing = null,
  }) {
    return _then(_value.copyWith(
      audioPlayer: freezed == audioPlayer
          ? _value.audioPlayer
          : audioPlayer // ignore: cast_nullable_to_non_nullable
              as AudioPlayer?,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioPlayerStateImplCopyWith<$Res>
    implements $AudioPlayerStateCopyWith<$Res> {
  factory _$$AudioPlayerStateImplCopyWith(_$AudioPlayerStateImpl value,
          $Res Function(_$AudioPlayerStateImpl) then) =
      __$$AudioPlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(toJson: _audioPlayerToJson, fromJson: _audioPlayerFromJson)
      AudioPlayer? audioPlayer,
      bool isInitialized,
      bool isPlaying,
      @JsonKey(toJson: _durationToJson, fromJson: _durationFromJson)
      Duration position,
      String currentLanguage,
      bool isSyncing});
}

/// @nodoc
class __$$AudioPlayerStateImplCopyWithImpl<$Res>
    extends _$AudioPlayerStateCopyWithImpl<$Res, _$AudioPlayerStateImpl>
    implements _$$AudioPlayerStateImplCopyWith<$Res> {
  __$$AudioPlayerStateImplCopyWithImpl(_$AudioPlayerStateImpl _value,
      $Res Function(_$AudioPlayerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioPlayer = freezed,
    Object? isInitialized = null,
    Object? isPlaying = null,
    Object? position = null,
    Object? currentLanguage = null,
    Object? isSyncing = null,
  }) {
    return _then(_$AudioPlayerStateImpl(
      audioPlayer: freezed == audioPlayer
          ? _value.audioPlayer
          : audioPlayer // ignore: cast_nullable_to_non_nullable
              as AudioPlayer?,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioPlayerStateImpl
    with DiagnosticableTreeMixin
    implements _AudioPlayerState {
  const _$AudioPlayerStateImpl(
      {@JsonKey(toJson: _audioPlayerToJson, fromJson: _audioPlayerFromJson)
      this.audioPlayer,
      this.isInitialized = false,
      this.isPlaying = false,
      @JsonKey(toJson: _durationToJson, fromJson: _durationFromJson)
      this.position = Duration.zero,
      this.currentLanguage = 'english',
      this.isSyncing = false});

  factory _$AudioPlayerStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioPlayerStateImplFromJson(json);

  @override
  @JsonKey(toJson: _audioPlayerToJson, fromJson: _audioPlayerFromJson)
  final AudioPlayer? audioPlayer;
  @override
  @JsonKey()
  final bool isInitialized;
  @override
  @JsonKey()
  final bool isPlaying;
  @override
  @JsonKey(toJson: _durationToJson, fromJson: _durationFromJson)
  final Duration position;
  @override
  @JsonKey()
  final String currentLanguage;
  @override
  @JsonKey()
  final bool isSyncing;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AudioPlayerState(audioPlayer: $audioPlayer, isInitialized: $isInitialized, isPlaying: $isPlaying, position: $position, currentLanguage: $currentLanguage, isSyncing: $isSyncing)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AudioPlayerState'))
      ..add(DiagnosticsProperty('audioPlayer', audioPlayer))
      ..add(DiagnosticsProperty('isInitialized', isInitialized))
      ..add(DiagnosticsProperty('isPlaying', isPlaying))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('currentLanguage', currentLanguage))
      ..add(DiagnosticsProperty('isSyncing', isSyncing));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioPlayerStateImpl &&
            (identical(other.audioPlayer, audioPlayer) ||
                other.audioPlayer == audioPlayer) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.currentLanguage, currentLanguage) ||
                other.currentLanguage == currentLanguage) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, audioPlayer, isInitialized,
      isPlaying, position, currentLanguage, isSyncing);

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioPlayerStateImplCopyWith<_$AudioPlayerStateImpl> get copyWith =>
      __$$AudioPlayerStateImplCopyWithImpl<_$AudioPlayerStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioPlayerStateImplToJson(
      this,
    );
  }
}

abstract class _AudioPlayerState implements AudioPlayerState {
  const factory _AudioPlayerState(
      {@JsonKey(toJson: _audioPlayerToJson, fromJson: _audioPlayerFromJson)
      final AudioPlayer? audioPlayer,
      final bool isInitialized,
      final bool isPlaying,
      @JsonKey(toJson: _durationToJson, fromJson: _durationFromJson)
      final Duration position,
      final String currentLanguage,
      final bool isSyncing}) = _$AudioPlayerStateImpl;

  factory _AudioPlayerState.fromJson(Map<String, dynamic> json) =
      _$AudioPlayerStateImpl.fromJson;

  @override
  @JsonKey(toJson: _audioPlayerToJson, fromJson: _audioPlayerFromJson)
  AudioPlayer? get audioPlayer;
  @override
  bool get isInitialized;
  @override
  bool get isPlaying;
  @override
  @JsonKey(toJson: _durationToJson, fromJson: _durationFromJson)
  Duration get position;
  @override
  String get currentLanguage;
  @override
  bool get isSyncing;

  /// Create a copy of AudioPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioPlayerStateImplCopyWith<_$AudioPlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
