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
  bool get isProcessing => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isPlaying => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;
  EditingMode get currentMode => throw _privateConstructorUsedError;
  double get startValue => throw _privateConstructorUsedError;
  double get endValue => throw _privateConstructorUsedError;
  double get brightness => throw _privateConstructorUsedError;
  FilterOption get selectedFilter => throw _privateConstructorUsedError;
  List<FilterOption> get availableFilters => throw _privateConstructorUsedError;
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
      {bool isProcessing,
      bool isLoading,
      bool isPlaying,
      bool isInitialized,
      EditingMode currentMode,
      double startValue,
      double endValue,
      double brightness,
      FilterOption selectedFilter,
      List<FilterOption> availableFilters,
      @FileConverter() File? tempVideoFile,
      String? currentPreviewPath,
      String? processedVideoPath,
      @JsonKey(ignore: true)
      @VideoPlayerControllerConverter()
      VideoPlayerController? videoPlayerController,
      @JsonKey(ignore: true)
      @ChewieControllerConverter()
      ChewieController? chewieController});

  $FilterOptionCopyWith<$Res> get selectedFilter;
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
    Object? isProcessing = null,
    Object? isLoading = null,
    Object? isPlaying = null,
    Object? isInitialized = null,
    Object? currentMode = null,
    Object? startValue = null,
    Object? endValue = null,
    Object? brightness = null,
    Object? selectedFilter = null,
    Object? availableFilters = null,
    Object? tempVideoFile = freezed,
    Object? currentPreviewPath = freezed,
    Object? processedVideoPath = freezed,
    Object? videoPlayerController = freezed,
    Object? chewieController = freezed,
  }) {
    return _then(_value.copyWith(
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      currentMode: null == currentMode
          ? _value.currentMode
          : currentMode // ignore: cast_nullable_to_non_nullable
              as EditingMode,
      startValue: null == startValue
          ? _value.startValue
          : startValue // ignore: cast_nullable_to_non_nullable
              as double,
      endValue: null == endValue
          ? _value.endValue
          : endValue // ignore: cast_nullable_to_non_nullable
              as double,
      brightness: null == brightness
          ? _value.brightness
          : brightness // ignore: cast_nullable_to_non_nullable
              as double,
      selectedFilter: null == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as FilterOption,
      availableFilters: null == availableFilters
          ? _value.availableFilters
          : availableFilters // ignore: cast_nullable_to_non_nullable
              as List<FilterOption>,
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
    ) as $Val);
  }

  /// Create a copy of VideoEditState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FilterOptionCopyWith<$Res> get selectedFilter {
    return $FilterOptionCopyWith<$Res>(_value.selectedFilter, (value) {
      return _then(_value.copyWith(selectedFilter: value) as $Val);
    });
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
      {bool isProcessing,
      bool isLoading,
      bool isPlaying,
      bool isInitialized,
      EditingMode currentMode,
      double startValue,
      double endValue,
      double brightness,
      FilterOption selectedFilter,
      List<FilterOption> availableFilters,
      @FileConverter() File? tempVideoFile,
      String? currentPreviewPath,
      String? processedVideoPath,
      @JsonKey(ignore: true)
      @VideoPlayerControllerConverter()
      VideoPlayerController? videoPlayerController,
      @JsonKey(ignore: true)
      @ChewieControllerConverter()
      ChewieController? chewieController});

  @override
  $FilterOptionCopyWith<$Res> get selectedFilter;
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
    Object? isProcessing = null,
    Object? isLoading = null,
    Object? isPlaying = null,
    Object? isInitialized = null,
    Object? currentMode = null,
    Object? startValue = null,
    Object? endValue = null,
    Object? brightness = null,
    Object? selectedFilter = null,
    Object? availableFilters = null,
    Object? tempVideoFile = freezed,
    Object? currentPreviewPath = freezed,
    Object? processedVideoPath = freezed,
    Object? videoPlayerController = freezed,
    Object? chewieController = freezed,
  }) {
    return _then(_$VideoEditStateImpl(
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      currentMode: null == currentMode
          ? _value.currentMode
          : currentMode // ignore: cast_nullable_to_non_nullable
              as EditingMode,
      startValue: null == startValue
          ? _value.startValue
          : startValue // ignore: cast_nullable_to_non_nullable
              as double,
      endValue: null == endValue
          ? _value.endValue
          : endValue // ignore: cast_nullable_to_non_nullable
              as double,
      brightness: null == brightness
          ? _value.brightness
          : brightness // ignore: cast_nullable_to_non_nullable
              as double,
      selectedFilter: null == selectedFilter
          ? _value.selectedFilter
          : selectedFilter // ignore: cast_nullable_to_non_nullable
              as FilterOption,
      availableFilters: null == availableFilters
          ? _value._availableFilters
          : availableFilters // ignore: cast_nullable_to_non_nullable
              as List<FilterOption>,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoEditStateImpl implements _VideoEditState {
  const _$VideoEditStateImpl(
      {required this.isProcessing,
      required this.isLoading,
      required this.isPlaying,
      required this.isInitialized,
      required this.currentMode,
      required this.startValue,
      required this.endValue,
      required this.brightness,
      required this.selectedFilter,
      required final List<FilterOption> availableFilters,
      @FileConverter() this.tempVideoFile,
      this.currentPreviewPath,
      this.processedVideoPath,
      @JsonKey(ignore: true)
      @VideoPlayerControllerConverter()
      this.videoPlayerController,
      @JsonKey(ignore: true)
      @ChewieControllerConverter()
      this.chewieController})
      : _availableFilters = availableFilters;

  factory _$VideoEditStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoEditStateImplFromJson(json);

  @override
  final bool isProcessing;
  @override
  final bool isLoading;
  @override
  final bool isPlaying;
  @override
  final bool isInitialized;
  @override
  final EditingMode currentMode;
  @override
  final double startValue;
  @override
  final double endValue;
  @override
  final double brightness;
  @override
  final FilterOption selectedFilter;
  final List<FilterOption> _availableFilters;
  @override
  List<FilterOption> get availableFilters {
    if (_availableFilters is EqualUnmodifiableListView)
      return _availableFilters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableFilters);
  }

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
  String toString() {
    return 'VideoEditState(isProcessing: $isProcessing, isLoading: $isLoading, isPlaying: $isPlaying, isInitialized: $isInitialized, currentMode: $currentMode, startValue: $startValue, endValue: $endValue, brightness: $brightness, selectedFilter: $selectedFilter, availableFilters: $availableFilters, tempVideoFile: $tempVideoFile, currentPreviewPath: $currentPreviewPath, processedVideoPath: $processedVideoPath, videoPlayerController: $videoPlayerController, chewieController: $chewieController)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoEditStateImpl &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.currentMode, currentMode) ||
                other.currentMode == currentMode) &&
            (identical(other.startValue, startValue) ||
                other.startValue == startValue) &&
            (identical(other.endValue, endValue) ||
                other.endValue == endValue) &&
            (identical(other.brightness, brightness) ||
                other.brightness == brightness) &&
            (identical(other.selectedFilter, selectedFilter) ||
                other.selectedFilter == selectedFilter) &&
            const DeepCollectionEquality()
                .equals(other._availableFilters, _availableFilters) &&
            (identical(other.tempVideoFile, tempVideoFile) ||
                other.tempVideoFile == tempVideoFile) &&
            (identical(other.currentPreviewPath, currentPreviewPath) ||
                other.currentPreviewPath == currentPreviewPath) &&
            (identical(other.processedVideoPath, processedVideoPath) ||
                other.processedVideoPath == processedVideoPath) &&
            (identical(other.videoPlayerController, videoPlayerController) ||
                other.videoPlayerController == videoPlayerController) &&
            (identical(other.chewieController, chewieController) ||
                other.chewieController == chewieController));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isProcessing,
      isLoading,
      isPlaying,
      isInitialized,
      currentMode,
      startValue,
      endValue,
      brightness,
      selectedFilter,
      const DeepCollectionEquality().hash(_availableFilters),
      tempVideoFile,
      currentPreviewPath,
      processedVideoPath,
      videoPlayerController,
      chewieController);

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
      {required final bool isProcessing,
      required final bool isLoading,
      required final bool isPlaying,
      required final bool isInitialized,
      required final EditingMode currentMode,
      required final double startValue,
      required final double endValue,
      required final double brightness,
      required final FilterOption selectedFilter,
      required final List<FilterOption> availableFilters,
      @FileConverter() final File? tempVideoFile,
      final String? currentPreviewPath,
      final String? processedVideoPath,
      @JsonKey(ignore: true)
      @VideoPlayerControllerConverter()
      final VideoPlayerController? videoPlayerController,
      @JsonKey(ignore: true)
      @ChewieControllerConverter()
      final ChewieController? chewieController}) = _$VideoEditStateImpl;

  factory _VideoEditState.fromJson(Map<String, dynamic> json) =
      _$VideoEditStateImpl.fromJson;

  @override
  bool get isProcessing;
  @override
  bool get isLoading;
  @override
  bool get isPlaying;
  @override
  bool get isInitialized;
  @override
  EditingMode get currentMode;
  @override
  double get startValue;
  @override
  double get endValue;
  @override
  double get brightness;
  @override
  FilterOption get selectedFilter;
  @override
  List<FilterOption> get availableFilters;
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

  /// Create a copy of VideoEditState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoEditStateImplCopyWith<_$VideoEditStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
