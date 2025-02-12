// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_facade.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoMediaHash() => r'82dd8335622817a7d2723b1d903f8eecb8b5affa';

/// Provider for the VideoMediaService
///
/// Copied from [videoMedia].
@ProviderFor(videoMedia)
final videoMediaProvider = Provider<VideoMediaService>.internal(
  videoMedia,
  name: r'videoMediaProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$videoMediaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoMediaRef = ProviderRef<VideoMediaService>;
String _$videoPlayerFacadeHash() => r'74d0f8f8b14e8588efd76f14677a2cbc1f800f73';

/// See also [VideoPlayerFacade].
@ProviderFor(VideoPlayerFacade)
final videoPlayerFacadeProvider = AutoDisposeAsyncNotifierProvider<
    VideoPlayerFacade, VideoPlayerState>.internal(
  VideoPlayerFacade.new,
  name: r'videoPlayerFacadeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$videoPlayerFacadeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VideoPlayerFacade = AutoDisposeAsyncNotifier<VideoPlayerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
