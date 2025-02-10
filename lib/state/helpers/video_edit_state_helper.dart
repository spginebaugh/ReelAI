import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/video_edit_state.dart';

/// Helper class for managing VideoEditState operations and updates.
///
/// This class provides utility methods for common state operations and validations,
/// ensuring consistent state management across the video editing flow.
class VideoEditStateHelper {
  /// Checks if the current state allows processing operations.
  ///
  /// Returns false if:
  /// - The state is null
  /// - The state is already processing
  ///
  /// This helps prevent concurrent processing operations.
  static bool canProcess(AsyncValue<VideoEditState> state) {
    final currentState = state.value;
    return !(currentState == null || currentState.isProcessing);
  }

  /// Updates the state while preserving filter information.
  ///
  /// [currentState] The current VideoEditState to update
  /// [updates] Map of properties to update
  ///
  /// Returns a new VideoEditState with the updates applied while preserving filters.
  static VideoEditState updateWithFilters(
    VideoEditState currentState,
    Map<String, dynamic> updates,
  ) {
    return currentState.copyWith(
      isProcessing:
          updates['isProcessing'] as bool? ?? currentState.isProcessing,
      isLoading: updates['isLoading'] as bool? ?? currentState.isLoading,
      isPlaying: updates['isPlaying'] as bool? ?? currentState.isPlaying,
      currentMode: updates['currentMode'] ?? currentState.currentMode,
      startValue: updates['startValue'] as double? ?? currentState.startValue,
      endValue: updates['endValue'] as double? ?? currentState.endValue,
      brightness: updates['brightness'] as double? ?? currentState.brightness,
      selectedFilter: updates['selectedFilter'] ?? currentState.selectedFilter,
      availableFilters: currentState.availableFilters,
    );
  }

  /// Creates a loading state while preserving essential information.
  ///
  /// This is useful when transitioning to a loading state while keeping
  /// important state information intact.
  static VideoEditState createLoadingState(VideoEditState currentState) {
    return currentState.copyWith(
      isProcessing: true,
      isLoading: true,
      availableFilters: currentState.availableFilters,
    );
  }

  /// Validates if the current state is in a valid range for editing.
  ///
  /// This ensures that start and end values are within valid bounds.
  static bool hasValidRange(VideoEditState state) {
    return state.startValue >= 0 &&
        state.endValue > state.startValue &&
        state.endValue <= state.endValue;
  }
}
