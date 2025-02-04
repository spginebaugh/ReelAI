import 'package:flutter/material.dart';
import '../models/video.dart';
import '../screens/video_screen.dart';
import '../screens/edit_video_screen.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  const VideoCard({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(video.title),
        subtitle: Text('Uploaded on: ${video.uploadTime.toLocal()}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(videoUrl: video.videoUrl),
            ),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditVideoScreen(video: video),
              ),
            );
          },
        ),
      ),
    );
  }
}
