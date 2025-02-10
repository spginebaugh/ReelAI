import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import 'firestore_service.dart';
import 'user_storage_service.dart';
import 'base_service.dart';
import '../utils/error_handler.dart';

part 'user_service.g.dart';

@riverpod
UserService userService(UserServiceRef ref) => UserService(
      firestoreService: ref.watch(firestoreServiceProvider),
      userStorageService: ref.watch(userStorageServiceProvider),
    );

class UserService extends BaseService {
  final FirestoreService _firestoreService;
  final UserStorageService _userStorageService;

  UserService({
    required FirestoreService firestoreService,
    required UserStorageService userStorageService,
  })  : _firestoreService = firestoreService,
        _userStorageService = userStorageService;

  // Profile Management
  Future<User?> getUser(String userId) {
    return executeOperation(
      operation: () => _firestoreService.getUser(userId),
      operationName: 'getUser',
      context: {'userId': userId},
      errorCategory: ErrorCategory.database,
    );
  }

  Future<void> updateProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    await executeOperation(
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

        // Upload profile picture
        final profilePictureUrl =
            await _userStorageService.uploadProfilePicture(
          userId: userId,
          imageFile: imageFile,
        );

        // Update user document with new URL
        await _firestoreService.updateUser(userId, {
          'profilePictureUrl': profilePictureUrl,
          // We no longer have separate thumbnail URLs in the new structure
          'profileThumbnailUrl': profilePictureUrl,
        });
      },
      operationName: 'updateProfilePicture',
      context: {
        'userId': userId,
        'filePath': imageFile.path,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'userId': userId,
            'data': data,
          },
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
            'data': (value) => value == null || (value as Map).isEmpty
                ? 'Profile data is required'
                : '',
          },
        );

        await _firestoreService.updateUser(userId, data);
      },
      operationName: 'updateProfile',
      context: {
        'userId': userId,
        'updateFields': data.keys.toList(),
      },
      errorCategory: ErrorCategory.database,
    );
  }

  // Account Management
  Future<void> createUser(User user) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {'user': user},
          validators: {
            'user': (value) => value == null ? 'User data is required' : '',
          },
        );

        // Create user document
        await _firestoreService.createUser(user);

        // Set default profile picture if none provided
        if (user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty) {
          final defaultUrl =
              await _userStorageService.getDefaultProfilePicture();
          await _firestoreService.updateUser(user.id, {
            'profilePictureUrl': defaultUrl,
            'profileThumbnailUrl': defaultUrl,
          });
        }
      },
      operationName: 'createUser',
      context: {'userId': user.id},
      errorCategory: ErrorCategory.database,
    );
  }

  Future<void> deleteAccount(String userId) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {'userId': userId},
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
          },
        );

        // Delete all user content from storage
        await _userStorageService.deleteAllUserContent(userId);

        // Delete user document
        // Note: This should be done through a Cloud Function to ensure
        // all related data (comments, likes, etc.) is properly cleaned up
        await _firestoreService.updateUser(userId, {
          'isDeleted': true,
          'deletedAt': DateTime.now().toIso8601String(),
        });
      },
      operationName: 'deleteAccount',
      context: {'userId': userId},
      errorCategory: ErrorCategory.database,
    );
  }
}
