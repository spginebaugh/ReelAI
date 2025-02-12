import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/common/utils/storage_paths.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/common/utils/error_handler.dart';

part 'public_storage_service.g.dart';

@riverpod
PublicStorageService publicStorageService(PublicStorageServiceRef ref) =>
    PublicStorageService();

class PublicStorageService extends BaseService {
  final _storage = FirebaseStorage.instance;

  // Default Assets
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

  // Admin Operations - These should be protected by admin-only access
  Future<String> uploadPublicAsset({
    required File file,
    required String assetName,
    required String category,
    String? contentType,
  }) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'file': file,
            'assetName': assetName,
            'category': category,
          },
          validators: {
            'file': (value) => value == null || !File(value.path).existsSync()
                ? 'Valid file is required'
                : '',
            'assetName': (value) => value?.toString().isEmpty == true
                ? 'Asset name is required'
                : '',
            'category': (value) =>
                value?.toString().isEmpty == true ? 'Category is required' : '',
          },
        );

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
      },
      operationName: 'uploadPublicAsset',
      context: {
        'assetName': assetName,
        'category': category,
        'filePath': file.path,
        'contentType': contentType,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<void> deletePublicAsset({
    required String assetName,
    required String category,
  }) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {
            'assetName': assetName,
            'category': category,
          },
          validators: {
            'assetName': (value) => value?.toString().isEmpty == true
                ? 'Asset name is required'
                : '',
            'category': (value) =>
                value?.toString().isEmpty == true ? 'Category is required' : '',
          },
        );

        final assetRef =
            _storage.ref(StoragePaths.publicCategoryAsset(category, assetName));
        await assetRef.delete();
      },
      operationName: 'deletePublicAsset',
      context: {
        'assetName': assetName,
        'category': category,
      },
      errorCategory: ErrorCategory.storage,
    );
  }

  // Category Management
  Future<List<String>> listCategoryAssets(String category) async {
    return executeOperation(
      operation: () async {
        validateInput(
          parameters: {'category': category},
          validators: {
            'category': (value) =>
                value?.toString().isEmpty == true ? 'Category is required' : '',
          },
        );

        final categoryRef = _storage.ref(StoragePaths.publicCategory(category));
        final result = await categoryRef.listAll();
        return await Future.wait(
          result.items.map((ref) => ref.getDownloadURL()),
        );
      },
      operationName: 'listCategoryAssets',
      context: {'category': category},
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<void> deleteCategory(String category) async {
    await executeOperation(
      operation: () async {
        validateInput(
          parameters: {'category': category},
          validators: {
            'category': (value) =>
                value?.toString().isEmpty == true ? 'Category is required' : '',
          },
        );

        final categoryRef = _storage.ref(StoragePaths.publicCategory(category));
        final result = await categoryRef.listAll();
        await Future.wait([
          ...result.items.map((item) => item.delete()),
          ...result.prefixes.map((prefix) => _deleteDirectoryRecursive(prefix)),
        ]);
      },
      operationName: 'deleteCategory',
      context: {'category': category},
      errorCategory: ErrorCategory.storage,
    );
  }

  // Helper Methods
  Future<void> _deleteDirectoryRecursive(Reference ref) async {
    return executeOperation(
      operation: () async {
        final result = await ref.listAll();
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

  // Common Public Assets
  Future<String> getDefaultProfilePicture() async {
    return executeOperation(
      operation: () => getDefaultAsset('default_avatar.jpg'),
      operationName: 'getDefaultProfilePicture',
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<String> getDefaultVideoThumbnail() async {
    return executeOperation(
      operation: () => getDefaultAsset('default_video_thumbnail.jpg'),
      operationName: 'getDefaultVideoThumbnail',
      errorCategory: ErrorCategory.storage,
    );
  }

  Future<String> getAppLogo() async {
    return executeOperation(
      operation: () => getDefaultAsset('app_logo.png'),
      operationName: 'getAppLogo',
      errorCategory: ErrorCategory.storage,
    );
  }
}
