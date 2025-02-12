import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:reel_ai/common/utils/json_utils.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String username,
    required String email,
    String? bio,
    String? profilePictureUrl,
    String? profileThumbnailUrl,
    @Default(false) bool isDeleted,
    @Default(null) String? deletedAt,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() @Default(null) DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
