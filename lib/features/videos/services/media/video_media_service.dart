import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:reel_ai/common/utils/storage_paths.dart';
import 'package:reel_ai/common/utils/logger.dart';
import 'package:reel_ai/features/videos/services/processing/ffmpeg_processor.dart';
import 'package:reel_ai/features/videos/services/utils/video_file_utils.dart';

/// Service responsible for managing video media operations including:
/// - Firebase Storage access for media files
/// - Language availability management
/// - Audio/Video synchronization
/// - Playback state management
///
/// Note: For video controller lifecycle management (creation, disposal, muting),
/// use [VideoControllerManager] instead.
class VideoMediaService {
  final FirebaseStorage _storage;
  final FFmpegProcessor _ffmpeg;

  VideoMediaService({
    FirebaseStorage? storage,
    FFmpegProcessor? ffmpeg,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _ffmpeg = ffmpeg ?? FFmpegProcessor();

  /// Fetches a media file from Firebase Storage
  Future<String?> fetchMediaUrl({
    required String userId,
    required String videoId,
    required String type, // 'audio' or 'subtitles'
    String? language,
    String format = 'mp3',
    int maxRetries = 3,
  }) async {
    final path = type == 'audio'
        ? StoragePaths.audioFile(userId, videoId,
            lang: language ?? 'english', ext: format)
        : StoragePaths.subtitlesFile(userId, videoId,
            lang: language ?? 'english', format: format);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        Logger.debug(
            'Fetching $type URL (attempt ${attempt + 1}/$maxRetries)', {
          'path': path,
          'language': language,
        });

        final url = await _storage.ref(path).getDownloadURL();

        Logger.success('Successfully fetched $type URL', {
          'path': path,
        });

        return url;
      } catch (e) {
        if (e.toString().contains('object-not-found')) {
          if (attempt < maxRetries - 1) {
            Logger.debug('$type not ready yet, retrying in 2 seconds...', {
              'attempt': attempt + 1,
              'maxRetries': maxRetries,
            });
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          Logger.warning('$type not found after $maxRetries attempts', {
            'path': path,
          });
          return null;
        }

        Logger.warning('Failed to fetch $type URL', {
          'path': path,
          'error': e.toString(),
        });
        return null;
      }
    }
    return null;
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

      // Extract languages from file names
      final languages = result.items
          .where((ref) => ref.name.endsWith(fileExtension))
          .map((ref) {
            final filename = ref.name;
            // Handle both formats: audio_english.mp3 and audio.english.mp3
            final nameWithoutExt = filename.substring(
              0,
              filename.length - (fileExtension.length + 1),
            );
            final parts = nameWithoutExt.split(RegExp(r'[_.]'));
            if (parts.length < 2) return null;
            return parts.last.toLowerCase();
          })
          .where((lang) => lang != null && lang.isNotEmpty)
          .map((lang) => lang!)
          .toSet() // Remove duplicates
          .toList();

      // Sort languages alphabetically after ensuring English is first
      languages.sort();
      if (languages.contains('english')) {
        languages.remove('english');
        languages.insert(0, 'english');
      }

      Logger.success('Successfully listed $type languages', {
        'languages': languages,
      });

      // Return all found languages, or just English if none found
      return languages.isEmpty ? ['english'] : languages;
    } catch (e) {
      Logger.error('Failed to list $type languages', {
        'error': e.toString(),
        'userId': userId,
        'videoId': videoId,
      });
      // Only return English as fallback if we couldn't access the storage
      return ['english'];
    }
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

  /// Creates a muxed stream with the specified audio language
  Future<File> createMuxedStreamWithAudio({
    required File videoFile,
    required String userId,
    required String videoId,
    required String language,
  }) async {
    File? audioFile;
    File? outputFile;

    try {
      Logger.debug('Creating muxed stream', {
        'videoId': videoId,
        'language': language,
      });

      // Get audio file URL
      final audioUrl = await fetchMediaUrl(
        userId: userId,
        videoId: videoId,
        type: 'audio',
        format: 'mp3',
        language: language,
      );

      if (audioUrl == null) {
        throw Exception('Audio file not found for language: $language');
      }

      // Download audio file
      audioFile = await VideoFileUtils.downloadFile(
        url: audioUrl,
        prefix: 'audio',
        extension: 'mp3',
      );

      // Create output path for muxed file
      outputFile = await VideoFileUtils.createTempVideoFile(
        prefix: 'muxed',
        extension: 'mp4',
      );

      // Create muxed stream
      await _ffmpeg.createMuxedStream(
        videoPath: videoFile.path,
        audioPath: audioFile.path,
        outputPath: outputFile.path,
      );

      Logger.success('Successfully created muxed stream', {
        'videoId': videoId,
        'language': language,
      });

      return outputFile;
    } catch (e) {
      Logger.error('Failed to create muxed stream', {
        'error': e.toString(),
        'videoId': videoId,
        'language': language,
      });

      // Clean up output file if it exists and there was an error
      if (outputFile != null) {
        try {
          await outputFile.delete();
        } catch (e) {
          Logger.warning('Failed to delete output file after error', {
            'error': e.toString(),
          });
        }
      }

      rethrow;
    } finally {
      // Clean up temporary audio file
      if (audioFile != null) {
        try {
          await audioFile.delete();
        } catch (e) {
          Logger.warning('Failed to delete temporary audio file', {
            'error': e.toString(),
          });
        }
      }
    }
  }
}
