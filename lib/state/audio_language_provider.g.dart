// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_language_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$audioLanguageControllerHash() =>
    r'12ff57bf717177020911b8e383ff61f4440a9314';

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

abstract class _$AudioLanguageController
    extends BuildlessAutoDisposeAsyncNotifier<List<String>> {
  late final String videoId;

  FutureOr<List<String>> build(
    String videoId,
  );
}

/// Provider that manages the list of available audio languages for a video
///
/// Copied from [AudioLanguageController].
@ProviderFor(AudioLanguageController)
const audioLanguageControllerProvider = AudioLanguageControllerFamily();

/// Provider that manages the list of available audio languages for a video
///
/// Copied from [AudioLanguageController].
class AudioLanguageControllerFamily extends Family<AsyncValue<List<String>>> {
  /// Provider that manages the list of available audio languages for a video
  ///
  /// Copied from [AudioLanguageController].
  const AudioLanguageControllerFamily();

  /// Provider that manages the list of available audio languages for a video
  ///
  /// Copied from [AudioLanguageController].
  AudioLanguageControllerProvider call(
    String videoId,
  ) {
    return AudioLanguageControllerProvider(
      videoId,
    );
  }

  @override
  AudioLanguageControllerProvider getProviderOverride(
    covariant AudioLanguageControllerProvider provider,
  ) {
    return call(
      provider.videoId,
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
  String? get name => r'audioLanguageControllerProvider';
}

/// Provider that manages the list of available audio languages for a video
///
/// Copied from [AudioLanguageController].
class AudioLanguageControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<AudioLanguageController,
        List<String>> {
  /// Provider that manages the list of available audio languages for a video
  ///
  /// Copied from [AudioLanguageController].
  AudioLanguageControllerProvider(
    String videoId,
  ) : this._internal(
          () => AudioLanguageController()..videoId = videoId,
          from: audioLanguageControllerProvider,
          name: r'audioLanguageControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$audioLanguageControllerHash,
          dependencies: AudioLanguageControllerFamily._dependencies,
          allTransitiveDependencies:
              AudioLanguageControllerFamily._allTransitiveDependencies,
          videoId: videoId,
        );

  AudioLanguageControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoId,
  }) : super.internal();

  final String videoId;

  @override
  FutureOr<List<String>> runNotifierBuild(
    covariant AudioLanguageController notifier,
  ) {
    return notifier.build(
      videoId,
    );
  }

  @override
  Override overrideWith(AudioLanguageController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AudioLanguageControllerProvider._internal(
        () => create()..videoId = videoId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoId: videoId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AudioLanguageController, List<String>>
      createElement() {
    return _AudioLanguageControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AudioLanguageControllerProvider && other.videoId == videoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AudioLanguageControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<String>> {
  /// The parameter `videoId` of this provider.
  String get videoId;
}

class _AudioLanguageControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AudioLanguageController,
        List<String>> with AudioLanguageControllerRef {
  _AudioLanguageControllerProviderElement(super.provider);

  @override
  String get videoId => (origin as AudioLanguageControllerProvider).videoId;
}

String _$currentLanguageHash() => r'5f5bebdd7fbf26a1bc945a493781deb4579fe04b';

abstract class _$CurrentLanguage extends BuildlessAutoDisposeNotifier<String> {
  late final String videoId;

  String build(
    String videoId,
  );
}

/// Provider that manages the currently selected audio language
///
/// Copied from [CurrentLanguage].
@ProviderFor(CurrentLanguage)
const currentLanguageProvider = CurrentLanguageFamily();

/// Provider that manages the currently selected audio language
///
/// Copied from [CurrentLanguage].
class CurrentLanguageFamily extends Family<String> {
  /// Provider that manages the currently selected audio language
  ///
  /// Copied from [CurrentLanguage].
  const CurrentLanguageFamily();

  /// Provider that manages the currently selected audio language
  ///
  /// Copied from [CurrentLanguage].
  CurrentLanguageProvider call(
    String videoId,
  ) {
    return CurrentLanguageProvider(
      videoId,
    );
  }

  @override
  CurrentLanguageProvider getProviderOverride(
    covariant CurrentLanguageProvider provider,
  ) {
    return call(
      provider.videoId,
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
  String? get name => r'currentLanguageProvider';
}

/// Provider that manages the currently selected audio language
///
/// Copied from [CurrentLanguage].
class CurrentLanguageProvider
    extends AutoDisposeNotifierProviderImpl<CurrentLanguage, String> {
  /// Provider that manages the currently selected audio language
  ///
  /// Copied from [CurrentLanguage].
  CurrentLanguageProvider(
    String videoId,
  ) : this._internal(
          () => CurrentLanguage()..videoId = videoId,
          from: currentLanguageProvider,
          name: r'currentLanguageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentLanguageHash,
          dependencies: CurrentLanguageFamily._dependencies,
          allTransitiveDependencies:
              CurrentLanguageFamily._allTransitiveDependencies,
          videoId: videoId,
        );

  CurrentLanguageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.videoId,
  }) : super.internal();

  final String videoId;

  @override
  String runNotifierBuild(
    covariant CurrentLanguage notifier,
  ) {
    return notifier.build(
      videoId,
    );
  }

  @override
  Override overrideWith(CurrentLanguage Function() create) {
    return ProviderOverride(
      origin: this,
      override: CurrentLanguageProvider._internal(
        () => create()..videoId = videoId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        videoId: videoId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CurrentLanguage, String> createElement() {
    return _CurrentLanguageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentLanguageProvider && other.videoId == videoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, videoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CurrentLanguageRef on AutoDisposeNotifierProviderRef<String> {
  /// The parameter `videoId` of this provider.
  String get videoId;
}

class _CurrentLanguageProviderElement
    extends AutoDisposeNotifierProviderElement<CurrentLanguage, String>
    with CurrentLanguageRef {
  _CurrentLanguageProviderElement(super.provider);

  @override
  String get videoId => (origin as CurrentLanguageProvider).videoId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
