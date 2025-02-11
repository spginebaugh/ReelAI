import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../models/video_edit_state.dart';
import '../../../../state/video_edit_provider.dart';

part 'playback_speed_controller.g.dart';

@riverpod
class PlaybackSpeedController extends _$PlaybackSpeedController {
  static const List<double> speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void build() {
    // No initial state needed
  }

  void setSpeed(double speed) {
    final state = ref.read(videoEditControllerProvider);
    state.whenData((data) {
      if (data.videoPlayerController != null) {
        data.videoPlayerController!.setPlaybackSpeed(speed);
      }
    });
  }
}
