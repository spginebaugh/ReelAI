import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';
import '../state/video_provider.dart';
import '../state/user_provider.dart';
import '../widgets/video_card.dart';
import '../utils/logger.dart';

class MyVideosScreen extends HookConsumerWidget {
  const MyVideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Videos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(RouteNames.home),
        ),
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            Logger.error('No authenticated user found');
            return const Center(
                child: Text('Please sign in to view your videos'));
          }

          Logger.info('Fetching videos for user', {'userId': user.id});
          final videosAsync = ref.watch(userVideosProvider(user.id));

          return videosAsync.when(
            data: (videos) {
              Logger.info('Videos fetched', {
                'userId': user.id,
                'videoCount': videos.length,
              });
              return videos.isEmpty
                  ? const Center(child: Text('No videos yet'))
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: videos.length,
                      itemBuilder: (context, index) =>
                          VideoCard(video: videos[index]),
                    );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              Logger.error('Error loading videos', {
                'userId': user.id,
                'error': error.toString(),
                'stack': stack.toString(),
              });
              return Center(
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
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          Logger.error('Error loading user', {
            'error': error.toString(),
            'stack': stack.toString(),
          });
          return Center(
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
          );
        },
      ),
    );
  }
}
