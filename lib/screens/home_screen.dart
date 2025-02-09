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

    return Scaffold(
      body: Stack(
        children: [
          // Synthwave grid background
          _SynthwaveBackground(),

          // Main content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'ReelAI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: AppColors.neonPink,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.neonPurple.withOpacity(0.3),
                          AppColors.darkBackground.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildListDelegate([
                    _SynthwaveCard(
                      title: 'Take Video',
                      icon: Icons.videocam,
                      color: AppColors.neonPink,
                      onTap: () async {
                        await context.pushNamed(RouteNames.camera);
                      },
                    ),
                    _SynthwaveCard(
                      title: 'My Videos',
                      icon: Icons.video_library,
                      color: AppColors.neonBlue,
                      onTap: () => context.pushNamed(RouteNames.myVideos),
                    ),
                    _SynthwaveCard(
                      title: 'Upload Videos',
                      icon: Icons.upload_file,
                      color: AppColors.neonPurple,
                      onTap: () async {
                        final currentUser = currentUserState.valueOrNull;
                        if (currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please sign in to upload videos')),
                          );
                          return;
                        }

                        try {
                          final hasPermission = await PermissionsService
                              .requestStoragePermission();
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

                          if (result == null ||
                              result.files.single.path == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('No video selected')),
                              );
                            }
                            return;
                          }

                          if (context.mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.neonPink,
                                ),
                              ),
                            );
                          }

                          final videoFile = File(result.files.single.path!);
                          final thumbnailFile =
                              File(AssetPaths.defaultVideoThumbnail);

                          final videoId =
                              await ref.read(videoServiceProvider).uploadVideo(
                                    userId: currentUser.id,
                                    videoFile: videoFile,
                                    thumbnailFile: thumbnailFile,
                                    title: 'Untitled Video',
                                    description: '',
                                  );

                          final video = await ref
                              .read(videoServiceProvider)
                              .getVideo(videoId);

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }

                          if (context.mounted && video != null) {
                            context.pushNamed(
                              RouteNames.video,
                              pathParameters: {'id': video.id},
                              extra: video,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error uploading video: ${e.toString()}')),
                            );
                          }
                        }
                      },
                    ),
                    _SynthwaveCard(
                      title: 'Settings',
                      icon: Icons.settings,
                      color: AppColors.retroOrange,
                      onTap: () => context.pushNamed(RouteNames.settings),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SynthwaveBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      child: Container(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonPurple.withOpacity(0.15)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double i = 0; i <= size.width; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines with perspective effect
    for (double i = 0; i <= size.height; i += 40) {
      final y = size.height - i;
      final startX = 0.0;
      final endX = size.width;

      // Calculate perspective points
      final startPoint = Offset(startX, y);
      final endPoint = Offset(endX, y + (size.height - y) * 0.2);

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SynthwaveCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SynthwaveCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: color,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: color,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
