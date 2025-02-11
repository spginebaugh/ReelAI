import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../state/video_edit_provider.dart';
import 'package:video_player/video_player.dart';

class TrimPanel extends ConsumerWidget {
  const TrimPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
      data: (state) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      _formatDuration(
                          Duration(milliseconds: state.startValue.round())),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Expanded(
                      child: RangeSlider(
                        values: RangeValues(
                          state.startValue,
                          state.endValue,
                        ),
                        min: 0,
                        max: state.videoPlayerController?.value.duration
                                .inMilliseconds
                                .toDouble() ??
                            0,
                        onChanged: (RangeValues values) {
                          ref
                              .read(videoEditControllerProvider.notifier)
                              .updateStartValue(values.start);
                          ref
                              .read(videoEditControllerProvider.notifier)
                              .updateEndValue(values.end);
                        },
                        onChangeEnd: (_) => ref
                            .read(videoEditControllerProvider.notifier)
                            .updatePlaybackState(false),
                      ),
                    ),
                    Text(
                      _formatDuration(
                          Duration(milliseconds: state.endValue.round())),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: state.isProcessing
                      ? null
                      : () => ref
                          .read(videoEditControllerProvider.notifier)
                          .processVideo(),
                  child: state.isProcessing
                      ? const CircularProgressIndicator()
                      : const Text('Apply Trim'),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
