import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/features/videos/models/video_player_state.dart';
import 'package:reel_ai/common/router/route_names.dart';
import 'package:reel_ai/features/videos/providers/video_player_facade.dart';
import 'package:reel_ai/features/videos/widgets/subtitle_display.dart';
import 'package:reel_ai/features/videos/widgets/toolbar/edit_toolbar.dart';
import 'package:reel_ai/features/videos/widgets/video_player_widget.dart';
import 'package:reel_ai/common/widgets/floating_action_button.dart';

class EditVideoScreen extends ConsumerStatefulWidget {
  final Video video;
  const EditVideoScreen({super.key, required this.video});

  @override
  ConsumerState<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends ConsumerState<EditVideoScreen> {
  @override
  void initState() {
    super.initState();
    _configureSystemUI();
    _initializeVideo();
  }

  void _configureSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
  }

  void _initializeVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoPlayerFacadeProvider.notifier).initialize(widget.video);
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
  Widget build(BuildContext context) =>
      ref.watch(videoPlayerFacadeProvider).when(
            data: _buildContent,
            loading: _buildLoading,
            error: _buildError,
          );

  Widget _buildContent(VideoPlayerState videoState) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (videoState.videoController != null)
              VideoPlayerWidget(
                videoController: videoState.videoController!,
                showControls: true,
                autoPlay: false,
                allowFullScreen: false,
              ),
            SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CustomFloatingButton(
                          iconData: Icons.arrow_back,
                          onPressed: () => context.pushReplacementNamed(
                            RouteNames.myVideos,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: EditToolbar(video: widget.video),
                  ),
                  if (videoState.subtitles.isEnabled)
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: SubtitleDisplay(),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );

  Widget _buildError(Object error, StackTrace stack) => Scaffold(
        body: Center(
          child: SelectableText.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Error loading video:\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      );
}
