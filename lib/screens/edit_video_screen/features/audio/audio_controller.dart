import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../state/audio_language_provider.dart';
import '../../../../state/audio_player_provider.dart';

part 'audio_controller.g.dart';

@riverpod
class AudioController extends _$AudioController {
  @override
  void build() {
    // No initial state needed
  }

  Future<void> switchLanguage(String videoId, String language) async {
    await ref
        .read(audioPlayerControllerProvider.notifier)
        .switchLanguage(videoId, language);
  }

  void refreshLanguages(String videoId) {
    ref.invalidate(audioLanguageControllerProvider(videoId));
  }
}
