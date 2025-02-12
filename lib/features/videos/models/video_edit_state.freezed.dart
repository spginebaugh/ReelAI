// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_edit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VideoEditState _$VideoEditStateFromJson(Map<String, dynamic> json) {
  return _VideoEditState.fromJson(json);
}

/// @nodoc
mixin _$VideoEditState {
  VideoEditStatus get status => throw _privateConstructorUsedError;
  EditingMode get currentMode => throw _privateConstructorUsedError;
  @FileConverter()
  File? get tempVideoFile => throw _privateConstructorUsedError;
  String? get currentPreviewPath => throw _privateConstructorUsedError;
  String? get processedVideoPath => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  @VideoPlayerControllerConverter()
  VideoPlayerController? get videoPlayerController =>
      throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  @ChewieControllerConverter()
  ChewieController? get chewieController => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this VideoEditState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoEditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoEditStateCopyWith<VideoEditState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoEditStateCopyWith<$Res> {
  factory $VideoEditStateCopyWith(
          VideoEditState value, $Res Function(VideoEditState) then) =
      _$VideoEditStateCopyWithImpl<$Res, VideoEditState>;
  @useResult
  $Res call(
      {VideoEditStatus status,
      EditingMode currentMode,
      @FileConverter() File? tempVideoFile,
      String? currentPreviewPath,
      String? processedVideoPath,
      @JsonKey(ignore: true)
      @VideoPlayerControllerConverter()
      VideoPlayerController? videoPlayerController,
      @JsonKey(ignore: true)
      @ChewieControllerConverter()
      ChewieController? chewieController,
      String? errorMessage});
}

/// @nodoc
class _$VideoEditStateCopyWithImpl<$Res, $Val extends VideoEditState>
    implements $VideoEditStateCopyWith<$Res> {
  _$VideoEditStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoEditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentMode = null,
    Object? tempVideoFile = freezed,
    Object? currentPreviewPath = freezed,
    Object? processedVideoPath = freezed,
    Object? videoPlayerController = freezed,
    Object? chewieController = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VideoEditStatus,
      currentMode: null == currentMode
          ? _value.currentMode
          : currentMode // ignore: cast_nullable_to_non_nullable
              as EditingMode,
      tempVideoFile: freezed == tempVideoFile
          ? _value.tempVideoFile
          : tempVideoFile // ignore: cast_nullable_to_non_nullable
              as File?,
      currentPreviewPath: freezed == currentPreviewPath
          ? _value.currentPreviewPath
          : currentPreviewPath // ignore: cast_nullable_to_non_nullable
              as String?,
      processedVideoPath: freezed == processedVideoPath
          ? _value.processedVideoPath
          : processedVideoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      videoPlayerController: freezed == videoPlayerController
          ? _value.videoPlayerController
          : videoPlayerController // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController?,
      chewieController: freezed == chewieController
          ? _value.chewieController
          : chewieController // ignore: cast_nullable_to_non_nullable
              as ChewieController?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoEditStateImplCopyWith<$Res>
    implements $VideoEditStateCopyWith<$Res> {
  factory _$$VideoEditStateImplCopyWith(_$VideoEditStateImpl value,
          $Res Function(_$VideoEditStateImpl) then) =
      __$$VideoEditStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {VideoEditStatus status,
      EditingMode currentMode,
      @FileConverter() File? tempVideoFile,
      String? currentPreviewPath,
      String? processedVideoPath,
      @JsonKey(ignore: true)
      @VideoPlayerControllerConverter()
      VideoPlayerController? videoPlayerController,
      @JsonKey(ignore: true)
      @ChewieControllerConverter()
      ChewieController? chewieController,
      String? errorMessage});
}

/// @nodoc
class __$$VideoEditStateImplCopyWithImpl<$Res>
    extends _$VideoEditStateCopyWithImpl<$Res, _$VideoEditStateImpl>
    implements _$$VideoEditStateImplCopyWith<$Res> {
  __$$VideoEditStateImplCopyWithImpl(
      _$VideoEditStateImpl _value, $Res Function(_$VideoEditStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoEditState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? currentMode = null,
    Object? tempVideoFile = freezed,
    Object? currentPreviewPath = freezed,
    Object? processedVideoPath = freezed,
    Object? videoPlayerController = freezed,
    Object? chewieController = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$VideoEditStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VideoEditStatus,
      currentMode: null == currentMode
          ? _value.currentMode
          : currentMode // ignore: cast_nullable_to_non_nullable
              as EditingMode,
      tempVideoFile: freezed == tempVideoFile
          ? _value.tempVideoFile
          : tempVideoFile // ignore: cast_nullable_to_non_nullable
              as File?,
      currentPreviewPath: freezed == currentPreviewPath
          ? _value.currentPreviewPath
          : currentPreviewPath // ignore: cast_nullable_to_non_nullable
              as String?,
      processedVideoPath: freezed == processedVideoPath
          ? _value.processedVideoPath
          : processedVideoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      videoPlayerController: freezed == videoPlayerController
          ? _value.videoPlayerController
          : videoPlayerController // ignore: cast_nullable_to_non_nullable
              as VideoPlayerController?,
      chewieController: freezed == chewieController
          ? _value.chewieController
          : chewieController // ignore: cast_nullable_to_non_nullable
              as ChewieController?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoEditStateImpl implements _VideoEditState {
  const _$VideoEditStateImpl(
      {required this.status,
      required this.currentMode,
      @FileConverter() this.tempVideoFile,
      this.currentPreviewPath,
      this.processedVideoPath,
      @JsonKey(ignore: true)
      @VideoPlayerControllerConverter()
      this.videoPlayerController,
      @JsonKey(ignore: true) @ChewieControllerConverter() this.chewieController,
      this.errorMessage});

  factory _$VideoEditStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoEditStateImplFromJson(json);

  @override
  final VideoEditStatus status;
  @override
  final EditingMode currentMode;
  @override
  @FileConverter()
  final File? tempVideoFile;
  @override
  final String? currentPreviewPath;
  @override
  final String? processedVideoPath;
  @override
  @JsonKey(ignore: true)
  @VideoPlayerControllerConverter()
  final VideoPlayerController? videoPlayerController;
  @override
  @JsonKey(ignore: true)
  @ChewieControllerConverter()
  final ChewieController? chewieController;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'VideoEditState(status: $status, currentMode: $currentMode, tempVideoFile: $tempVideoFile, currentPreviewPath: $currentPreviewPath, processedVideoPath: $processedVideoPath, videoPlayerController: $videoPlayerController, chewieController: $chewieController, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoEditStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentMode, currentMode) ||
                other.currentMode == currentMode) &&
            (identical(other.tempVideoFile, tempVideoFile) ||
                other.tempVideoFile == tempVideoFile) &&
            (identical(other.currentPreviewPath, currentPreviewPath) ||
                other.currentPreviewPath == currentPreviewPath) &&
            (identical(other.processedVideoPath, processedVideoPath) ||
                other.processedVideoPath == processedVideoPath) &&
            (identical(other.videoPlayerController, videoPlayerController) ||
                other.videoPlayerController == videoPlayerController) &&
            (identical(other.chewieController, chewieController) ||
                other.chewieController == chewieController) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      currentMode,
      tempVideoFile,
      currentPreviewPath,
      processedVideoPath,
      videoPlayerController,
      chewieController,
      errorMessage);

  /// Create a copy of VideoEditState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoEditStateImplCopyWith<_$VideoEditStateImpl> get copyWith =>
      __$$VideoEditStateImplCopyWithImpl<_$VideoEditStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoEditStateImplToJson(
      this,
    );
  }
}

abstract class _VideoEditState implements VideoEditState {
  const factory _VideoEditState(
      {required final VideoEditStatus status,
      required final EditingMode currentMode,
      @FileConverter() final File? tempVideoFile,
      final String? currentPreviewPath,
      final String? processedVideoPath,
      @JsonKey(ignore: true)
      @VideoPlayerControllerConverter()
      final VideoPlayerController? videoPlayerController,
      @JsonKey(ignore: true)
      @ChewieControllerConverter()
      final ChewieController? chewieController,
      final String? errorMessage}) = _$VideoEditStateImpl;

  factory _VideoEditState.fromJson(Map<String, dynamic> json) =
      _$VideoEditStateImpl.fromJson;

  @override
  VideoEditStatus get status;
  @override
  EditingMode get currentMode;
  @override
  @FileConverter()
  File? get tempVideoFile;
  @override
  String? get currentPreviewPath;
  @override
  String? get processedVideoPath;
  @override
  @JsonKey(ignore: true)
  @VideoPlayerControllerConverter()
  VideoPlayerController? get videoPlayerController;
  @override
  @JsonKey(ignore: true)
  @ChewieControllerConverter()
  ChewieController? get chewieController;
  @override
  String? get errorMessage;

  /// Create a copy of VideoEditState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoEditStateImplCopyWith<_$VideoEditStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
