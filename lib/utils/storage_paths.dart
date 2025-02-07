/// Utility class for generating consistent Firebase Storage paths across the app.
///
/// This class provides static methods to generate storage paths for various
/// file types including videos, audio, subtitles, thumbnails, and user content.
class StoragePaths {
  // Private constructor to prevent instantiation
  StoragePaths._();

  // Base paths
  static const _videoPath = 'video';
  static const _audioPath = 'audio';
  static const _subtitlesPath = 'subtitles';
  static const _thumbnailPath = 'thumbnail';
  static const _profilePath = 'profile_pic';
  static const _publicPath = 'public';
  static const _assetsPath = 'assets';

  /// Returns the storage path for a video file
  /// Format: {userId}/{videoId}/video/video.mp4
  static String videoFile(String userId, String videoId) =>
      '$userId/$videoId/$_videoPath/video.mp4';

  /// Returns the storage path for an audio file with optional language and extension
  /// Format: {userId}/{videoId}/audio/audio_{lang}.{ext}
  static String audioFile(
    String userId,
    String videoId, {
    String lang = 'english',
    String ext = 'wav',
  }) {
    assert(ext == 'wav' || ext == 'mp3',
        'Audio extension must be either wav or mp3');
    return '$userId/$videoId/$_audioPath/audio_$lang.$ext';
  }

  /// Returns the storage path for a subtitles file with optional language
  /// Format: {userId}/{videoId}/subtitles/subtitles_{lang}.json
  static String subtitlesFile(
    String userId,
    String videoId, {
    String lang = 'english',
  }) =>
      '$userId/$videoId/$_subtitlesPath/subtitles_$lang.json';

  /// Returns the storage path for a video thumbnail
  /// Format: {userId}/{videoId}/thumbnail/thumbnail.png
  static String thumbnailFile(String userId, String videoId) =>
      '$userId/$videoId/$_thumbnailPath/thumbnail.png';

  /// Returns the storage path for a user's profile picture
  /// Format: {userId}/profile_pic/profile_pic.png
  static String profilePicture(String userId) =>
      '$userId/$_profilePath/profile_pic.png';

  /// Returns the directory path for all files related to a specific video
  /// Format: {userId}/{videoId}
  static String videoDirectory(String userId, String videoId) =>
      '$userId/$videoId';

  /// Returns the root directory path for a user
  /// Format: {userId}
  static String userDirectory(String userId) => userId;

  /// Returns the storage path for a temporary file
  /// Format: {userId}/temp/{filename}
  static String temporaryFile(String userId, String filename) =>
      '$userId/temp/$filename';

  /// Returns the storage path for a public asset in the default assets folder
  /// Format: public/assets/{assetName}
  static String publicAsset(String assetName) =>
      '$_publicPath/$_assetsPath/$assetName';

  /// Returns the storage path for a public asset in a specific category
  /// Format: public/{category}/{assetName}
  static String publicCategoryAsset(String category, String assetName) =>
      '$_publicPath/$category/$assetName';

  /// Returns the storage path for a public category directory
  /// Format: public/{category}
  static String publicCategory(String category) => '$_publicPath/$category';
}
