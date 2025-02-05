/// URL paths for each route in the app
class RoutePaths {
  const RoutePaths._();

  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';

  // Main routes
  static const String home = '/';
  static const String camera = '/camera';
  static const String myVideos = '/my-videos';
  static const String settings = '/settings';
  static const String video = '/video/:id';
  static const String editVideoMetadata = '/video/:id/metadata';
}
