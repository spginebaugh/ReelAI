import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../models/video_edit_state.dart';
import '../../../../models/filter_option.dart';
import '../../../../state/video_edit_provider.dart';

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
