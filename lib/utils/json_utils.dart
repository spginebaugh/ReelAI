import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts between DateTime and Firestore Timestamp
/// Used with @JsonKey annotations in model classes for Firestore interaction
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Converts any value to a JSON-serializable format
/// Used for API calls, logging, or any JSON serialization outside of Firestore
dynamic toJsonSafe(dynamic value) {
  if (value == null) return null;

  if (value is Timestamp) {
    return value.toDate().toIso8601String();
  }

  if (value is DateTime) {
    return value.toIso8601String();
  }

  if (value is Map) {
    return Map<String, dynamic>.from(
      value.map((key, val) => MapEntry(key.toString(), toJsonSafe(val))),
    );
  }

  if (value is Iterable) {
    return value.map(toJsonSafe).toList();
  }

  return value;
}
