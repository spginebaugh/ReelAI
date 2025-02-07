import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import 'firestore_service.dart';
import 'user_storage_service.dart';

part 'user_service.g.dart';

@riverpod
UserService userService(UserServiceRef ref) => UserService(
      firestoreService: ref.watch(firestoreServiceProvider),
      userStorageService: ref.watch(userStorageServiceProvider),
    );

class UserService {
  final FirestoreService _firestoreService;
  final UserStorageService _userStorageService;

  UserService({
    required FirestoreService firestoreService,
    required UserStorageService userStorageService,
  })  : _firestoreService = firestoreService,
        _userStorageService = userStorageService;

  // Profile Management
  Future<User?> getUser(String userId) {
    return _firestoreService.getUser(userId);
  }

  Future<void> updateProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    // Upload profile picture
    final profilePictureUrl = await _userStorageService.uploadProfilePicture(
      userId: userId,
      imageFile: imageFile,
    );

    // Update user document with new URL
    await _firestoreService.updateUser(userId, {
      'profilePictureUrl': profilePictureUrl,
      // We no longer have separate thumbnail URLs in the new structure
      'profileThumbnailUrl': profilePictureUrl,
    });
  }

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _firestoreService.updateUser(userId, data);
  }

  // Account Management
  Future<void> createUser(User user) async {
    // Create user document
    await _firestoreService.createUser(user);

    // Set default profile picture if none provided
    if (user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty) {
      final defaultUrl = await _userStorageService.getDefaultProfilePicture();
      await _firestoreService.updateUser(user.id, {
        'profilePictureUrl': defaultUrl,
        'profileThumbnailUrl': defaultUrl,
      });
    }
  }

  Future<void> deleteAccount(String userId) async {
    // Delete all user content from storage
    await _userStorageService.deleteAllUserContent(userId);

    // Delete user document
    // Note: This should be done through a Cloud Function to ensure
    // all related data (comments, likes, etc.) is properly cleaned up
    await _firestoreService.updateUser(userId, {
      'isDeleted': true,
      'deletedAt': DateTime.now().toIso8601String(),
    });
  }
}
