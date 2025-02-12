import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/features/videos/models/filter_option.dart';
import 'package:reel_ai/features/videos/providers/video_edit_provider.dart';

part 'filter_controller.g.dart';

@riverpod
class FilterController extends _$FilterController {
  @override
  void build() {
    // No initial state needed
  }

  void updateFilter(FilterOption filter) {
    ref.read(videoEditControllerProvider.notifier).updateFilter(filter);
  }
}
