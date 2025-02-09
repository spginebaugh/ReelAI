import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TrimControlsWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final double startValue;
  final double endValue;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChangeEnd;
  final ValueChanged<bool> onChangePlaybackState;
  final VoidCallback onApplyTrim;
  final bool isProcessing;

  const TrimControlsWidget({
    Key? key,
    required this.controller,
    required this.startValue,
    required this.endValue,
    required this.onChangeStart,
    required this.onChangeEnd,
    required this.onChangePlaybackState,
    required this.onApplyTrim,
    required this.isProcessing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                _formatDuration(Duration(milliseconds: startValue.round())),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Expanded(
                child: RangeSlider(
                  values: RangeValues(startValue, endValue),
                  min: 0,
                  max: controller.value.duration.inMilliseconds.toDouble(),
                  onChanged: (RangeValues values) {
                    onChangeStart(values.start);
                    onChangeEnd(values.end);
                    if (controller.value.isPlaying) {
                      onChangePlaybackState(false);
                    }
                  },
                ),
              ),
              Text(
                _formatDuration(Duration(milliseconds: endValue.round())),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  onChangePlaybackState(!controller.value.isPlaying);
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: isProcessing ? null : onApplyTrim,
                child: const Text('Apply Trim'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
