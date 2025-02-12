import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/features/videos/services/media/video_media_service.dart';

part 'video_media_provider.g.dart';

/// Provider for the VideoMediaService
@Riverpod(keepAlive: true)
VideoMediaService videoMedia(VideoMediaRef ref) {
  return VideoMediaService();
}
