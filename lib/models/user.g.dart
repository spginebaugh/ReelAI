// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      profileThumbnailUrl: json['profileThumbnailUrl'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] as String?,
      createdAt: _timestampFromJson(json['createdAt'] as Timestamp),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'bio': instance.bio,
      'profilePictureUrl': instance.profilePictureUrl,
      'profileThumbnailUrl': instance.profileThumbnailUrl,
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
