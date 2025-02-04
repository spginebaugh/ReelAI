import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/video.dart';
import '../router/route_names.dart';
import '../utils/app_theme.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  const VideoCard({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      color: AppColors.lightBackground,
      shape: Border(
        bottom: BorderSide(
          color: AppColors.surfaceColor,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          video.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.surfaceColor,
              ),
        ),
        subtitle: Text(
          'Uploaded on: ${video.uploadTime.toLocal()}',
          style: TextStyle(color: AppColors.surfaceColor.withOpacity(0.8)),
        ),
        onTap: () => context.pushNamed(
          RouteNames.video,
          pathParameters: {'id': video.id},
          extra: video.videoUrl,
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.edit,
            color: Theme.of(context).primaryColor,
          ),
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
