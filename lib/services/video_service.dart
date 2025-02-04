import 'dart:io';
import '../models/video.dart';
import 'firestore_service.dart';
import 'storage_service.dart';
import 'package:uuid/uuid.dart';

class VideoService {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  VideoService({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  Stream<List<Video>> getVideos() {
    return _firestoreService.getPublicVideos();
  }

  Stream<List<Video>> getUserVideos(String userId) {
    return _firestoreService.getUserVideos(userId);
  }

  Future<Video?> getVideo(String videoId) {
    return _firestoreService.getVideo(videoId);
  }

  Future<String> uploadVideo({
    required String userId,
    required File videoFile,
    File? thumbnailFile,
    required String title,
    required String description,
    String privacy = 'public',
  }) async {
    // Verify video file exists
    if (!videoFile.existsSync()) {
      throw Exception('Video file does not exist at path: ${videoFile.path}');
    }

    final videoId = const Uuid().v4();

    // Upload video and get URL
    final videoUrl = await _storageService.uploadVideo(
      userId: userId,
      videoId: videoId,
      videoFile: videoFile,
    );

    // Upload thumbnail if provided
    String? thumbnailUrl;
    if (thumbnailFile != null) {
      if (thumbnailFile.existsSync()) {
        thumbnailUrl = await _storageService.uploadThumbnail(
          userId: userId,
          videoId: videoId,
          thumbnailFile: thumbnailFile,
        );
      }
    }

    // Create the video document with all required fields
    final video = Video(
      id: '', // Will be set by Firestore
      uploaderId: userId,
      title: title,
      description: description,
      privacy: privacy,
      uploadTime: DateTime.now(),
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      likesCount: 0,
      commentsCount: 0,
      isProcessing: false,
    );

    // Create the video document in Firestore
    final createdVideoId = await _firestoreService.createVideo(video);

    return createdVideoId;
  }

  Future<void> deleteVideo({
    required String userId,
    required String videoId,
  }) async {
    // Delete storage files first
    await _storageService.deleteVideoContent(
      userId: userId,
      videoId: videoId,
    );

    // Then delete the Firestore document
    await _firestoreService.deleteVideo(videoId);
  }

  Future<void> incrementLikes(String videoId) {
    return _firestoreService.incrementVideoLikes(videoId);
  }

  Future<void> incrementComments(String videoId) {
    return _firestoreService.incrementVideoComments(videoId);
  }
}
