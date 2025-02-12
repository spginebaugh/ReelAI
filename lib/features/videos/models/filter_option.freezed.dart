// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FilterOption _$FilterOptionFromJson(Map<String, dynamic> json) {
  return _FilterOption.fromJson(json);
}

/// @nodoc
mixin _$FilterOption {
  String get name => throw _privateConstructorUsedError;
  String get ffmpegCommand => throw _privateConstructorUsedError;

  /// Serializes this FilterOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FilterOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FilterOptionCopyWith<FilterOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FilterOptionCopyWith<$Res> {
  factory $FilterOptionCopyWith(
          FilterOption value, $Res Function(FilterOption) then) =
      _$FilterOptionCopyWithImpl<$Res, FilterOption>;
  @useResult
  $Res call({String name, String ffmpegCommand});
}

/// @nodoc
class _$FilterOptionCopyWithImpl<$Res, $Val extends FilterOption>
    implements $FilterOptionCopyWith<$Res> {
  _$FilterOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FilterOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? ffmpegCommand = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ffmpegCommand: null == ffmpegCommand
          ? _value.ffmpegCommand
          : ffmpegCommand // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FilterOptionImplCopyWith<$Res>
    implements $FilterOptionCopyWith<$Res> {
  factory _$$FilterOptionImplCopyWith(
          _$FilterOptionImpl value, $Res Function(_$FilterOptionImpl) then) =
      __$$FilterOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String ffmpegCommand});
}

/// @nodoc
class __$$FilterOptionImplCopyWithImpl<$Res>
    extends _$FilterOptionCopyWithImpl<$Res, _$FilterOptionImpl>
    implements _$$FilterOptionImplCopyWith<$Res> {
  __$$FilterOptionImplCopyWithImpl(
      _$FilterOptionImpl _value, $Res Function(_$FilterOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of FilterOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? ffmpegCommand = null,
  }) {
    return _then(_$FilterOptionImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ffmpegCommand: null == ffmpegCommand
          ? _value.ffmpegCommand
          : ffmpegCommand // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FilterOptionImpl implements _FilterOption {
  const _$FilterOptionImpl({required this.name, required this.ffmpegCommand});

  factory _$FilterOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FilterOptionImplFromJson(json);

  @override
  final String name;
  @override
  final String ffmpegCommand;

  @override
  String toString() {
    return 'FilterOption(name: $name, ffmpegCommand: $ffmpegCommand)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterOptionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ffmpegCommand, ffmpegCommand) ||
                other.ffmpegCommand == ffmpegCommand));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, ffmpegCommand);

  /// Create a copy of FilterOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterOptionImplCopyWith<_$FilterOptionImpl> get copyWith =>
      __$$FilterOptionImplCopyWithImpl<_$FilterOptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FilterOptionImplToJson(
      this,
    );
  }
}

abstract class _FilterOption implements FilterOption {
  const factory _FilterOption(
      {required final String name,
      required final String ffmpegCommand}) = _$FilterOptionImpl;

  factory _FilterOption.fromJson(Map<String, dynamic> json) =
      _$FilterOptionImpl.fromJson;

  @override
  String get name;
  @override
  String get ffmpegCommand;

  /// Create a copy of FilterOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FilterOptionImplCopyWith<_$FilterOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
