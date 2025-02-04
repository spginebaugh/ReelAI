import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/video.dart';
import '../router/route_names.dart';

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
        onTap: () => context.pushNamed(
          RouteNames.video,
          pathParameters: {'id': video.id},
          extra: video.videoUrl,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => context.pushNamed(
            RouteNames.editVideo,
            pathParameters: {'id': video.id},
            extra: video,
          ),
        ),
      ),
    );
  }
}
