import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Request storage/video permission based on Android version
  static Future<bool> requestStoragePermission() async {
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
  }

  /// Request all permissions needed for camera recording
  static Future<bool> requestCameraAndMicrophonePermissions() async {
    final cameraGranted = await requestCameraPermission();
    if (!cameraGranted) return false;

    final microphoneGranted = await requestMicrophonePermission();
    return microphoneGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Check if microphone permission is granted
  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await _deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      return await Permission.videos.isGranted;
    } else {
      return await Permission.storage.isGranted;
    }
  }
}
