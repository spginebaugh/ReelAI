import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'video.freezed.dart';
part 'video.g.dart';

@freezed
class Video with _$Video {
  const Video._();

  const factory Video({
    required String id,
    required String uploaderId,
    required String title,
    String? description,
    required String videoUrl,
    String? thumbnailUrl,
    @JsonKey(
      fromJson: Video._timestampFromJson,
      toJson: Video._timestampToJson,
    )
    required DateTime uploadTime,
    @Default('public') String privacy,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(false) bool isProcessing,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    throw Exception('Invalid timestamp format');
  }

  static dynamic _timestampToJson(DateTime dateTime) =>
      Timestamp.fromDate(dateTime);
}
