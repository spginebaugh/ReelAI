import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';

import '../models/video.dart';
import '../services/video_service.dart';
import '../widgets/error_text.dart';
import '../state/video_edit_provider.dart';
import '../router/route_names.dart';
import '../services/video_processing_service.dart';

class EditVideoMetadataScreen extends HookConsumerWidget {
  final Video video;

  const EditVideoMetadataScreen({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(text: video.title);
    final descriptionController =
        useTextEditingController(text: video.description);
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final editState = ref.watch(videoEditControllerProvider);

    Future<void> saveChanges() async {
      try {
        isLoading.value = true;
        errorMessage.value = null;

        await ref.read(videoServiceProvider).updateVideoMetadata(
              videoId: video.id,
              title: titleController.text,
              description: descriptionController.text,
            );

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        errorMessage.value = 'Failed to update video: $e';
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> deleteVideo() async {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          title: const Text('Delete Video'),
          content: const Text(
            'Are you sure you want to delete this video? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (shouldDelete != true || !context.mounted) return;

      try {
        isLoading.value = true;
        errorMessage.value = null;

        // Delete the video from the server
        await ref.read(videoServiceProvider).deleteVideo(
              userId: video.uploaderId,
              videoId: video.id,
            );

        // Navigate back to my videos screen
        if (context.mounted) {
          context.goNamed(RouteNames.myVideos);
        }
      } catch (e) {
        errorMessage.value = 'Failed to delete video: $e';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Video Details'),
        actions: [
          if (isLoading.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveChanges,
            ),
        ],
      ),
      body: Column(
        children: [
          if (editState.value?.chewieController != null)
            SizedBox(
              height: 200,
              child: Chewie(controller: editState.value!.chewieController!),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (errorMessage.value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ErrorText(message: errorMessage.value!),
                    ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading.value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    enabled: !isLoading.value,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton.tonalIcon(
              onPressed: isLoading.value ? null : deleteVideo,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete Video'),
            ),
          ),
        ],
      ),
    );
  }
}
