import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/user.dart';
import '../state/video_provider.dart';
import '../constants/assets.dart';
import '../screens/edit_video_screen.dart';
import '../widgets/error_text.dart';

class UploadingScreen extends HookConsumerWidget {
  final File videoFile;
  final User currentUser;

  const UploadingScreen({
    super.key,
    required this.videoFile,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: FutureBuilder<String?>(
        future: _uploadVideo(ref, context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ErrorText(
                      message: 'Error uploading video: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            // Navigation will be handled in _uploadVideo
            return const SizedBox.shrink();
          }

          return Container(
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
          );
        },
      ),
    );
  }

  Future<String?> _uploadVideo(WidgetRef ref, BuildContext context) async {
    try {
      // TODO: Generate thumbnail from video
      // For now, use a placeholder
      final thumbnailFile = File(AssetPaths.defaultVideoThumbnail);

      final videoId = await ref.read(videoServiceProvider).uploadVideo(
            userId: currentUser.id,
            videoFile: videoFile,
            thumbnailFile: thumbnailFile,
            title: 'Camera Recording',
            description: 'Recorded from camera',
          );

      final video = await ref.read(videoServiceProvider).getVideo(videoId);

      if (!context.mounted || video == null) return null;

      // Navigate to edit screen
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EditVideoScreen(video: video),
        ),
      );

      return videoId;
    } catch (e) {
      debugPrint('Error uploading video: $e');
      rethrow;
    }
  }
}
