import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/video.dart';
import '../services/video_service.dart';
import '../widgets/error_text.dart';
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
    final isGeneratingTranslation = useState(false);

    Future<void> generateTranslation() async {
      try {
        debugPrint('🎬 Starting translation generation process...');
        isGeneratingTranslation.value = true;
        errorMessage.value = null;

        // Check current auth state
        debugPrint('👤 Checking authentication state...');
        final auth = FirebaseAuth.instance;
        debugPrint(
            '- Current auth instance state: ${auth.currentUser != null ? 'Has user' : 'No user'}');

        // Ensure user is authenticated
        final user = auth.currentUser;
        if (user == null) {
          debugPrint('❌ No authenticated user found');
          throw Exception('User must be authenticated to generate translation');
        }

        // Log user details
        debugPrint('✅ User authenticated:');
        debugPrint('- User ID: ${user.uid}');
        debugPrint('- Email: ${user.email}');
        debugPrint('- Email verified: ${user.emailVerified}');
        debugPrint(
            '- Provider ID: ${user.providerData.map((p) => p.providerId).join(', ')}');

        // Force token refresh and wait for it
        debugPrint('🔄 Refreshing ID token...');
        final idToken = await user.getIdToken(true);
        debugPrint('✅ Got fresh ID token:');
        debugPrint('- Token length: ${idToken?.length ?? 0}');
        debugPrint('- Token exists: ${idToken != null}');

        // Log video details
        debugPrint('📹 Video details:');
        debugPrint('- Video ID: ${video.id}');
        debugPrint('- Uploader ID: ${video.uploaderId}');
        debugPrint('- Video title: ${video.title}');
        debugPrint('- Created at: ${video.createdAt}');

        // Verify video ownership
        debugPrint('🔍 Verifying video ownership...');
        if (video.uploaderId != user.uid) {
          debugPrint('❌ Video ownership mismatch:');
          debugPrint('- Video uploader: ${video.uploaderId}');
          debugPrint('- Current user: ${user.uid}');
          throw Exception(
              'Not authorized to generate translation for this video');
        }
        debugPrint('✅ Video ownership verified');

        debugPrint('📞 Setting up Cloud Function call...');
        // Force token refresh to ensure we have a fresh token
        final freshToken =
            await FirebaseAuth.instance.currentUser?.getIdToken(true);
        debugPrint('🔑 Fresh token details:');
        debugPrint('- Token: ${freshToken?.substring(0, 20)}... (truncated)');
        debugPrint('- Full length: ${freshToken?.length}');

        debugPrint('🌐 Initializing Firebase Functions...');
        final functions = FirebaseFunctions.instanceFor(
          region: 'us-central1',
          app: Firebase.app(),
        );
        debugPrint('✅ Functions instance created');
        debugPrint('- App name: ${Firebase.app().name}');
        debugPrint('- Options: ${Firebase.app().options.projectId}');

        debugPrint('🔧 Creating callable...');
        final callable = functions.httpsCallable(
          'generateTranslation',
          options: HttpsCallableOptions(
            timeout: const Duration(minutes: 5),
          ),
        );
        debugPrint('✅ Callable created');

        debugPrint('🚀 Calling generateTranslation function...');
        debugPrint('📤 Request payload:');
        debugPrint('- videoId: ${video.id}');

        final result = await callable.call<Map<String, dynamic>>({
          'videoId': video.id,
        });

        debugPrint('✅ Function call completed');
        debugPrint('📥 Response details:');
        debugPrint('- Raw data: ${result.data}');
        debugPrint('- Success: ${result.data['success']}');

        if (result.data['success'] == true) {
          debugPrint('🎉 Translation generated successfully');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Translation generated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          debugPrint('⚠️ Function returned success: false');
          throw Exception('Function did not return success');
        }
      } on FirebaseFunctionsException catch (e) {
        debugPrint('❌ Firebase Functions Error:');
        debugPrint('- Code: ${e.code}');
        debugPrint('- Message: ${e.message}');
        debugPrint('- Details: ${e.details}');
        debugPrint('- Stack trace: ${e.stackTrace}');

        if (e.code == 'unauthenticated') {
          debugPrint('🔐 Authentication error detected');
          errorMessage.value =
              'Authentication error. Please try logging out and back in.';
        } else {
          errorMessage.value = 'Failed to generate translation: ${e.message}';
        }
      } catch (e, stack) {
        debugPrint('❌ Unexpected error:');
        debugPrint('- Error: $e');
        debugPrint('- Stack trace: $stack');
        errorMessage.value = 'Failed to generate translation: $e';
      } finally {
        debugPrint('🏁 Translation generation process completed');
        isGeneratingTranslation.value = false;
      }
    }

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
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      FilledButton.icon(
                        onPressed: isGeneratingTranslation.value
                            ? null
                            : () => generateTranslation(),
                        icon: isGeneratingTranslation.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.translate),
                        label: Text(
                          isGeneratingTranslation.value
                              ? 'Generating Translation...'
                              : 'Translate Audio',
                        ),
                      ),
                    ],
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
