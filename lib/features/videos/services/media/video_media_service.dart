import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:reel_ai/common/utils/storage_paths.dart';
import 'package:reel_ai/common/utils/logger.dart';

/// Service for managing video media operations including Firebase Storage access,
/// volume control, and synchronized playback
class VideoMediaService {
  final FirebaseStorage _storage;

  VideoMediaService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Fetches a media file from Firebase Storage
  Future<String> fetchMediaUrl({
    required String userId,
    required String videoId,
    required String type, // 'audio' or 'subtitles'
    String? language,
    String format = 'mp3',
  }) async {
    final path = type == 'audio'
        ? StoragePaths.audioFile(userId, videoId,
            lang: language ?? 'english', ext: format)
        : StoragePaths.subtitlesFile(userId, videoId,
            lang: language ?? 'english', format: format);

    try {
      Logger.debug('Fetching $type URL', {
        'path': path,
        'language': language,
      });

      final url = await _storage.ref(path).getDownloadURL();

      Logger.success('Successfully fetched $type URL', {
        'path': path,
      });

      return url;
    } catch (e) {
      Logger.warning('Failed to fetch $type URL', {
        'path': path,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Lists available languages for a media type
  Future<List<String>> listAvailableLanguages({
    required String userId,
    required String videoId,
    required String type, // 'audio' or 'subtitles'
    required String fileExtension,
  }) async {
    try {
      final dirPath = '${StoragePaths.videoDirectory(userId, videoId)}/$type';
      Logger.debug('Listing $type languages', {
        'path': dirPath,
      });

      final result = await _storage.ref(dirPath).listAll();

      final languages = result.items
          .where((ref) => ref.name.endsWith(fileExtension))
          .map((ref) {
            final parts = ref.name.split('_');
            if (parts.length != 2) return null;
            return parts[1].split('.')[0];
          })
          .where((lang) => lang != null)
          .map((lang) => lang!)
          .toList();

      // Ensure English is first if available
      if (languages.contains('english')) {
        languages.remove('english');
        languages.insert(0, 'english');
      }

      Logger.success('Successfully listed $type languages', {
        'languages': languages,
      });

      return languages;
    } catch (e) {
      Logger.error('Failed to list $type languages', {
        'error': e.toString(),
        'userId': userId,
        'videoId': videoId,
      });
      return ['english']; // Fallback to English
    }
  }

  /// Ensures video player is muted
  Future<void> ensureVideoMuted(VideoPlayerController controller) async {
    Logger.debug('Ensuring video player is muted');

    await controller.setVolume(0);
    if (controller.value.volume > 0) {
      Logger.warning('First mute attempt failed, retrying...');
      await controller.setVolume(0);

      if (controller.value.volume > 0) {
        throw Exception('Failed to mute video player after multiple attempts');
      }
    }
    Logger.debug('Successfully muted video player');
  }

  /// Synchronizes audio and video positions
  Future<void> syncAudioVideo({
    required VideoPlayerController videoController,
    required AudioPlayer audioPlayer,
    required Duration targetPosition,
  }) async {
    Logger.debug('Syncing audio and video positions', {
      'targetPosition': targetPosition.inMilliseconds,
    });

    await Future.wait([
      videoController.seekTo(targetPosition),
      audioPlayer.seek(targetPosition),
    ]);

    Logger.debug('Successfully synced audio and video positions');
  }

  /// Manages playback state changes
  Future<void> updatePlaybackState({
    required VideoPlayerController videoController,
    required AudioPlayer audioPlayer,
    required bool shouldPlay,
  }) async {
    Logger.debug('Updating playback state', {
      'shouldPlay': shouldPlay,
    });

    if (shouldPlay) {
      final playFuture = audioPlayer.play();
      final videoPlayFuture = Future.delayed(
        const Duration(milliseconds: 50),
        () => videoController.play(),
      );
      await Future.wait([playFuture, videoPlayFuture]);
    } else {
      await Future.wait([
        audioPlayer.pause(),
        videoController.pause(),
      ]);
    }

    Logger.debug('Successfully updated playback state');
  }
}
