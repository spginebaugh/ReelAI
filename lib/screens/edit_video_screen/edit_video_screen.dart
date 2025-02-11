import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/video.dart';
import '../../models/video_edit_state.dart';
import '../../router/route_names.dart';
import '../../state/video_edit_provider.dart';
import '../../state/audio_player_provider.dart';
import 'widgets/video_player_section.dart';
import 'widgets/right_toolbar/right_toolbar.dart';
import 'widgets/editing_controls/editing_controls.dart';

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
          children: [
            Column(
              children: [
                if (editState.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (editState.chewieController != null) ...[
                  Expanded(
                    child: Row(
                      children: [
                        // Video player section
                        Expanded(
                          child: VideoPlayerSection(
                            chewieController: editState.chewieController!,
                            videoId: widget.video.id,
                          ),
                        ),
                        // Right toolbar
                        RightToolbar(
                          video: widget.video,
                          editState: editState,
                        ),
                      ],
                    ),
                  ),
                ] else
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                // Editing controls at bottom
                if (!editState.isLoading &&
                    editState.currentMode != EditingMode.none)
                  EditingControls(editState: editState),
              ],
            ),
            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: _buildFloatingButton(
                icon: Icons.arrow_back,
                onPressed: () =>
                    context.pushReplacementNamed(RouteNames.myVideos),
              ),
            ),
            // Save button
            if (!editState.isProcessing && !editState.isLoading)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 64,
                child: _buildFloatingButton(
                  icon: Icons.save,
                  onPressed: () => ref
                      .read(videoEditControllerProvider.notifier)
                      .processVideo(),
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
