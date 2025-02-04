import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    String size = 'original', // original, thumbnail
  }) async {
    final profileRef = _storage
        .ref()
        .child('users')
        .child(userId)
        .child('profile')
        .child('avatar')
        .child('$size.jpg');

    final uploadTask = await profileRef.putFile(
      imageFile,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'userId': userId,
          'size': size,
        },
      ),
    );

    return uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteProfilePictures(String userId) async {
    final profileRef = _storage
        .ref()
        .child('users')
        .child(userId)
        .child('profile')
        .child('avatar');

    try {
      final ListResult result = await profileRef.listAll();
      await Future.wait(result.items.map((item) => item.delete()));
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }

  // Banner Image Operations
  Future<String> uploadBannerImage({
    required String userId,
    required File imageFile,
    String size = 'original', // original, mobile
  }) async {
    final bannerRef = _storage
        .ref()
        .child('users')
        .child(userId)
        .child('profile')
        .child('banner')
        .child('$size.jpg');

    final uploadTask = await bannerRef.putFile(
      imageFile,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'userId': userId,
          'size': size,
        },
      ),
    );

    return uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteBannerImages(String userId) async {
    final bannerRef = _storage
        .ref()
        .child('users')
        .child(userId)
        .child('profile')
        .child('banner');

    try {
      final ListResult result = await bannerRef.listAll();
      await Future.wait(result.items.map((item) => item.delete()));
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }

  // User Content Management
  Future<void> deleteAllUserContent(String userId) async {
    final userRef = _storage.ref().child('users').child(userId);

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

  Future<String> getDefaultBanner() async {
    return getDefaultAsset('default_banner.jpg');
  }

  Future<String> getDefaultAsset(String assetName) async {
    final assetRef =
        _storage.ref().child('public').child('assets').child(assetName);

    return await assetRef.getDownloadURL();
  }
}
