// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_player_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AudioPlayerStateImpl _$$AudioPlayerStateImplFromJson(
        Map<String, dynamic> json) =>
    _$AudioPlayerStateImpl(
      audioPlayer: _audioPlayerFromJson(json['audioPlayer']),
      isInitialized: json['isInitialized'] as bool? ?? false,
      isPlaying: json['isPlaying'] as bool? ?? false,
      position: json['position'] == null
          ? Duration.zero
          : _durationFromJson((json['position'] as num).toInt()),
      currentLanguage: json['currentLanguage'] as String? ?? 'english',
      isSyncing: json['isSyncing'] as bool? ?? false,
    );

Map<String, dynamic> _$$AudioPlayerStateImplToJson(
        _$AudioPlayerStateImpl instance) =>
    <String, dynamic>{
      'audioPlayer': toJsonSafe(instance.audioPlayer),
      'isInitialized': instance.isInitialized,
      'isPlaying': instance.isPlaying,
      'position': _durationToJson(instance.position),
      'currentLanguage': instance.currentLanguage,
      'isSyncing': instance.isSyncing,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioPlayerControllerHash() =>
    r'8fa5e62389636501bb194d6a782fd596ad908837';

/// Provider that manages audio playback and synchronization with video
///
/// Copied from [AudioPlayerController].
@ProviderFor(AudioPlayerController)
final audioPlayerControllerProvider =
    NotifierProvider<AudioPlayerController, AudioPlayerState>.internal(
  AudioPlayerController.new,
  name: r'audioPlayerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioPlayerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AudioPlayerController = Notifier<AudioPlayerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
