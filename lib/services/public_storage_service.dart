import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/storage_paths.dart';

part 'public_storage_service.g.dart';

@riverpod
PublicStorageService publicStorageService(PublicStorageServiceRef ref) =>
    PublicStorageService();

class PublicStorageService {
  final _storage = FirebaseStorage.instance;

  // Default Assets
  Future<String> getDefaultAsset(String assetName) async {
    final assetRef = _storage.ref(StoragePaths.publicAsset(assetName));
    return await assetRef.getDownloadURL();
  }

  // Admin Operations - These should be protected by admin-only access
  Future<String> uploadPublicAsset({
    required File file,
    required String assetName,
    required String category,
    String? contentType,
  }) async {
    final assetRef =
        _storage.ref(StoragePaths.publicCategoryAsset(category, assetName));

    final uploadTask = await assetRef.putFile(
      file,
      SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'category': category,
        },
      ),
    );

    return uploadTask.ref.getDownloadURL();
  }

  Future<void> deletePublicAsset({
    required String assetName,
    required String category,
  }) async {
    final assetRef =
        _storage.ref(StoragePaths.publicCategoryAsset(category, assetName));

    try {
      await assetRef.delete();
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }

  // Category Management
  Future<List<String>> listCategoryAssets(String category) async {
    final categoryRef = _storage.ref(StoragePaths.publicCategory(category));

    try {
      final result = await categoryRef.listAll();
      return await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()),
      );
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return [];
      }
      rethrow;
    }
  }

  Future<void> deleteCategory(String category) async {
    final categoryRef = _storage.ref(StoragePaths.publicCategory(category));

    try {
      final result = await categoryRef.listAll();
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

  // Helper Methods
  Future<void> _deleteDirectoryRecursive(Reference ref) async {
    try {
      final result = await ref.listAll();
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

  // Common Public Assets
  Future<String> getDefaultProfilePicture() async {
    return getDefaultAsset('default_avatar.jpg');
  }

  Future<String> getDefaultVideoThumbnail() async {
    return getDefaultAsset('default_video_thumbnail.jpg');
  }

  Future<String> getAppLogo() async {
    return getDefaultAsset('app_logo.png');
  }
}
