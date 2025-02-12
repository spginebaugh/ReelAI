// Video editing constants
class VideoConstants {
  static const int maxVideoDuration = 300; // 5 minutes in seconds
  static const int minVideoDuration = 3; // 3 seconds
  static const double maxVideoSize = 100 * 1024 * 1024; // 100MB in bytes
}

// Video processing status messages
class VideoProcessingMessages {
  static const String processing = 'Processing video...';
  static const String success = 'Video processed successfully';
  static const String error = 'Error processing video';
  static const String cancelled = 'Video processing cancelled';
}
