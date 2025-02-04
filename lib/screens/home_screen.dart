import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';
import '../utils/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      _MenuItem(
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
      _MenuItem(
        title: 'My Videos',
        icon: Icons.video_library,
        onTap: () => context.pushNamed(RouteNames.myVideos),
      ),
      _MenuItem(
        title: 'Upload Videos',
        icon: Icons.upload_file,
        onTap: () => context.pushNamed(RouteNames.upload),
      ),
      _MenuItem(
        title: 'Settings',
        icon: Icons.settings,
        onTap: () => context.pushNamed(RouteNames.settings),
      ),
    ];

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
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1, // Square tiles
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) => _MenuCard(item: menuItems[index]),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.item,
  });

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.surfaceColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.surfaceColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
