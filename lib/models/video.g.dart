// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoImpl _$$VideoImplFromJson(Map<String, dynamic> json) => _$VideoImpl(
      id: json['id'] as String,
      uploaderId: json['uploaderId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      uploadTime:
          const TimestampConverter().fromJson(json['uploadTime'] as Timestamp),
      privacy: json['privacy'] as String? ?? 'public',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      isProcessing: json['isProcessing'] as bool? ?? false,
    );

Map<String, dynamic> _$$VideoImplToJson(_$VideoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uploaderId': instance.uploaderId,
      'title': instance.title,
      'description': instance.description,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'uploadTime': const TimestampConverter().toJson(instance.uploadTime),
      'privacy': instance.privacy,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'isProcessing': instance.isProcessing,
    };
