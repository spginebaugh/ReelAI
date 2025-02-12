import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/services/video/controller_manager_service.dart';

part 'video_controller_provider.g.dart';

@riverpod
VideoControllerManager videoControllerManager(VideoControllerManagerRef ref) {
  return VideoControllerManager();
}
