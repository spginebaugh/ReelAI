import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlaybackSpeedButton extends StatelessWidget {
  final VideoPlayerController? videoPlayerController;
  static const List<double> _speeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0
  ];

  const PlaybackSpeedButton({
    Key? key,
    required this.videoPlayerController,
  }) : super(key: key);

  void _showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _speeds.length,
            itemBuilder: (context, index) {
              final speed = _speeds[index];
              return ListTile(
                dense: true,
                title: Text('${speed}x'),
                onTap: () {
                  videoPlayerController?.setPlaybackSpeed(speed);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.speed),
      onPressed: videoPlayerController != null
          ? () => _showSpeedDialog(context)
          : null,
    );
  }
}
