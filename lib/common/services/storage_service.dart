import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/common/utils/storage_paths.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/common/utils/error_handler.dart';
import 'package:reel_ai/common/utils/transaction_decorator.dart';
import 'package:reel_ai/common/utils/transaction_middleware.dart';

part 'storage_service.g.dart';

@riverpod
StorageService storageService(StorageServiceRef ref) => StorageService();

class StorageService extends BaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Video Operations
  Future<String> uploadVideo({
    required String userId,
    required String videoId,
    required File videoFile,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'userId': userId,
            'videoId': videoId,
            'videoFile': videoFile,
          },
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
            'videoId': (value) =>
                value?.toString().isEmpty == true ? 'Video ID is required' : '',
            'videoFile': (value) =>
                value == null || !File(value.path).existsSync()
                    ? 'Valid video file is required'
                    : '',
          },
        );

        final videoRef = _storage.ref(StoragePaths.videoFile(userId, videoId));

        final uploadTask = await videoRef.putFile(
          videoFile.absolute,
          SettableMetadata(
            contentType: 'video/mp4',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'userId': userId,
              'videoId': videoId,
            },
          ),
        );

        return uploadTask.ref.getDownloadURL();
      },
      operationName: 'uploadVideo',
      context: {
        'userId': userId,
        'videoId': videoId,
        'filePath': videoFile.path,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<String?> uploadThumbnail({
    required String userId,
    required String videoId,
    required File thumbnailFile,
  }) async {
    return executeOperation(
      operation: () async {
        if (!thumbnailFile.existsSync()) {
          return null;
        }

        final thumbnailRef =
            _storage.ref(StoragePaths.thumbnailFile(userId, videoId));

        final uploadTask = await thumbnailRef.putFile(
          thumbnailFile.absolute,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'userId': userId,
              'videoId': videoId,
            },
          ),
        );

        return uploadTask.ref.getDownloadURL();
      },
      operationName: 'uploadThumbnail',
      context: {
        'userId': userId,
        'videoId': videoId,
        'filePath': thumbnailFile.path,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<void> deleteVideoContent({
    required String userId,
    required String videoId,
  }) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'userId': userId,
            'videoId': videoId,
          },
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
            'videoId': (value) =>
                value?.toString().isEmpty == true ? 'Video ID is required' : '',
          },
        );

        final realErrors = <String>[];

        // Get reference to the video's root directory
        final videoRef =
            _storage.ref(StoragePaths.videoDirectory(userId, videoId));

        try {
          // List all items in the directory
          final ListResult result = await videoRef.listAll();

          // Delete all files in parallel
          await Future.wait([
            ...result.items.map((ref) => ref.delete()),
            ...result.prefixes
                .map((prefix) => _deleteDirectoryRecursive(prefix)),
          ]);
        } catch (e) {
          if (e is FirebaseException && e.code == 'object-not-found') {
            // Ignore if directory doesn't exist
            return;
          }
          realErrors.add('Failed to delete video content: $e');
        }

        // Only throw if we had real errors (not "not found" errors)
        if (realErrors.isNotEmpty) {
          throw AppError(
            title: 'Storage Error',
            message: 'Failed to delete video content',
            category: ErrorCategory.storage,
            severity: ErrorSeverity.error,
            context: {'errors': realErrors},
          );
        }
      },
      operationName: 'deleteVideoContent',
      context: {
        'userId': userId,
        'videoId': videoId,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  // Helper method to recursively delete a directory
  Future<void> _deleteDirectoryRecursive(Reference ref) async {
    return executeOperation(
      operation: () async {
        final ListResult result = await ref.listAll();
        await Future.wait([
          ...result.items.map((item) => item.delete()),
          ...result.prefixes.map((prefix) => _deleteDirectoryRecursive(prefix)),
        ]);
      },
      operationName: '_deleteDirectoryRecursive',
      context: {'path': ref.fullPath},
      errorCategory: ErrorCategory.storage,
    );
  }

  // User Profile Operations
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'userId': userId,
            'imageFile': imageFile,
          },
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
            'imageFile': (value) =>
                value == null || !File(value.path).existsSync()
                    ? 'Valid image file is required'
                    : '',
          },
        );

        final profileRef = _storage.ref(StoragePaths.profilePicture(userId));

        final uploadTask = await profileRef.putFile(
          imageFile,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'userId': userId,
            },
          ),
        );

        return uploadTask.ref.getDownloadURL();
      },
      operationName: 'uploadProfilePicture',
      context: {
        'userId': userId,
        'filePath': imageFile.path,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  // Temporary Upload Operations
  Future<String> uploadTemporaryFile({
    required String userId,
    required File file,
    required String fileName,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'userId': userId,
            'file': file,
            'fileName': fileName,
          },
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
            'file': (value) => value == null || !File(value.path).existsSync()
                ? 'Valid file is required'
                : '',
            'fileName': (value) => value?.toString().isEmpty == true
                ? 'File name is required'
                : '',
          },
        );

        final tempRef =
            _storage.ref(StoragePaths.temporaryFile(userId, fileName));
        final uploadTask = await tempRef.putFile(file);
        return uploadTask.ref.getDownloadURL();
      },
      operationName: 'uploadTemporaryFile',
      context: {
        'userId': userId,
        'fileName': fileName,
        'filePath': file.path,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<void> deleteTemporaryFile({
    required String userId,
    required String fileName,
  }) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'userId': userId,
            'fileName': fileName,
          },
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
            'fileName': (value) => value?.toString().isEmpty == true
                ? 'File name is required'
                : '',
          },
        );

        final tempRef =
            _storage.ref(StoragePaths.temporaryFile(userId, fileName));
        await tempRef.delete();
      },
      operationName: 'deleteTemporaryFile',
      context: {
        'userId': userId,
        'fileName': fileName,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  // Public Asset Operations
  Future<String> getDefaultAssetUrl(String assetName) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {'assetName': assetName},
          validators: {
            'assetName': (value) => value?.toString().isEmpty == true
                ? 'Asset name is required'
                : '',
          },
        );

        final assetRef = _storage.ref(StoragePaths.publicAsset(assetName));
        return await assetRef.getDownloadURL();
      },
      operationName: 'getDefaultAssetUrl',
      context: {'assetName': assetName},
      errorCategory: ErrorCategory.storage,
    );
  }

  @WithTransaction(
    category: ErrorCategory.storage,
    middleware: [AsyncTrackingMiddleware, ResourceTrackingMiddleware],
  )
  Future<String> uploadAudio({
    required String userId,
    required String videoId,
    required File audioFile,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'userId': userId,
            'videoId': videoId,
            'audioFile': audioFile,
          },
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
            'videoId': (value) =>
                value?.toString().isEmpty == true ? 'Video ID is required' : '',
            'audioFile': (value) =>
                value == null || !File(value.path).existsSync()
                    ? 'Valid audio file is required'
                    : '',
          },
        );

        final audioRef = _storage.ref(StoragePaths.audioFile(userId, videoId));

        final uploadTask = await audioRef.putFile(
          audioFile,
          SettableMetadata(
            contentType: 'audio/wav',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'userId': userId,
              'videoId': videoId,
            },
          ),
        );

        return uploadTask.ref.getDownloadURL();
      },
      operationName: 'uploadAudio',
      context: {
        'userId': userId,
        'videoId': videoId,
        'filePath': audioFile.path,
      },
      errorCategory: ErrorCategory.storage,
    );
  }
}
