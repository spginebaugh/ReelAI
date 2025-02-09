import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../models/video.dart';
import '../../../../models/video_edit_state.dart';
import 'edit_mode_buttons.dart';
import 'playback_speed_button.dart';
import 'subtitle_controls.dart';
import 'audio_controls.dart';

class RightToolbar extends ConsumerWidget {
  final Video video;
  final VideoEditState editState;

  const RightToolbar({
    Key? key,
    required this.video,
    required this.editState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              EditModeButtons(
                currentMode: editState.currentMode,
                video: video,
              ),
              const SizedBox(height: 16),
              PlaybackSpeedButton(
                videoPlayerController: editState.videoPlayerController,
              ),
              const Spacer(),
              SubtitleControls(video: video),
              const SizedBox(height: 16),
              AudioControls(video: video),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
