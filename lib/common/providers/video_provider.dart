import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/common/services/video_service.dart';
import 'package:reel_ai/common/services/firestore_service.dart';
import 'package:reel_ai/common/services/storage_service.dart';

part 'video_provider.g.dart';

@riverpod
VideoService videoService(VideoServiceRef ref) => VideoService(
      firestoreService: ref.watch(firestoreServiceProvider),
      storageService: ref.watch(storageServiceProvider),
    );

// Stream provider to listen for videos from Firestore
@riverpod
Stream<List<Video>> videos(VideosRef ref) {
  return ref.watch(videoServiceProvider).getVideos().map(
        (videos) => videos.map((video) => video).toList(),
      );
}

// Stream provider for user's videos
@riverpod
Stream<List<Video>> userVideos(UserVideosRef ref, String userId) {
  return ref.watch(videoServiceProvider).getUserVideos(userId).map(
        (videos) => videos.map((video) => video).toList(),
      );
}
