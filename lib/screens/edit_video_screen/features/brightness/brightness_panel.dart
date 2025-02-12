import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reel_ai/features/videos/providers/video_edit_provider.dart';

class BrightnessPanel extends ConsumerWidget {
  const BrightnessPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(videoEditControllerProvider);

    return editState.when(
      data: (state) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.brightness_low),
                Expanded(
                  child: Slider(
                    value: state.brightness,
                    min: -1.0,
                    max: 1.0,
                    onChanged: (value) => ref
                        .read(videoEditControllerProvider.notifier)
                        .updateBrightness(value),
                    onChangeEnd: (value) => ref
                        .read(videoEditControllerProvider.notifier)
                        .applyFilters(),
                  ),
                ),
                const Icon(Icons.brightness_high),
              ],
            ),
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
