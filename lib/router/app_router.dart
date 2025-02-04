import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/video.dart';
import '../screens/camera_screen.dart';
import '../screens/edit_video_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/my_videos_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/video_screen.dart';
import '../state/auth_provider.dart';
import '../state/video_provider.dart';
import 'route_names.dart';
import 'route_paths.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.signup;

      if (!isLoggedIn) {
        return isAuthRoute ? null : RoutePaths.login;
      }

      if (isAuthRoute) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),

      // Main routes
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.camera,
        name: RouteNames.camera,
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: RoutePaths.myVideos,
        name: RouteNames.myVideos,
        builder: (context, state) => const MyVideosScreen(),
      ),
      GoRoute(
        path: RoutePaths.upload,
        name: RouteNames.upload,
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.video,
        name: RouteNames.video,
        builder: (context, state) {
          final videoId = state.pathParameters['id']!;
          final videoUrl = state.extra as String?;
          if (videoUrl == null) {
            // If videoUrl is not provided in extra, fetch it using the ID
            // You might want to show a loading indicator here
            return const Center(child: CircularProgressIndicator());
          }
          return VideoScreen(videoUrl: videoUrl);
        },
      ),
      GoRoute(
        path: RoutePaths.editVideo,
        name: RouteNames.editVideo,
        builder: (context, state) {
          final videoId = state.pathParameters['id']!;
          final video = state.extra as Video?;
          if (video == null) {
            // If video is not provided in extra, fetch it using the ID
            // You might want to show a loading indicator here
            return const Center(child: CircularProgressIndicator());
          }
          return EditVideoScreen(video: video);
        },
      ),
    ],
  );
}
