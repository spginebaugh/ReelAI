import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import '../state/video_provider.dart';
import '../constants/assets.dart';
import '../router/route_names.dart';
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
    final error = useState<String?>(null);
    final isMounted = useIsMounted();

    // Use useEffect to handle the upload once when the screen mounts
    useEffect(() {
      Future<void> uploadVideo() async {
        // Capture the BuildContext in a local variable
        final currentContext = context;

        try {
          final thumbnailFile = File(AssetPaths.defaultVideoThumbnail);

          final videoId = await ref.read(videoServiceProvider).uploadVideo(
                userId: currentUser.id,
                videoFile: videoFile,
                thumbnailFile: thumbnailFile,
                title: 'Camera Recording',
                description: 'Recorded from camera',
              );

          if (!isMounted()) return;

          final video = await ref.read(videoServiceProvider).getVideo(videoId);

          // Clean up the original video file
          try {
            if (await videoFile.exists()) {
              await videoFile.delete();
            }
          } catch (e) {
            debugPrint('Error cleaning up original video file: $e');
          }

          if (!isMounted()) return;

          // Use the captured context and verify it's still valid
          if (video != null) {
            currentContext.pushNamed(
              RouteNames.video,
              pathParameters: {'id': video.id},
              extra: video,
            );
          }
        } catch (e) {
          debugPrint('Error uploading video: $e');
          if (isMounted()) {
            error.value = e.toString();
          }
        }
      }

      uploadVideo();
      return null;
    }, const []); // Empty dependency array means this runs once on mount

    if (error.value != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ErrorText(
                  message: 'Error uploading video: ${error.value}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(false),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
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
    );
  }
}
