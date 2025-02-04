import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video.dart';
import '../services/video_service.dart';

// Provider for VideoService instance
final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService();
});

// Stream provider to listen for videos from Firestore
final videosStreamProvider = StreamProvider<List<Video>>((ref) {
  final videoService = ref.watch(videoServiceProvider);
  return videoService.getVideos();
});
