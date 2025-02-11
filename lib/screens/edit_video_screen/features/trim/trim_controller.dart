import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../models/video_edit_state.dart';
import '../../../../state/video_edit_provider.dart';

part 'trim_controller.g.dart';

@riverpod
class TrimController extends _$TrimController {
  @override
  void build() {
    // No initial state needed
  }

  void updateStartValue(double value) {
    ref.read(videoEditControllerProvider.notifier).updateStartValue(value);
  }

  void updateEndValue(double value) {
    ref.read(videoEditControllerProvider.notifier).updateEndValue(value);
  }

  void updatePlaybackState(bool isPlaying) {
    ref
        .read(videoEditControllerProvider.notifier)
        .updatePlaybackState(isPlaying);
  }

  void processVideo() {
    ref.read(videoEditControllerProvider.notifier).processVideo();
  }
}
