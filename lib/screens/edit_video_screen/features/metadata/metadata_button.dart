import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/video.dart';
import '../../../../models/video_edit_state.dart';
import '../../../../state/video_edit_provider.dart';
import '../../../../router/route_names.dart';

class MetadataButton extends ConsumerWidget {
  final Video video;

  const MetadataButton({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
      data: (state) => IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.edit_note,
          color: state.currentMode == EditingMode.metadata
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        onPressed: () {
          // Set mode to metadata before navigating
          ref
              .read(videoEditControllerProvider.notifier)
              .setMode(EditingMode.metadata);
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
