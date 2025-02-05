import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TrimControlsWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final double startValue;
  final double endValue;
  final Function(double) onChangeStart;
  final Function(double) onChangeEnd;
  final Function(bool) onChangePlaybackState;
  final VoidCallback onApplyTrim;
  final bool isProcessing;

  const TrimControlsWidget({
    super.key,
    required this.controller,
    required this.startValue,
    required this.endValue,
    required this.onChangeStart,
    required this.onChangeEnd,
    required this.onChangePlaybackState,
    required this.onApplyTrim,
    this.isProcessing = false,
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
        Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: isProcessing ? null : onApplyTrim,
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Apply Trim'),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrimSlider extends StatefulWidget {
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
  State<_TrimSlider> createState() => _TrimSliderState();
}

class _TrimSliderState extends State<_TrimSlider> {
  void _updateVideoPosition(double position) {
    widget.controller.seekTo(Duration(milliseconds: position.toInt()));
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
      widget.onChangePlaybackState(false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Add listener for playback position
    widget.controller.addListener(_onVideoProgress);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoProgress);
    super.dispose();
  }

  void _onVideoProgress() {
    if (!mounted) return;
    final position = widget.controller.value.position.inMilliseconds.toDouble();
    // If playback reaches end value, seek back to start value
    if (position >= widget.endValue) {
      widget.controller
          .seekTo(Duration(milliseconds: widget.startValue.toInt()));
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        widget.onChangePlaybackState(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.controller.value.duration.inMilliseconds.toDouble();

    // Ensure endValue doesn't exceed duration
    final validEndValue =
        widget.endValue > duration ? duration : widget.endValue;
    // Ensure startValue is less than endValue
    final validStartValue = widget.startValue >= validEndValue
        ? validEndValue - 1000
        : widget.startValue;

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              widget.controller.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
            onPressed: () {
              if (widget.controller.value.isPlaying) {
                widget.controller.pause();
                widget.onChangePlaybackState(false);
              } else {
                // When playing, ensure we're within the trim range
                final position =
                    widget.controller.value.position.inMilliseconds.toDouble();
                if (position < validStartValue || position >= validEndValue) {
                  widget.controller
                      .seekTo(Duration(milliseconds: validStartValue.toInt()));
                }
                widget.controller.play();
                widget.onChangePlaybackState(true);
              }
            },
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RangeSlider(
                  values: RangeValues(validStartValue, validEndValue),
                  min: 0,
                  max: duration,
                  divisions: 100,
                  onChanged: (RangeValues values) {
                    // Ensure we don't exceed the video duration
                    final end = values.end > duration ? duration : values.end;
                    final start =
                        values.start >= end ? end - 1000 : values.start;

                    // Update preview based on which handle was moved
                    final oldStart = validStartValue;
                    final oldEnd = validEndValue;

                    if (start != oldStart) {
                      _updateVideoPosition(start);
                    } else if (end != oldEnd) {
                      _updateVideoPosition(end);
                    }

                    widget.onChangeStart(start);
                    widget.onChangeEnd(end);
                  },
                  labels: RangeLabels(
                    '${(validStartValue / 1000).toStringAsFixed(1)}s',
                    '${(validEndValue / 1000).toStringAsFixed(1)}s',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(validStartValue / 1000).toStringAsFixed(1)}s',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${(validEndValue / 1000).toStringAsFixed(1)}s',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
