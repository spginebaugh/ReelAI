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
import 'base_service.dart';
import '../utils/error_handler.dart';
import '../utils/transaction_decorator.dart';
import '../utils/transaction_middleware.dart';

part 'video_service.g.dart';

@riverpod
VideoService videoService(VideoServiceRef ref) {
  return VideoService(
    firestoreService: ref.watch(firestoreServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
}

class VideoService extends BaseService {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FFmpegService _ffmpegService = FFmpegService();

  VideoService({
    required FirestoreService firestoreService,
    required StorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  @WithTransaction(
    category: ErrorCategory.video,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Stream<List<Video>> getVideos() {
    return _firestoreService.getPublicVideos();
  }

  @WithTransaction(
    category: ErrorCategory.video,
    middleware: [AsyncTrackingMiddleware, StateTrackingMiddleware],
  )
  Stream<List<Video>> getUserVideos(String userId) {
    return _firestoreService.getUserVideos(userId);
  }

  @WithTransaction(
    category: ErrorCategory.video,
    middleware: [AsyncTrackingMiddleware],
  )
  Future<Video?> getVideo(String videoId) {
    return executeOperation(
      operation: () => _firestoreService.getVideo(videoId),
      operationName: 'getVideo',
      context: {'videoId': videoId},
      errorCategory: ErrorCategory.database,
    );
  }

  @WithTransaction(
    category: ErrorCategory.video,
    middleware: [
      AsyncTrackingMiddleware,
      NetworkTrackingMiddleware,
      StateTrackingMiddleware,
      ResourceTrackingMiddleware,
    ],
  )
  Future<String> uploadVideo({
    required String userId,
    required File videoFile,
    File? thumbnailFile,
    required String title,
    required String description,
    String privacy = 'public',
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'userId': userId,
            'videoFile': videoFile,
            'title': title,
            'description': description,
          },
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
            'videoFile': (value) =>
                value == null || !File(value.path).existsSync()
                    ? 'Valid video file is required'
                    : '',
            'title': (value) =>
                value?.toString().isEmpty == true ? 'Title is required' : '',
            'description': (value) => value?.toString().isEmpty == true
                ? 'Description is required'
                : '',
          },
        );

        final videoId = _firestoreService.generateVideoId().id;
        String? videoUrl;
        String? audioUrl;

        try {
          // Upload video file
          videoUrl = await _storageService.uploadVideo(
            userId: userId,
            videoId: videoId,
            videoFile: videoFile,
          );

          // Extract and upload audio if needed
          final audioFile = await _ffmpegService.extractAudio(videoFile.path);
          audioUrl = await _storageService.uploadAudio(
            userId: userId,
            videoId: videoId,
            audioFile: File(audioFile),
          );

          // Create video document
          await _firestoreService.createVideo({
            'id': videoId,
            'userId': userId,
            'title': title,
            'description': description,
            'videoUrl': videoUrl,
            'audioUrl': audioUrl,
            'thumbnailUrl': null, // Will be updated later
            'privacy': privacy,
            'status': 'processing',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return videoId;
        } catch (e) {
          // Clean up any uploaded files
          await executeMultipleCleanups(
            cleanups: [
              if (videoUrl != null)
                () => _storage
                    .ref(StoragePaths.videoFile(userId, videoId))
                    .delete(),
              if (audioUrl != null)
                () => _storage
                    .ref(StoragePaths.audioFile(userId, videoId))
                    .delete(),
            ],
            cleanupName: 'uploadVideoCleanup',
            context: {
              'userId': userId,
              'videoId': videoId,
            },
          );
          rethrow;
        }
      },
      operationName: 'uploadVideo',
      context: {
        'userId': userId,
        'title': title,
        'privacy': privacy,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  @WithTransaction(
    category: ErrorCategory.video,
    middleware: [
      AsyncTrackingMiddleware,
      NetworkTrackingMiddleware,
      ResourceTrackingMiddleware,
    ],
  )
  Future<(String videoUrl, String audioUrl)> uploadVideoWithAudio(
    String videoPath,
    String userId, {
    required String videoId,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'videoPath': videoPath,
            'userId': userId,
            'videoId': videoId,
          },
          validators: {
            'videoPath': (value) => value?.toString().isEmpty == true
                ? 'Video path is required'
                : '',
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
            'videoId': (value) =>
                value?.toString().isEmpty == true ? 'Video ID is required' : '',
          },
        );

        final videoFile = File(videoPath);
        if (!await videoFile.exists()) {
          throw AppError(
            title: 'File Error',
            message: 'Video file not found',
            category: ErrorCategory.video,
            severity: ErrorSeverity.error,
          );
        }

        // Upload video
        final videoUrl = await _storageService.uploadVideo(
          userId: userId,
          videoId: videoId,
          videoFile: videoFile,
        );

        // Extract and upload audio
        final audioFile = await _ffmpegService.extractAudio(videoPath);
        final audioUrl = await _storageService.uploadAudio(
          userId: userId,
          videoId: videoId,
          audioFile: File(audioFile),
        );

        return (videoUrl, audioUrl);
      },
      operationName: 'uploadVideoWithAudio',
      context: {
        'userId': userId,
        'videoId': videoId,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<void> deleteVideo({
    required String userId,
    required String videoId,
  }) async {
    await executeOperation(
      operation: () async {
        // Delete storage files first
        await _storageService.deleteVideoContent(
          userId: userId,
          videoId: videoId,
        );

        // Then delete the Firestore document
        await _firestoreService.deleteVideo(videoId);
      },
      operationName: 'deleteVideo',
      context: {
        'userId': userId,
        'videoId': videoId,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<void> incrementLikes(String videoId) {
    return executeOperation(
      operation: () => _firestoreService.incrementVideoLikes(videoId),
      operationName: 'incrementLikes',
      context: {'videoId': videoId},
      errorCategory: ErrorCategory.database,
    );
  }

  Future<void> incrementComments(String videoId) {
    return executeOperation(
      operation: () => _firestoreService.incrementVideoComments(videoId),
      operationName: 'incrementComments',
      context: {'videoId': videoId},
      errorCategory: ErrorCategory.database,
    );
  }

  Future<void> updateVideoMetadata({
    required String videoId,
    required String title,
    required String description,
  }) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'videoId': videoId,
            'title': title,
            'description': description,
          },
          validators: {
            'videoId': (value) =>
                value?.toString().isEmpty == true ? 'Video ID is required' : '',
            'title': (value) =>
                value?.toString().isEmpty == true ? 'Title is required' : '',
            'description': (value) => value?.toString().isEmpty == true
                ? 'Description is required'
                : '',
          },
        );

        await _firestoreService.updateVideo(
          videoId,
          {
            'title': title,
            'description': description,
            'updatedAt': DateTime.now(),
          },
        );
      },
      operationName: 'updateVideoMetadata',
      context: {
        'videoId': videoId,
        'title': title,
      },
      errorCategory: ErrorCategory.database,
    );
  }
}
