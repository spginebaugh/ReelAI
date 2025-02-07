import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/video.dart';
import 'firestore_service.dart';
import 'storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'ffmpeg_service.dart';
import 'package:flutter/foundation.dart';
import '../utils/storage_paths.dart';

part 'video_service.g.dart';

@riverpod
VideoService videoService(VideoServiceRef ref) {
  return VideoService(
    firestoreService: ref.watch(firestoreServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
}

class VideoService {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FFmpegService _ffmpegService = FFmpegService();

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

    // Generate a Firestore document reference first to get its ID
    final docRef = _firestoreService.generateVideoId();
    final videoId = docRef.id;
    String? videoUrl;
    String? audioUrl;

    try {
      // Upload video and audio, get URLs
      final uploadResult = await uploadVideoWithAudio(
        videoFile.path,
        userId,
        videoId: videoId, // Pass the Firestore ID to use for storage
      );
      videoUrl = uploadResult.$1;
      audioUrl = uploadResult.$2;

      // Upload thumbnail if provided
      String? thumbnailUrl;
      if (thumbnailFile != null && thumbnailFile.existsSync()) {
        thumbnailUrl = await _storageService.uploadThumbnail(
          userId: userId,
          videoId: videoId,
          thumbnailFile: thumbnailFile,
        );
      }

      final now = DateTime.now();

      // Create the video document with all required fields
      final video = Video(
        id: videoId,
        uploaderId: userId,
        title: title,
        description: description,
        privacy: privacy,
        uploadTime: now,
        videoUrl: videoUrl,
        audioUrl: audioUrl,
        thumbnailUrl: thumbnailUrl,
        likesCount: 0,
        commentsCount: 0,
        isProcessing: false,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      // Convert to a Map and explicitly set Timestamps for Firestore
      final videoData = video.toJson();
      videoData['createdAt'] = Timestamp.fromDate(now);
      videoData['updatedAt'] = Timestamp.fromDate(now);
      videoData['uploadTime'] = Timestamp.fromDate(now);

      // Create the video document in Firestore using the same ID
      await _firestoreService.createVideo(videoData, docRef);

      return videoId;
    } catch (e) {
      // Clean up any uploaded files in case of error
      if (videoUrl != null || audioUrl != null) {
        try {
          await _storageService.deleteVideoContent(
            userId: userId,
            videoId: videoId,
          );
        } catch (cleanupError) {
          debugPrint('Error cleaning up failed upload: $cleanupError');
        }
      }
      rethrow;
    }
  }

  Future<(String videoUrl, String audioUrl)> uploadVideoWithAudio(
    String videoPath,
    String userId, {
    required String videoId,
  }) async {
    String? audioPath;
    String? videoFileName;
    String? audioFileName;

    try {
      // Extract audio first
      audioPath = await _ffmpegService.extractAudio(videoPath);
      if (audioPath == null) {
        throw Exception('Failed to extract audio from video');
      }

      // Use StoragePaths utility for consistent path generation
      videoFileName = StoragePaths.videoFile(userId, videoId);
      audioFileName = StoragePaths.audioFile(userId, videoId);

      // Upload both files concurrently
      final videoUpload = _storage.ref(videoFileName).putFile(File(videoPath));
      final audioUpload = _storage.ref(audioFileName).putFile(File(audioPath));

      // Wait for both uploads to complete
      final results = await Future.wait([
        videoUpload,
        audioUpload,
      ]);

      // Get download URLs
      final videoUrl = await results[0].ref.getDownloadURL();
      final audioUrl = await results[1].ref.getDownloadURL();

      // Clean up temporary audio file
      await File(audioPath).delete();

      return (videoUrl, audioUrl);
    } catch (e) {
      // Clean up any uploaded files
      if (videoFileName != null) {
        try {
          await _storage.ref(videoFileName).delete();
        } catch (_) {
          // Ignore cleanup errors
        }
      }
      if (audioFileName != null) {
        try {
          await _storage.ref(audioFileName).delete();
        } catch (_) {
          // Ignore cleanup errors
        }
      }
      // Clean up temporary audio file
      if (audioPath != null) {
        try {
          await File(audioPath).delete();
        } catch (_) {
          // Ignore cleanup errors
        }
      }
      throw Exception('Failed to upload video and audio: $e');
    }
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

  Future<void> updateVideoMetadata({
    required String videoId,
    required String title,
    required String description,
  }) async {
    await _firestoreService.updateVideo(
      videoId,
      {
        'title': title,
        'description': description,
        'updatedAt': DateTime.now(),
      },
    );
  }
}
