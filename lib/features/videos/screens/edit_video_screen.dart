import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/common/router/route_names.dart';
import 'package:reel_ai/features/videos/providers/video_edit_provider.dart';
import 'package:reel_ai/features/videos/providers/audio_player_provider.dart';
import 'package:reel_ai/features/videos/widgets/subtitle_display.dart';
import 'package:reel_ai/features/videos/widgets/toolbar/edit_toolbar.dart';
import 'package:reel_ai/features/videos/widgets/toolbar/panel_container.dart';
import 'package:reel_ai/features/videos/widgets/toolbar/features/video_player_section/video_player_section.dart';

class EditVideoScreen extends ConsumerStatefulWidget {
  final Video video;
  const EditVideoScreen({Key? key, required this.video}) : super(key: key);

  @override
  ConsumerState<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends ConsumerState<EditVideoScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('🎬 EditVideoScreen: Initializing video...');
      try {
        await ref
            .read(videoEditControllerProvider.notifier)
            .initializeVideo(widget.video);
        debugPrint('✅ EditVideoScreen: Video initialized successfully');

        // Verify audio initialization
        final editState = ref.read(videoEditControllerProvider).value;
        if (editState != null && editState.chewieController != null) {
          debugPrint('🎬 EditVideoScreen: Verifying audio system...');
          await ref.read(audioPlayerControllerProvider.notifier).initialize(
                editState.chewieController!.videoPlayerController,
              );
          debugPrint('🎬 EditVideoScreen: Switching to English audio...');
          await ref.read(audioPlayerControllerProvider.notifier).switchLanguage(
                widget.video.id,
                'english',
              );
          debugPrint(
              '✅ EditVideoScreen: Audio system initialized successfully');
        } else {
          debugPrint(
              '❌ EditVideoScreen: Video controllers not properly initialized');
        }
      } catch (e) {
        debugPrint('❌ EditVideoScreen: Error during initialization: $e');
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editStateAsync = ref.watch(videoEditControllerProvider);

    return editStateAsync.when(
      data: (editState) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Video player in background
            VideoPlayerSection(editState: editState),

            // Overlay content
            SafeArea(
              child: Stack(
                children: [
                  // Top buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        _buildFloatingButton(
                          icon: Icons.arrow_back,
                          onPressed: () =>
                              context.pushReplacementNamed(RouteNames.myVideos),
                        ),
                      ],
                    ),
                  ),

                  // Right side toolbar
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: EditToolbar(video: widget.video),
                  ),

                  // Subtitles
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 80, // Position above the panel container
                    child: SubtitleDisplay(),
                  ),

                  // Bottom panel
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: const PanelContainer(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
