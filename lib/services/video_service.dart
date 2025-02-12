import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/models/video.dart';
import 'package:reel_ai/services/firestore_service.dart';
import 'package:reel_ai/services/storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reel_ai/services/video/processing/ffmpeg_processor.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/common/utils/error_handler.dart';
import 'package:reel_ai/common/utils/transaction_decorator.dart';
import 'package:reel_ai/common/utils/transaction_middleware.dart';
import 'package:reel_ai/common/constants/constants.dart';
import 'package:reel_ai/common/utils/logger.dart';
import 'package:reel_ai/common/utils/error_context.dart';
import 'package:reel_ai/common/utils/json_utils.dart';

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
  final FFmpegProcessor _ffmpegProcessor = FFmpegProcessor();

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
        final transactionId =
            Logger.startTransaction('video_upload_operation', {
          'userId': userId,
          'title': title,
          'privacy': privacy,
        });

        try {
          // Validate input parameters
          Logger.debug('Validating input parameters');
          final validationErrors = <String>[];

          validateInput(
            parameters: {
              'userId': userId,
              'videoFile': videoFile,
              'title': title,
              'description': description,
            },
            validators: {
              'userId': (value) {
                final error = value?.toString().isEmpty == true
                    ? 'User ID is required'
                    : '';
                if (error.isNotEmpty) validationErrors.add(error);
                return error;
              },
              'videoFile': (value) {
                final error = value == null || !File(value.path).existsSync()
                    ? 'Valid video file is required'
                    : '';
                if (error.isNotEmpty) validationErrors.add(error);
                return error;
              },
              'title': (value) {
                final error = value?.toString().isEmpty == true
                    ? 'Title is required'
                    : '';
                if (error.isNotEmpty) validationErrors.add(error);
                return error;
              },
              'description': (value) {
                final error = value == null // Allow empty string, just not null
                    ? 'Description is required'
                    : '';
                if (error.isNotEmpty) validationErrors.add(error);
                return error;
              },
            },
          );

          // Validate video file size and format
          final fileSize = await videoFile.length();
          Logger.info('Validating video file', {
            'size': fileSize,
            'maxSize': VideoConstants.maxVideoSize,
            'path': videoFile.path,
          });

          if (fileSize > VideoConstants.maxVideoSize) {
            throw AppError(
              title: 'File Too Large',
              message:
                  'Video file size must be less than ${VideoConstants.maxVideoSize ~/ (1024 * 1024)}MB',
              category: ErrorCategory.validation,
              severity: ErrorSeverity.warning,
              context: {
                'fileSize': fileSize,
                'maxSize': VideoConstants.maxVideoSize,
                'filePath': videoFile.path,
              },
            );
          }

          // Generate a single ID to use for both Firestore and Storage
          final docRef = _firestoreService.generateVideoId();
          final videoId = docRef.id;

          Logger.info('Generated video ID', {
            'videoId': videoId,
            'transactionId': transactionId,
          });

          String? videoUrl;
          String? audioUrl;
          File? extractedAudioFile;

          try {
            // Upload video file
            Logger.info('Starting video file upload', {
              'videoId': videoId,
              'size': fileSize,
              'path': videoFile.path,
            });

            try {
              videoUrl = await _storageService.uploadVideo(
                userId: userId,
                videoId: videoId,
                videoFile: videoFile,
              );
              Logger.success('Video file upload completed', {
                'videoId': videoId,
                'url': videoUrl,
              });
            } catch (e) {
              Logger.error('Video file upload failed', {
                'error': e.toString(),
                'videoId': videoId,
                'path': videoFile.path,
              });
              if (e is FirebaseException) {
                final errorContext = ErrorContextBuilder()
                    .withCategory(ErrorCategory.storage)
                    .withOperationId('uploadVideo')
                    .withMetadata({
                      'videoId': videoId,
                      'userId': userId,
                      'fileSize': fileSize,
                      'filePath': videoFile.path,
                    })
                    .addBreadcrumb('Video upload failed')
                    .build();

                throw AppError(
                  title: 'Video Upload Failed',
                  message: 'Failed to upload video: ${e.message}',
                  originalError: e,
                  category: ErrorCategory.storage,
                  severity: ErrorSeverity.error,
                  code: e.code,
                  context: errorContext.toMap(),
                );
              }
              rethrow;
            }

            // Extract and upload audio
            Logger.info('Starting audio extraction', {
              'videoId': videoId,
              'videoPath': videoFile.path,
            });

            try {
              final audioPath =
                  await _ffmpegProcessor.extractAudio(videoFile.path);
              extractedAudioFile = File(audioPath);

              if (!await extractedAudioFile.exists()) {
                throw AppError(
                  title: 'Audio Extraction Failed',
                  message: 'Failed to extract audio from video',
                  category: ErrorCategory.processing,
                  severity: ErrorSeverity.error,
                  context: {
                    'videoId': videoId,
                    'videoPath': videoFile.path,
                    'audioPath': audioPath,
                  },
                );
              }
              Logger.success('Audio extraction completed', {
                'audioPath': audioPath,
              });

              Logger.info('Starting audio upload');
              audioUrl = await _storageService.uploadAudio(
                userId: userId,
                videoId: videoId,
                audioFile: extractedAudioFile,
              );
              Logger.success('Audio upload completed', {
                'videoId': videoId,
                'url': audioUrl,
              });
            } catch (e) {
              Logger.error('Audio processing failed', {
                'error': e.toString(),
                'videoId': videoId,
              });
              rethrow;
            }

            // Create video document
            final now = DateTime.now();
            final video = Video(
              id: videoId, // Use the same ID
              userId: userId,
              title: title,
              description: description,
              videoUrl: videoUrl!,
              audioUrl: audioUrl!,
              uploadTime: now,
              privacy: privacy,
              createdAt: now,
              updatedAt: now,
              isProcessing: true,
            );

            // Create the document with the same ID
            await _firestoreService.createVideo(video.toJson(), docRef);
            Logger.success('Video document created', {
              'videoId': videoId,
              'transactionId': transactionId,
            });

            return videoId;
          } finally {
            // Clean up temporary files
            if (extractedAudioFile != null &&
                await extractedAudioFile.exists()) {
              await extractedAudioFile.delete();
            }
          }
        } catch (e) {
          Logger.error('Video upload failed', {
            'error': e.toString(),
            'transactionId': transactionId,
          });
          rethrow;
        }
      },
      operationName: 'uploadVideo',
      context: {
        'userId': userId,
        'title': title,
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
        final audioFile = await _ffmpegProcessor.extractAudio(videoPath);
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
            'description': (value) =>
                value == null // Allow empty string, just not null
                    ? 'Description is required'
                    : '',
          },
        );

        final video = Video(
          id: videoId,
          userId: '', // Not needed for update
          title: title,
          description: description,
          videoUrl: '', // Not needed for update
          audioUrl: '', // Not needed for update
          uploadTime: DateTime.now(), // Not needed for update
          createdAt: DateTime.now(), // Not needed for update
          updatedAt: DateTime.now(),
          isProcessing: false, // Not needed for update
        );

        final updateData = {
          'title': title,
          'description': description,
          'updatedAt': const TimestampConverter().toJson(DateTime.now()),
        };

        await _firestoreService.updateVideo(videoId, updateData);
      },
      operationName: 'updateVideoMetadata',
      context: {
        'videoId': videoId,
        'title': title,
      },
      errorCategory: ErrorCategory.database,
    );
  }

  @WithTransaction(
    category: ErrorCategory.video,
    middleware: [AsyncTrackingMiddleware],
  )
  Future<void> createVideo(Video video) async {
    return executeOperation(
      operation: () async {
        final videoJson = video.toJson();
        final safeVideoJson = toJsonSafe(videoJson);
        await _firestoreService
            .createVideo(safeVideoJson as Map<String, dynamic>);
      },
      operationName: 'createVideo',
      context: {'videoId': video.id},
      errorCategory: ErrorCategory.database,
    );
  }

  @WithTransaction(
    category: ErrorCategory.video,
    middleware: [AsyncTrackingMiddleware],
  )
  Future<void> updateVideo(String videoId, Map<String, dynamic> data) async {
    return executeOperation(
      operation: () async {
        final safeData = toJsonSafe(data);
        await _firestoreService.updateVideo(
            videoId, safeData as Map<String, dynamic>);
      },
      operationName: 'updateVideo',
      context: {'videoId': videoId},
      errorCategory: ErrorCategory.database,
    );
  }
}
