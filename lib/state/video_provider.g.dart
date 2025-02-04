// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoServiceHash() => r'bf5ca06ff14e6a89d2dad291276ff26da4a304a0';

/// See also [videoService].
@ProviderFor(videoService)
final videoServiceProvider = AutoDisposeProvider<VideoService>.internal(
  videoService,
  name: r'videoServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$videoServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideoServiceRef = AutoDisposeProviderRef<VideoService>;
String _$videosHash() => r'056c7d5b6bef353a6a60b77a5033cb17c9610700';

/// See also [videos].
@ProviderFor(videos)
final videosProvider = AutoDisposeStreamProvider<List<Video>>.internal(
  videos,
  name: r'videosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$videosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VideosRef = AutoDisposeStreamProviderRef<List<Video>>;
String _$userVideosHash() => r'9e3ffdf37174f8650a623f29828dbb3412dcaee6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [userVideos].
@ProviderFor(userVideos)
const userVideosProvider = UserVideosFamily();

/// See also [userVideos].
class UserVideosFamily extends Family<AsyncValue<List<Video>>> {
  /// See also [userVideos].
  const UserVideosFamily();

  /// See also [userVideos].
  UserVideosProvider call(
    String userId,
  ) {
    return UserVideosProvider(
      userId,
    );
  }

  @override
  UserVideosProvider getProviderOverride(
    covariant UserVideosProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userVideosProvider';
}

/// See also [userVideos].
class UserVideosProvider extends AutoDisposeStreamProvider<List<Video>> {
  /// See also [userVideos].
  UserVideosProvider(
    String userId,
  ) : this._internal(
          (ref) => userVideos(
            ref as UserVideosRef,
            userId,
          ),
          from: userVideosProvider,
          name: r'userVideosProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userVideosHash,
          dependencies: UserVideosFamily._dependencies,
          allTransitiveDependencies:
              UserVideosFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserVideosProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<Video>> Function(UserVideosRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserVideosProvider._internal(
        (ref) => create(ref as UserVideosRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Video>> createElement() {
    return _UserVideosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserVideosProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserVideosRef on AutoDisposeStreamProviderRef<List<Video>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserVideosProviderElement
    extends AutoDisposeStreamProviderElement<List<Video>> with UserVideosRef {
  _UserVideosProviderElement(super.provider);

  @override
  String get userId => (origin as UserVideosProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
