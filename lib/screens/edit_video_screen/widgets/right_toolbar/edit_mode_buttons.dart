import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/video.dart';
import '../../../../models/video_edit_state.dart';
import '../../../../router/route_names.dart';
import '../../../../state/video_edit_provider.dart';

class EditModeButtons extends ConsumerWidget {
  final EditingMode currentMode;
  final Video video;

  const EditModeButtons({
    Key? key,
    required this.currentMode,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildModeButton(
          context: context,
          icon: Icons.close,
          mode: EditingMode.none,
          ref: ref,
        ),
        const SizedBox(height: 16),
        _buildModeButton(
          context: context,
          icon: Icons.content_cut,
          mode: EditingMode.trim,
          ref: ref,
        ),
        const SizedBox(height: 16),
        _buildModeButton(
          context: context,
          icon: Icons.filter,
          mode: EditingMode.filter,
          ref: ref,
        ),
        const SizedBox(height: 16),
        _buildModeButton(
          context: context,
          icon: Icons.brightness_6,
          mode: EditingMode.brightness,
          ref: ref,
        ),
        const SizedBox(height: 16),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            Icons.edit_note,
            color: currentMode == EditingMode.metadata
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          onPressed: () {
            context.pushNamed(
              RouteNames.editVideoMetadata,
              pathParameters: {'id': video.id},
              extra: video,
            );
          },
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required IconData icon,
    required EditingMode mode,
    required WidgetRef ref,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        icon,
        color:
            currentMode == mode ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: () =>
          ref.read(videoEditControllerProvider.notifier).setMode(mode),
    );
  }
}
