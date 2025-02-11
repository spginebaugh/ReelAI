import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../models/video_edit_state.dart';
import '../../../../state/video_edit_provider.dart';

part 'brightness_controller.g.dart';

@riverpod
class BrightnessController extends _$BrightnessController {
  @override
  void build() {
    // No initial state needed
  }

  void updateBrightness(double value) {
    ref.read(videoEditControllerProvider.notifier).updateBrightness(value);
  }

  void applyBrightness() {
    ref.read(videoEditControllerProvider.notifier).applyFilters();
  }
}
