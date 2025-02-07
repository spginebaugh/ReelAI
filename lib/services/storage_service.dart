import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/storage_paths.dart';

part 'storage_service.g.dart';

@riverpod
StorageService storageService(StorageServiceRef ref) => StorageService();

class StorageService {
  final _storage = FirebaseStorage.instance;

  // Video Operations
  Future<String> uploadVideo({
    required String userId,
    required String videoId,
    required File videoFile,
  }) async {
    if (!videoFile.existsSync()) {
      throw Exception('Video file does not exist at path: ${videoFile.path}');
    }

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
  }

  Future<String?> uploadThumbnail({
    required String userId,
    required String videoId,
    required File thumbnailFile,
  }) async {
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
  }

  Future<void> deleteVideoContent({
    required String userId,
    required String videoId,
  }) async {
    final realErrors = <String>[];

    try {
      // Get reference to the video's root directory
      final videoRef =
          _storage.ref(StoragePaths.videoDirectory(userId, videoId));

      try {
        // List all items in the directory
        final ListResult result = await videoRef.listAll();

        // Delete all files in parallel
        await Future.wait([
          ...result.items.map((ref) => ref.delete()),
          ...result.prefixes.map((prefix) => _deleteDirectoryRecursive(prefix)),
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
        throw Exception(
          'Failed to delete video content: ${realErrors.join(', ')}',
        );
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        // If the directory doesn't exist, that's fine
        return;
      }
      throw Exception('Failed to delete video content: $e');
    }
  }

  // Helper method to recursively delete a directory
  Future<void> _deleteDirectoryRecursive(Reference ref) async {
    try {
      final ListResult result = await ref.listAll();
      await Future.wait([
        ...result.items.map((item) => item.delete()),
        ...result.prefixes.map((prefix) => _deleteDirectoryRecursive(prefix)),
      ]);
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }

  // User Profile Operations
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
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
  }

  // Temporary Upload Operations
  Future<String> uploadTemporaryFile({
    required String userId,
    required File file,
    required String fileName,
  }) async {
    final tempRef = _storage.ref(StoragePaths.temporaryFile(userId, fileName));

    final uploadTask = await tempRef.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteTemporaryFile({
    required String userId,
    required String fileName,
  }) async {
    final tempRef = _storage.ref(StoragePaths.temporaryFile(userId, fileName));

    try {
      await tempRef.delete();
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }

  // Public Asset Operations
  Future<String> getDefaultAssetUrl(String assetName) async {
    final assetRef = _storage.ref(StoragePaths.publicAsset(assetName));
    return await assetRef.getDownloadURL();
  }
}
