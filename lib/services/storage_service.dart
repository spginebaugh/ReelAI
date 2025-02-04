import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

    final videoRef = _storage
        .ref()
        .child('videos')
        .child(userId)
        .child('original')
        .child(videoId)
        .child('video.mp4');

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

    final thumbnailRef = _storage
        .ref()
        .child('videos')
        .child(userId)
        .child('thumbnails')
        .child(videoId)
        .child('thumbnail.jpg');

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
    // Delete video file
    final videoRef = _storage
        .ref()
        .child('videos')
        .child(userId)
        .child('original')
        .child(videoId);

    // Delete thumbnail
    final thumbnailRef = _storage
        .ref()
        .child('videos')
        .child(userId)
        .child('thumbnails')
        .child(videoId);

    try {
      await Future.wait([
        _deleteDirectory(videoRef),
        _deleteDirectory(thumbnailRef),
      ]);
    } catch (e) {
      // If files don't exist, that's okay
      // rethrow other errors
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }

  // Helper method to delete a directory and its contents
  Future<void> _deleteDirectory(Reference ref) async {
    try {
      final ListResult result = await ref.listAll();

      await Future.wait([
        ...result.items.map((item) => item.delete()),
        ...result.prefixes.map((prefix) => _deleteDirectory(prefix)),
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
    final profileRef = _storage
        .ref()
        .child('users')
        .child(userId)
        .child('profile')
        .child('avatar.jpg');

    final uploadTask = await profileRef.putFile(
      imageFile,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
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
    final tempRef = _storage
        .ref()
        .child('users')
        .child(userId)
        .child('uploads')
        .child('temp')
        .child(fileName);

    final uploadTask = await tempRef.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteTemporaryFile({
    required String userId,
    required String fileName,
  }) async {
    final tempRef = _storage
        .ref()
        .child('users')
        .child(userId)
        .child('uploads')
        .child('temp')
        .child(fileName);

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
    final assetRef =
        _storage.ref().child('public').child('assets').child(assetName);

    return await assetRef.getDownloadURL();
  }
}
