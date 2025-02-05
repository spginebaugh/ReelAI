import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TrimControlsWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final double startValue;
  final double endValue;
  final Function(double) onChangeStart;
  final Function(double) onChangeEnd;
  final Function(bool) onChangePlaybackState;

  const TrimControlsWidget({
    super.key,
    required this.controller,
    required this.startValue,
    required this.endValue,
    required this.onChangeStart,
    required this.onChangeEnd,
    required this.onChangePlaybackState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        _TrimSlider(
          controller: controller,
          startValue: startValue,
          endValue: endValue,
          onChangeStart: onChangeStart,
          onChangeEnd: onChangeEnd,
          onChangePlaybackState: onChangePlaybackState,
        ),
      ],
    );
  }
}

class _TrimSlider extends StatelessWidget {
  final VideoPlayerController controller;
  final double startValue;
  final double endValue;
  final Function(double) onChangeStart;
  final Function(double) onChangeEnd;
  final Function(bool) onChangePlaybackState;

  const _TrimSlider({
    required this.controller,
    required this.startValue,
    required this.endValue,
    required this.onChangeStart,
    required this.onChangeEnd,
    required this.onChangePlaybackState,
  });

  @override
  Widget build(BuildContext context) {
    final duration = controller.value.duration.inMilliseconds.toDouble();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              if (controller.value.isPlaying) {
                controller.pause();
                onChangePlaybackState(false);
              } else {
                controller.play();
                onChangePlaybackState(true);
              }
            },
          ),
          Expanded(
            child: RangeSlider(
              values: RangeValues(startValue, endValue),
              min: 0,
              max: duration,
              onChanged: (RangeValues values) {
                onChangeStart(values.start);
                onChangeEnd(values.end);

                // Seek to the start position when adjusting the trim
                controller.seekTo(Duration(milliseconds: values.start.toInt()));
                if (controller.value.isPlaying) {
                  controller.pause();
                  onChangePlaybackState(false);
                }
              },
              labels: RangeLabels(
                '${(startValue / 1000).toStringAsFixed(1)}s',
                '${(endValue / 1000).toStringAsFixed(1)}s',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
