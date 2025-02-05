import 'package:flutter/material.dart';
import 'package:flutter_video_trimmer/flutter_video_trimmer.dart';

class TrimControlsWidget extends StatelessWidget {
  final Trimmer trimmer;
  final double startValue;
  final double endValue;
  final Function(double) onChangeStart;
  final Function(double) onChangeEnd;
  final Function(bool) onChangePlaybackState;

  const TrimControlsWidget({
    super.key,
    required this.trimmer,
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
          child: VideoViewer(trimmer: trimmer),
        ),
        TrimViewer(
          trimmer: trimmer,
          viewerHeight: 50.0,
          viewerWidth: MediaQuery.of(context).size.width * 0.9,
          maxVideoLength: const Duration(seconds: 60), // Using same as original
          onChangeStart: onChangeStart,
          onChangeEnd: onChangeEnd,
          onChangePlaybackState: onChangePlaybackState,
        ),
      ],
    );
  }
}
