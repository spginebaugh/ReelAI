import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../state/video_provider.dart';
import '../state/user_provider.dart';
import '../widgets/video_card.dart';

class MyVideosScreen extends HookConsumerWidget {
  const MyVideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Videos'),
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
                child: Text('Please sign in to view your videos'));
          }

          final videosAsync = ref.watch(userVideosProvider(user.id));

          return videosAsync.when(
            data: (videos) => videos.isEmpty
                ? const Center(child: Text('No videos yet'))
                : ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) =>
                        VideoCard(video: videos[index]),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: SelectableText.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Error loading videos\n',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: error.toString()),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: SelectableText.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Error loading user\n',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: error.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
