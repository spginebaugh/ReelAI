import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/assets.dart';
import '../models/video.dart';
import '../router/route_names.dart';
import '../services/permissions_service.dart';
import '../services/video_service.dart';
import '../state/user_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/error_text.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserState = ref.watch(currentUserProvider);

    final menuItems = [
      _MenuItem(
        title: 'Take Video',
        icon: Icons.videocam,
        onTap: () async {
          await context.pushNamed(RouteNames.camera);
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
        onTap: () async {
          final currentUser = currentUserState.valueOrNull;
          if (currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please sign in to upload videos')),
            );
            return;
          }

          try {
            final hasPermission =
                await PermissionsService.requestStoragePermission();
            if (!hasPermission) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Permission denied. Please grant access to videos.'),
                  ),
                );
              }
              return;
            }

            final result = await FilePicker.platform.pickFiles(
              type: FileType.video,
              allowMultiple: false,
            );

            if (result == null || result.files.single.path == null) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No video selected')),
                );
              }
              return;
            }

            // Show loading dialog
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final videoFile = File(result.files.single.path!);
            final thumbnailFile = File(AssetPaths.defaultVideoThumbnail);

            // Upload video
            final videoId = await ref.read(videoServiceProvider).uploadVideo(
                  userId: currentUser.id,
                  videoFile: videoFile,
                  thumbnailFile: thumbnailFile,
                  title: 'Untitled Video',
                  description: '',
                );

            // Get the uploaded video
            final video =
                await ref.read(videoServiceProvider).getVideo(videoId);

            // Dismiss loading dialog
            if (context.mounted) {
              Navigator.of(context).pop();
            }

            // Navigate to video editing screen
            if (context.mounted && video != null) {
              context.pushNamed(
                RouteNames.video,
                pathParameters: {'id': video.id},
                extra: video,
              );
            }
          } catch (e) {
            // Dismiss loading dialog if showing
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error uploading video: ${e.toString()}')),
              );
            }
          }
        },
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
