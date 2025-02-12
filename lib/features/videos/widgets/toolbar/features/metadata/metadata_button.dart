import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reel_ai/features/videos/models/video.dart';
import 'package:reel_ai/features/videos/models/video_player_state.dart';
import 'package:reel_ai/features/videos/providers/video_player_facade.dart';
import 'package:reel_ai/common/router/route_names.dart';

class MetadataButton extends ConsumerWidget {
  final Video video;

  const MetadataButton({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoPlayerFacadeProvider);

    return videoState.when(
      data: (state) => IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.edit_note,
          color: state.mode == VideoMode.edit
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        onPressed: () {
          // Set mode to edit before navigating
          ref.read(videoPlayerFacadeProvider.notifier).setMode(VideoMode.edit);
          // Navigate to metadata screen with video object and id parameter
          context.pushNamed(
            RouteNames.editVideoMetadata,
            pathParameters: {'id': video.id},
            extra: video,
          );
        },
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
