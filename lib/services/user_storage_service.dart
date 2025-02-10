import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/storage_paths.dart';
import 'base_service.dart';
import '../utils/error_handler.dart';

part 'user_storage_service.g.dart';

@riverpod
UserStorageService userStorageService(UserStorageServiceRef ref) =>
    UserStorageService();

class UserStorageService extends BaseService {
  final _storage = FirebaseStorage.instance;

  // Profile Picture Operations
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

  Future<void> deleteProfilePicture(String userId) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {'userId': userId},
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
          },
        );

        final profileRef = _storage.ref(StoragePaths.profilePicture(userId));
        await profileRef.delete();
      },
      operationName: 'deleteProfilePicture',
      context: {'userId': userId},
      errorCategory: ErrorCategory.storage,
    );
  }

  // User Content Management
  Future<void> deleteAllUserContent(String userId) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {'userId': userId},
          validators: {
            'userId': (value) =>
                value?.toString().isEmpty == true ? 'User ID is required' : '',
          },
        );

        final userRef = _storage.ref(StoragePaths.userDirectory(userId));
        await _deleteDirectoryRecursive(userRef);
      },
      operationName: 'deleteAllUserContent',
      context: {'userId': userId},
      errorCategory: ErrorCategory.storage,
    );
  }

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

  // Default Profile Assets
  Future<String> getDefaultProfilePicture() async {
    return executeOperation(
      operation: () => getDefaultAsset('default_avatar.jpg'),
      operationName: 'getDefaultProfilePicture',
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<String> getDefaultAsset(String assetName) async {
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
      operationName: 'getDefaultAsset',
      context: {'assetName': assetName},
      errorCategory: ErrorCategory.storage,
    );
  }
}
