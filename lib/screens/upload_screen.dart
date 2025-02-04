import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../state/video_provider.dart';
import '../state/user_provider.dart';
import '../models/video.dart';
import '../widgets/error_text.dart';

class UploadScreen extends HookConsumerWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploading = useState(false);
    final errorMessage = useState<String?>(null);
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final currentUser = ref.watch(currentUserProvider);

    Future<bool> requestPermissions() async {
      if (Platform.isAndroid) {
        final androidVersion = await DeviceInfoPlugin().androidInfo;
        if (androidVersion.version.sdkInt >= 33) {
          final videoPermission = await Permission.videos.request();
          return videoPermission.isGranted;
        } else {
          final storagePermission = await Permission.storage.request();
          return storagePermission.isGranted;
        }
      }
      return true;
    }

    Future<void> pickAndUploadVideo() async {
      errorMessage.value = null;

      if (currentUser.value == null) {
        errorMessage.value = 'Please sign in to upload videos';
        return;
      }

      try {
        final hasPermission = await requestPermissions();
        if (!hasPermission) {
          errorMessage.value =
              'Permission denied. Please grant access to videos.';
          return;
        }

        final result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );

        if (result == null || result.files.single.path == null) {
          errorMessage.value = 'No video selected';
          return;
        }

        // TODO: Implement thumbnail generation
        // For now, we'll use a placeholder image
        final thumbnailFile =
            File('assets/defaults/default_video_thumbnail.jpg');

        isUploading.value = true;
        final videoFile = File(result.files.single.path!);

        // Upload video using the video service
        await ref.read(videoServiceProvider).uploadVideo(
              userId: currentUser.value!.id,
              videoFile: videoFile,
              thumbnailFile: thumbnailFile,
              title: titleController.text.isEmpty
                  ? 'Untitled Video'
                  : titleController.text,
              description: descriptionController.text,
            );

        if (!context.mounted) return;

        isUploading.value = false;
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;
        isUploading.value = false;
        errorMessage.value = 'Error uploading video: ${e.toString()}';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage.value != null)
              ErrorText(message: errorMessage.value!),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Video Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            if (isUploading.value)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Uploading video...'),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: pickAndUploadVideo,
                icon: const Icon(Icons.upload),
                label: const Text('Select & Upload Video'),
              ),
          ],
        ),
      ),
    );
  }
}
