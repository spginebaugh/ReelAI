import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/permissions_service.dart';
import '../state/user_provider.dart';
import '../widgets/error_text.dart';
import '../screens/uploading_screen.dart';

class CameraScreen extends HookConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = useState<CameraController?>(null);
    final isRecording = useState(false);
    final isInitialized = useState(false);
    final isUploading = useState(false);
    final errorMessage = useState<String?>(null);
    final currentUser = ref.watch(currentUserProvider);

    useEffect(() {
      // Lock orientation to portrait
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      PermissionsService.requestCameraAndMicrophonePermissions()
          .then((granted) {
        if (granted) {
          availableCameras().then((cameras) {
            if (cameras.isNotEmpty) {
              debugPrint('Available cameras: ${cameras.length}');
              debugPrint('Selected camera: ${cameras.first.name}');
              debugPrint(
                  'Camera lens direction: ${cameras.first.lensDirection}');

              cameraController.value = CameraController(
                cameras.first,
                ResolutionPreset.high,
                enableAudio: true,
              );
              cameraController.value!.initialize().then((_) {
                final value = cameraController.value!.value;
                debugPrint('Camera initialized');
                debugPrint('Camera preview size: ${value.previewSize}');
                debugPrint('Camera raw aspect ratio: ${value.aspectRatio}');
                debugPrint(
                    'Camera sensor orientation: ${cameras.first.sensorOrientation}');

                cameraController.value!
                    .lockCaptureOrientation(DeviceOrientation.portraitUp);
                isInitialized.value = true;
              });
            }
          });
        } else {
          errorMessage.value = 'Camera and microphone permissions are required';
        }
      });

      return () {
        cameraController.value?.dispose();
        // Reset orientation when screen is disposed
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      };
    }, const []);

    Future<void> startRecording() async {
      if (!isInitialized.value || isRecording.value) return;

      try {
        await cameraController.value!.startVideoRecording();
        isRecording.value = true;
        errorMessage.value = null;
      } catch (e) {
        debugPrint('Error starting video recording: $e');
        errorMessage.value = 'Failed to start recording: ${e.toString()}';
      }
    }

    Future<void> stopRecording() async {
      if (!isInitialized.value || !isRecording.value) return;

      XFile? recordedVideo;
      try {
        recordedVideo = await cameraController.value!.stopVideoRecording();
        isRecording.value = false;
        errorMessage.value = null;
      } catch (e) {
        debugPrint('Error stopping video recording: $e');
        errorMessage.value = 'Failed to stop recording: ${e.toString()}';
        return;
      }

      if (!context.mounted || currentUser.value == null) return;

      // Navigate immediately after stopping recording
      final shouldContinue = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => UploadingScreen(
            videoFile: File(recordedVideo!.path),
            currentUser: currentUser.value!,
          ),
        ),
      );

      if (shouldContinue == true && context.mounted) {
        Navigator.pop(context);
      }
    }

    if (!isInitialized.value) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Get the screen size in portrait.
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final cameraRatio = cameraController.value!.value.aspectRatio;

    debugPrint('\n=== Debug Info ===');
    debugPrint('Screen size: $size');
    debugPrint('Device ratio: $deviceRatio');
    debugPrint('Camera ratio: $cameraRatio');
    debugPrint('Preview size: ${cameraController.value!.value.previewSize}');
    debugPrint('==================\n');

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Transform.scale(
              scale: 1.0,
              child: Center(
                child: Transform.rotate(
                  angle: math.pi / 2,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height,
                    height: MediaQuery.of(context).size.width,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width /
                            cameraController.value!.value.aspectRatio,
                        child: CameraPreview(cameraController.value!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (errorMessage.value != null)
              Positioned(
                top: 64,
                left: 16,
                right: 16,
                child: ErrorText(
                  message: errorMessage.value!,
                  textAlign: TextAlign.center,
                ),
              ),
            if (isUploading.value)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Uploading video...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: FloatingActionButton(
                  backgroundColor:
                      isRecording.value ? Colors.red : Colors.white,
                  onPressed: isUploading.value
                      ? null
                      : (isRecording.value ? stopRecording : startRecording),
                  child: Icon(
                    isRecording.value ? Icons.stop : Icons.videocam,
                    color: isRecording.value ? Colors.white : Colors.black,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
