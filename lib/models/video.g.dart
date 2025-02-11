// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoImpl _$$VideoImplFromJson(Map<String, dynamic> json) => _$VideoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoUrl: json['videoUrl'] as String,
      audioUrl: json['audioUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      uploadTime:
          const TimestampConverter().fromJson(json['uploadTime'] as Timestamp),
      privacy: json['privacy'] as String? ?? 'public',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      isProcessing: json['isProcessing'] as bool? ?? false,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      updatedAt:
          const TimestampConverter().fromJson(json['updatedAt'] as Timestamp),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$VideoImplToJson(_$VideoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'videoUrl': instance.videoUrl,
      'audioUrl': instance.audioUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'uploadTime': const TimestampConverter().toJson(instance.uploadTime),
      'privacy': instance.privacy,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'viewsCount': instance.viewsCount,
      'isProcessing': instance.isProcessing,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'isDeleted': instance.isDeleted,
    };
