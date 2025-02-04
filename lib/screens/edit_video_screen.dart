import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/video.dart';

class EditVideoScreen extends StatefulWidget {
  final Video video;
  const EditVideoScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video.url)
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: false,
          looping: false,
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          aspectRatio: _controller.value.aspectRatio,
          allowedScreenSleep: false,
        );
        setState(() {}); // Refresh after initialization
      });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.video.title}'),
      ),
      body: Column(
        children: [
          if (_controller.value.isInitialized) ...[
            Expanded(
              child: Center(
                child: Container(
                  color: Colors.black,
                  child: Chewie(controller: _chewieController!),
                ),
              ),
            ),
          ] else
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          // We'll add editing controls here later
        ],
      ),
    );
  }
}
