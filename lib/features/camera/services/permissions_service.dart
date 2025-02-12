import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reel_ai/common/services/base_service.dart';
import 'package:reel_ai/common/utils/error_handler.dart';

part 'permissions_service.g.dart';

@riverpod
PermissionsService permissionsService(PermissionsServiceRef ref) =>
    PermissionsService();

class PermissionsService extends BaseService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    return executeOperation(
      operation: () async {
        final status = await Permission.camera.request();
        return status.isGranted;
      },
      operationName: 'requestCameraPermission',
      errorCategory: ErrorCategory.permission,
    );
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    return executeOperation(
      operation: () async {
        final status = await Permission.microphone.request();
        return status.isGranted;
      },
      operationName: 'requestMicrophonePermission',
      errorCategory: ErrorCategory.permission,
    );
  }

  /// Request storage/video permission based on Android version
  Future<bool> requestStoragePermission() async {
    return executeOperation(
      operation: () async {
        if (!Platform.isAndroid) return true;

        final androidInfo = await _deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          // Android 13 and above: Request videos permission
          final status = await Permission.videos.request();
          return status.isGranted;
        } else {
          // Below Android 13: Request storage permission
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      },
      operationName: 'requestStoragePermission',
      context: {'platform': Platform.operatingSystem},
      errorCategory: ErrorCategory.permission,
    );
  }

  /// Request all permissions needed for camera recording
  Future<bool> requestCameraAndMicrophonePermissions() async {
    return executeOperation(
      operation: () async {
        final cameraGranted = await requestCameraPermission();
        if (!cameraGranted) return false;

        final microphoneGranted = await requestMicrophonePermission();
        return microphoneGranted;
      },
      operationName: 'requestCameraAndMicrophonePermissions',
      errorCategory: ErrorCategory.permission,
    );
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    return executeOperation(
      operation: () => Permission.camera.isGranted,
      operationName: 'hasCameraPermission',
      errorCategory: ErrorCategory.permission,
    );
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    return executeOperation(
      operation: () => Permission.microphone.isGranted,
      operationName: 'hasMicrophonePermission',
      errorCategory: ErrorCategory.permission,
    );
  }

  /// Check if storage permission is granted
  Future<bool> hasStoragePermission() async {
    return executeOperation(
      operation: () async {
        if (!Platform.isAndroid) return true;

        final androidInfo = await _deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          return await Permission.videos.isGranted;
        } else {
          return await Permission.storage.isGranted;
        }
      },
      operationName: 'hasStoragePermission',
      context: {
        'platform': Platform.operatingSystem,
      },
      errorCategory: ErrorCategory.permission,
    );
  }
}
