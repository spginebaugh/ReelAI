import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../services/video_service.dart';
import '../models/video.dart';
import '../state/video_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  bool _isUploading = false;
  final _titleController = TextEditingController();

  Future<bool> _requestPermissions() async {
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

  Future<void> _pickAndUploadVideo() async {
    try {
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Please grant access to videos.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        initialDirectory: '/storage/emulated/0/Download/test_videos',
      );

      if (result == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No video selected')),
        );
        return;
      }

      if (result.files.single.path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid video file')),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      final file = File(result.files.single.path!);
      final videoId = const Uuid().v4();

      // Access video service via Riverpod
      final videoService = ref.read(videoServiceProvider);

      // Upload video file
      String videoUrl = await videoService.uploadVideo(file, videoId);

      // Create video metadata
      Video video = Video(
        id: videoId,
        title: _titleController.text.isEmpty
            ? 'Untitled Video'
            : _titleController.text,
        url: videoUrl,
        uploaderId: "CURRENT_USER_ID", // Replace with actual user id from auth
        uploadDate: DateTime.now(),
      );

      // Save metadata to Firestore
      await videoService.saveVideoMetadata(video);

      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Video Title'),
            ),
            const SizedBox(height: 20),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _pickAndUploadVideo,
                    child: const Text('Select & Upload Video'),
                  ),
          ],
        ),
      ),
    );
  }
}
