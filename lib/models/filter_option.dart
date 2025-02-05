import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_option.freezed.dart';
part 'filter_option.g.dart';

@freezed
class FilterOption with _$FilterOption {
  const factory FilterOption({
    required String name,
    required String ffmpegCommand,
  }) = _FilterOption;

  factory FilterOption.fromJson(Map<String, dynamic> json) =>
      _$FilterOptionFromJson(json);

  static const none = FilterOption(
    name: 'none',
    ffmpegCommand: '',
  );
}

// Extension to convert from the old map structure
extension FilterOptionX on Map<String, String> {
  List<FilterOption> toFilterOptions() {
    return entries
        .map((e) => FilterOption(
              name: e.key,
              ffmpegCommand: e.value,
            ))
        .toList();
  }
}
