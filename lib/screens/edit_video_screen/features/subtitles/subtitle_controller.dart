import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../state/subtitle_controller.dart';

part 'subtitle_controller.g.dart';

@riverpod
class SubtitleFeatureController extends _$SubtitleFeatureController {
  @override
  void build() {
    // No initial state needed
  }

  void toggleVisibility() {
    ref.read(subtitleControllerProvider.notifier).toggleVisibility();
  }

  Future<void> loadLanguage(String videoId, String language) async {
    await ref
        .read(subtitleControllerProvider.notifier)
        .loadLanguage(videoId, language);
  }

  List<String> get availableLanguages {
    return ref.read(subtitleControllerProvider.notifier).availableLanguages;
  }
}
