import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/storage_paths.dart';

part 'user_storage_service.g.dart';

@riverpod
UserStorageService userStorageService(UserStorageServiceRef ref) =>
    UserStorageService();

class UserStorageService {
  final _storage = FirebaseStorage.instance;

  // Profile Picture Operations
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

  Future<void> deleteProfilePicture(String userId) async {
    final profileRef = _storage.ref(StoragePaths.profilePicture(userId));

    try {
      await profileRef.delete();
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }

  // User Content Management
  Future<void> deleteAllUserContent(String userId) async {
    final userRef = _storage.ref(StoragePaths.userDirectory(userId));

    try {
      await _deleteDirectoryRecursive(userRef);
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }

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

  // Default Profile Assets
  Future<String> getDefaultProfilePicture() async {
    return getDefaultAsset('default_avatar.jpg');
  }

  Future<String> getDefaultAsset(String assetName) async {
    final assetRef = _storage.ref(StoragePaths.publicAsset(assetName));
    return await assetRef.getDownloadURL();
  }
}
