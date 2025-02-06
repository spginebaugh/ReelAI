import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
class Video with _$Video {
  const Video._();

  @JsonSerializable(explicitToJson: true)
  const factory Video({
    required String id,
    required String uploaderId,
    required String title,
    String? description,
    required String videoUrl,
    required String audioUrl,
    String? thumbnailUrl,
    @TimestampConverter() required DateTime uploadTime,
    @Default('public') String privacy,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isProcessing,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}
