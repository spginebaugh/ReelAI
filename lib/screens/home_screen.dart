import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/video_provider.dart';
import '../widgets/video_card.dart';
import '../models/video.dart';
import '../router/route_names.dart';
import '../router/route_paths.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ReelAI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _MenuCard(
              title: 'Take Video',
              icon: Icons.videocam,
              onTap: () async {
                final videoPath = await context.pushNamed<String>(
                  RouteNames.camera,
                );

                if (videoPath != null && context.mounted) {
                  // TODO: Handle the recorded video path
                  debugPrint('Video recorded at: $videoPath');
                }
              },
            ),
            const SizedBox(height: 16),
            _MenuCard(
              title: 'My Videos',
              icon: Icons.video_library,
              onTap: () => context.pushNamed(RouteNames.myVideos),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              title: 'Upload Videos',
              icon: Icons.upload_file,
              onTap: () => context.pushNamed(RouteNames.upload),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              title: 'User Settings',
              icon: Icons.settings,
              onTap: () => context.pushNamed(RouteNames.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
