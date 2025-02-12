// Video editing constants
class VideoConstants {
  static const int maxVideoDuration = 300; // 5 minutes in seconds
  static const int minVideoDuration = 3; // 3 seconds
  static const double maxVideoSize = 100 * 1024 * 1024; // 100MB in bytes

  // FFmpeg filter presets
  static const Map<String, String> videoFilters = {
    'none': '',
    'sepia':
        'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131',
    'grayscale': 'colorchannelmixer=.3:.59:.11:0:.3:.59:.11:0:.3:.59:.11',
    'vintage': 'curves=vintage',
    'vignette': 'vignette=PI/4',
  };
}

// Video processing status messages
class VideoProcessingMessages {
  static const String processing = 'Processing video...';
  static const String success = 'Video processed successfully';
  static const String error = 'Error processing video';
  static const String cancelled = 'Video processing cancelled';
}
