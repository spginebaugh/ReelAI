import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/features/videos/providers/video_edit_provider.dart';

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

  void updatePlayingState(bool isPlaying) {
    ref
        .read(videoEditControllerProvider.notifier)
        .updatePlayingState(isPlaying);
  }

  void processVideo() {
    ref.read(videoEditControllerProvider.notifier).processVideo();
  }
}
