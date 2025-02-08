import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/storage_paths.dart';
import 'auth_provider.dart';

part 'audio_language_provider.g.dart';

/// Provider that manages the list of available audio languages for a video
@riverpod
class AudioLanguageController extends _$AudioLanguageController {
  @override
  Future<List<String>> build(String videoId) {
    return _loadAvailableLanguages(videoId);
  }

  Future<List<String>> _loadAvailableLanguages(String videoId) async {
    try {
      final storage = FirebaseStorage.instance;
      final user = ref.read(authStateProvider).valueOrNull;

      if (user == null) {
        throw Exception('User must be authenticated to load audio languages');
      }

      final audioDir =
          '${StoragePaths.videoDirectory(user.uid, videoId)}/audio';

      final result = await storage.ref(audioDir).listAll();

      // Extract languages from audio file names (format: audio_language.mp3)
      final languages = result.items
          .where((ref) => ref.name.endsWith('.mp3'))
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

      return languages;
    } catch (e) {
      // If there's an error, return just English as it's our default
      return ['english'];
    }
  }

  /// Refreshes the list of available languages
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider that manages the currently selected audio language
@riverpod
class CurrentLanguage extends _$CurrentLanguage {
  @override
  String build(String videoId) => 'english'; // Default to English

  /// Sets the current audio language
  void setLanguage(String language) {
    state = language;
  }
}
