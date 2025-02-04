import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user.freezed.dart';
part 'user.g.dart';

DateTime _timestampFromJson(Timestamp timestamp) => timestamp.toDate();
Timestamp _timestampToJson(DateTime dateTime) => Timestamp.fromDate(dateTime);

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
    String? deletedAt,
    @JsonKey(
      fromJson: _timestampFromJson,
      toJson: _timestampToJson,
    )
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
