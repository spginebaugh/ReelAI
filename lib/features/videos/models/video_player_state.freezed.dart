// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AudioState _$AudioStateFromJson(Map<String, dynamic> json) {
  return _AudioState.fromJson(json);
}

/// @nodoc
mixin _$AudioState {
  bool get isEnabled => throw _privateConstructorUsedError;
  String get currentLanguage => throw _privateConstructorUsedError;
  List<String> get availableLanguages => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this AudioState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioStateCopyWith<AudioState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioStateCopyWith<$Res> {
  factory $AudioStateCopyWith(
          AudioState value, $Res Function(AudioState) then) =
      _$AudioStateCopyWithImpl<$Res, AudioState>;
  @useResult
  $Res call(
      {bool isEnabled,
      String currentLanguage,
      List<String> availableLanguages,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$AudioStateCopyWithImpl<$Res, $Val extends AudioState>
    implements $AudioStateCopyWith<$Res> {
  _$AudioStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? currentLanguage = null,
    Object? availableLanguages = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      availableLanguages: null == availableLanguages
          ? _value.availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioStateImplCopyWith<$Res>
    implements $AudioStateCopyWith<$Res> {
  factory _$$AudioStateImplCopyWith(
          _$AudioStateImpl value, $Res Function(_$AudioStateImpl) then) =
      __$$AudioStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isEnabled,
      String currentLanguage,
      List<String> availableLanguages,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$AudioStateImplCopyWithImpl<$Res>
    extends _$AudioStateCopyWithImpl<$Res, _$AudioStateImpl>
    implements _$$AudioStateImplCopyWith<$Res> {
  __$$AudioStateImplCopyWithImpl(
      _$AudioStateImpl _value, $Res Function(_$AudioStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? currentLanguage = null,
    Object? availableLanguages = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$AudioStateImpl(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      availableLanguages: null == availableLanguages
          ? _value._availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioStateImpl implements _AudioState {
  const _$AudioStateImpl(
      {required this.isEnabled,
      required this.currentLanguage,
      required final List<String> availableLanguages,
      required this.isLoading,
      this.error})
      : _availableLanguages = availableLanguages;

  factory _$AudioStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioStateImplFromJson(json);

  @override
  final bool isEnabled;
  @override
  final String currentLanguage;
  final List<String> _availableLanguages;
  @override
  List<String> get availableLanguages {
    if (_availableLanguages is EqualUnmodifiableListView)
      return _availableLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableLanguages);
  }

  @override
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'AudioState(isEnabled: $isEnabled, currentLanguage: $currentLanguage, availableLanguages: $availableLanguages, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioStateImpl &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.currentLanguage, currentLanguage) ||
                other.currentLanguage == currentLanguage) &&
            const DeepCollectionEquality()
                .equals(other._availableLanguages, _availableLanguages) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isEnabled,
      currentLanguage,
      const DeepCollectionEquality().hash(_availableLanguages),
      isLoading,
      error);

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioStateImplCopyWith<_$AudioStateImpl> get copyWith =>
      __$$AudioStateImplCopyWithImpl<_$AudioStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioStateImplToJson(
      this,
    );
  }
}

abstract class _AudioState implements AudioState {
  const factory _AudioState(
      {required final bool isEnabled,
      required final String currentLanguage,
      required final List<String> availableLanguages,
      required final bool isLoading,
      final String? error}) = _$AudioStateImpl;

  factory _AudioState.fromJson(Map<String, dynamic> json) =
      _$AudioStateImpl.fromJson;

  @override
  bool get isEnabled;
  @override
  String get currentLanguage;
  @override
  List<String> get availableLanguages;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of AudioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioStateImplCopyWith<_$AudioStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubtitleState _$SubtitleStateFromJson(Map<String, dynamic> json) {
  return _SubtitleState.fromJson(json);
}

/// @nodoc
mixin _$SubtitleState {
  bool get isEnabled => throw _privateConstructorUsedError;
  String get currentLanguage => throw _privateConstructorUsedError;
  List<String> get availableLanguages => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get currentText => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

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
      String currentLanguage,
      List<String> availableLanguages,
      bool isLoading,
      String? currentText,
      String? error});
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
    Object? currentLanguage = null,
    Object? availableLanguages = null,
    Object? isLoading = null,
    Object? currentText = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      availableLanguages: null == availableLanguages
          ? _value.availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      currentText: freezed == currentText
          ? _value.currentText
          : currentText // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
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
      String currentLanguage,
      List<String> availableLanguages,
      bool isLoading,
      String? currentText,
      String? error});
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
    Object? currentLanguage = null,
    Object? availableLanguages = null,
    Object? isLoading = null,
    Object? currentText = freezed,
    Object? error = freezed,
  }) {
    return _then(_$SubtitleStateImpl(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      availableLanguages: null == availableLanguages
          ? _value._availableLanguages
          : availableLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      currentText: freezed == currentText
          ? _value.currentText
          : currentText // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubtitleStateImpl implements _SubtitleState {
  const _$SubtitleStateImpl(
      {required this.isEnabled,
      required this.currentLanguage,
      required final List<String> availableLanguages,
      required this.isLoading,
      this.currentText,
      this.error})
      : _availableLanguages = availableLanguages;

  factory _$SubtitleStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubtitleStateImplFromJson(json);

  @override
  final bool isEnabled;
  @override
  final String currentLanguage;
  final List<String> _availableLanguages;
  @override
  List<String> get availableLanguages {
    if (_availableLanguages is EqualUnmodifiableListView)
      return _availableLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableLanguages);
  }

  @override
  final bool isLoading;
  @override
  final String? currentText;
  @override
  final String? error;

  @override
  String toString() {
    return 'SubtitleState(isEnabled: $isEnabled, currentLanguage: $currentLanguage, availableLanguages: $availableLanguages, isLoading: $isLoading, currentText: $currentText, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtitleStateImpl &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.currentLanguage, currentLanguage) ||
                other.currentLanguage == currentLanguage) &&
            const DeepCollectionEquality()
                .equals(other._availableLanguages, _availableLanguages) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.currentText, currentText) ||
                other.currentText == currentText) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isEnabled,
      currentLanguage,
      const DeepCollectionEquality().hash(_availableLanguages),
      isLoading,
      currentText,
      error);

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
      {required final bool isEnabled,
      required final String currentLanguage,
      required final List<String> availableLanguages,
      required final bool isLoading,
      final String? currentText,
      final String? error}) = _$SubtitleStateImpl;

  factory _SubtitleState.fromJson(Map<String, dynamic> json) =
      _$SubtitleStateImpl.fromJson;

  @override
  bool get isEnabled;
  @override
  String get currentLanguage;
  @override
  List<String> get availableLanguages;
  @override
  bool get isLoading;
  @override
  String? get currentText;
  @override
  String? get error;

  /// Create a copy of SubtitleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtitleStateImplCopyWith<_$SubtitleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoPlayerState _$VideoPlayerStateFromJson(Map<String, dynamic> json) {
  return _VideoPlayerState.fromJson(json);
}

/// @nodoc
mixin _$VideoPlayerState {
  VideoPlayerStatus get status => throw _privateConstructorUsedError;
  VideoMode get mode => throw _privateConstructorUsedError;
  AudioState get audio => throw _privateConstructorUsedError;
  SubtitleState get subtitles => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  VideoPlayerController? get videoController =>
      throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  ChewieController? get chewieController => throw _privateConstructorUsedError;
  @FileConverter()
  File? get videoFile => throw _privateConstructorUsedError;
  Video? get video => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this VideoPlayerState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoPlayerStateCopyWith<VideoPlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoPlayerStateCopyWith<$Res> {
  factory $VideoPlayerStateCopyWith(
          VideoPlayerState value, $Res Function(VideoPlayerState) then) =
      _$VideoPlayerStateCopyWithImpl<$Res, VideoPlayerState>;
  @useResult
  $Res call(
      {VideoPlayerStatus status,
      VideoMode mode,
      AudioState audio,
      SubtitleState subtitles,
      @JsonKey(ignore: true) VideoPlayerController? videoController,
      @JsonKey(ignore: true) ChewieController? chewieController,
      @FileConverter() File? videoFile,
      Video? video,
      String? error});

  $AudioStateCopyWith<$Res> get audio;
  $SubtitleStateCopyWith<$Res> get subtitles;
  $VideoCopyWith<$Res>? get video;
}

/// @nodoc
class _$VideoPlayerStateCopyWithImpl<$Res, $Val extends VideoPlayerState>
    implements $VideoPlayerStateCopyWith<$Res> {
  _$VideoPlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? mode = null,
    Object? audio = null,
    Object? subtitles = null,
    Object? videoController = freezed,
    Object? chewieController = freezed,
    Object? videoFile = freezed,
    Object? video = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VideoPlayerStatus,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as VideoMode,
      audio: null == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as AudioState,
      subtitles: null == subtitles
          ? _value.subtitles
          : subtitles // ignore: cast_nullable_to_non_nullable
              as SubtitleState,
      videoController: freezed == videoController
          ? _value.videoController
          : videoController // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController?,
      chewieController: freezed == chewieController
          ? _value.chewieController
          : chewieController // ignore: cast_nullable_to_non_nullable
              as ChewieController?,
      videoFile: freezed == videoFile
          ? _value.videoFile
          : videoFile // ignore: cast_nullable_to_non_nullable
              as File?,
      video: freezed == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as Video?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AudioStateCopyWith<$Res> get audio {
    return $AudioStateCopyWith<$Res>(_value.audio, (value) {
      return _then(_value.copyWith(audio: value) as $Val);
    });
  }

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubtitleStateCopyWith<$Res> get subtitles {
    return $SubtitleStateCopyWith<$Res>(_value.subtitles, (value) {
      return _then(_value.copyWith(subtitles: value) as $Val);
    });
  }

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoCopyWith<$Res>? get video {
    if (_value.video == null) {
      return null;
    }

    return $VideoCopyWith<$Res>(_value.video!, (value) {
      return _then(_value.copyWith(video: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoPlayerStateImplCopyWith<$Res>
    implements $VideoPlayerStateCopyWith<$Res> {
  factory _$$VideoPlayerStateImplCopyWith(_$VideoPlayerStateImpl value,
          $Res Function(_$VideoPlayerStateImpl) then) =
      __$$VideoPlayerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {VideoPlayerStatus status,
      VideoMode mode,
      AudioState audio,
      SubtitleState subtitles,
      @JsonKey(ignore: true) VideoPlayerController? videoController,
      @JsonKey(ignore: true) ChewieController? chewieController,
      @FileConverter() File? videoFile,
      Video? video,
      String? error});

  @override
  $AudioStateCopyWith<$Res> get audio;
  @override
  $SubtitleStateCopyWith<$Res> get subtitles;
  @override
  $VideoCopyWith<$Res>? get video;
}

/// @nodoc
class __$$VideoPlayerStateImplCopyWithImpl<$Res>
    extends _$VideoPlayerStateCopyWithImpl<$Res, _$VideoPlayerStateImpl>
    implements _$$VideoPlayerStateImplCopyWith<$Res> {
  __$$VideoPlayerStateImplCopyWithImpl(_$VideoPlayerStateImpl _value,
      $Res Function(_$VideoPlayerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? mode = null,
    Object? audio = null,
    Object? subtitles = null,
    Object? videoController = freezed,
    Object? chewieController = freezed,
    Object? videoFile = freezed,
    Object? video = freezed,
    Object? error = freezed,
  }) {
    return _then(_$VideoPlayerStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VideoPlayerStatus,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as VideoMode,
      audio: null == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as AudioState,
      subtitles: null == subtitles
          ? _value.subtitles
          : subtitles // ignore: cast_nullable_to_non_nullable
              as SubtitleState,
      videoController: freezed == videoController
          ? _value.videoController
          : videoController // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController?,
      chewieController: freezed == chewieController
          ? _value.chewieController
          : chewieController // ignore: cast_nullable_to_non_nullable
              as ChewieController?,
      videoFile: freezed == videoFile
          ? _value.videoFile
          : videoFile // ignore: cast_nullable_to_non_nullable
              as File?,
      video: freezed == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as Video?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoPlayerStateImpl implements _VideoPlayerState {
  const _$VideoPlayerStateImpl(
      {required this.status,
      required this.mode,
      required this.audio,
      required this.subtitles,
      @JsonKey(ignore: true) this.videoController,
      @JsonKey(ignore: true) this.chewieController,
      @FileConverter() this.videoFile,
      this.video,
      this.error});

  factory _$VideoPlayerStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoPlayerStateImplFromJson(json);

  @override
  final VideoPlayerStatus status;
  @override
  final VideoMode mode;
  @override
  final AudioState audio;
  @override
  final SubtitleState subtitles;
  @override
  @JsonKey(ignore: true)
  final VideoPlayerController? videoController;
  @override
  @JsonKey(ignore: true)
  final ChewieController? chewieController;
  @override
  @FileConverter()
  final File? videoFile;
  @override
  final Video? video;
  @override
  final String? error;

  @override
  String toString() {
    return 'VideoPlayerState(status: $status, mode: $mode, audio: $audio, subtitles: $subtitles, videoController: $videoController, chewieController: $chewieController, videoFile: $videoFile, video: $video, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoPlayerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.subtitles, subtitles) ||
                other.subtitles == subtitles) &&
            (identical(other.videoController, videoController) ||
                other.videoController == videoController) &&
            (identical(other.chewieController, chewieController) ||
                other.chewieController == chewieController) &&
            (identical(other.videoFile, videoFile) ||
                other.videoFile == videoFile) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, mode, audio, subtitles,
      videoController, chewieController, videoFile, video, error);

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoPlayerStateImplCopyWith<_$VideoPlayerStateImpl> get copyWith =>
      __$$VideoPlayerStateImplCopyWithImpl<_$VideoPlayerStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoPlayerStateImplToJson(
      this,
    );
  }
}

abstract class _VideoPlayerState implements VideoPlayerState {
  const factory _VideoPlayerState(
      {required final VideoPlayerStatus status,
      required final VideoMode mode,
      required final AudioState audio,
      required final SubtitleState subtitles,
      @JsonKey(ignore: true) final VideoPlayerController? videoController,
      @JsonKey(ignore: true) final ChewieController? chewieController,
      @FileConverter() final File? videoFile,
      final Video? video,
      final String? error}) = _$VideoPlayerStateImpl;

  factory _VideoPlayerState.fromJson(Map<String, dynamic> json) =
      _$VideoPlayerStateImpl.fromJson;

  @override
  VideoPlayerStatus get status;
  @override
  VideoMode get mode;
  @override
  AudioState get audio;
  @override
  SubtitleState get subtitles;
  @override
  @JsonKey(ignore: true)
  VideoPlayerController? get videoController;
  @override
  @JsonKey(ignore: true)
  ChewieController? get chewieController;
  @override
  @FileConverter()
  File? get videoFile;
  @override
  Video? get video;
  @override
  String? get error;

  /// Create a copy of VideoPlayerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoPlayerStateImplCopyWith<_$VideoPlayerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
