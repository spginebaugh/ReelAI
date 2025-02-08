// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle_language_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subtitleLanguageControllerHash() =>
    r'034150dda0edd239e146eb0b3b756911e0da3910';

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

abstract class _$SubtitleLanguageController
    extends BuildlessAutoDisposeAsyncNotifier<List<String>> {
  late final String videoId;

  FutureOr<List<String>> build(
    String videoId,
  );
}

/// See also [SubtitleLanguageController].
@ProviderFor(SubtitleLanguageController)
const subtitleLanguageControllerProvider = SubtitleLanguageControllerFamily();

/// See also [SubtitleLanguageController].
class SubtitleLanguageControllerFamily
    extends Family<AsyncValue<List<String>>> {
  /// See also [SubtitleLanguageController].
  const SubtitleLanguageControllerFamily();

  /// See also [SubtitleLanguageController].
  SubtitleLanguageControllerProvider call(
    String videoId,
  ) {
    return SubtitleLanguageControllerProvider(
      videoId,
    );
  }

  @override
  SubtitleLanguageControllerProvider getProviderOverride(
    covariant SubtitleLanguageControllerProvider provider,
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
  String? get name => r'subtitleLanguageControllerProvider';
}

/// See also [SubtitleLanguageController].
class SubtitleLanguageControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SubtitleLanguageController,
        List<String>> {
  /// See also [SubtitleLanguageController].
  SubtitleLanguageControllerProvider(
    String videoId,
  ) : this._internal(
          () => SubtitleLanguageController()..videoId = videoId,
          from: subtitleLanguageControllerProvider,
          name: r'subtitleLanguageControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subtitleLanguageControllerHash,
          dependencies: SubtitleLanguageControllerFamily._dependencies,
          allTransitiveDependencies:
              SubtitleLanguageControllerFamily._allTransitiveDependencies,
          videoId: videoId,
        );

  SubtitleLanguageControllerProvider._internal(
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
    covariant SubtitleLanguageController notifier,
  ) {
    return notifier.build(
      videoId,
    );
  }

  @override
  Override overrideWith(SubtitleLanguageController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SubtitleLanguageControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<SubtitleLanguageController,
      List<String>> createElement() {
    return _SubtitleLanguageControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubtitleLanguageControllerProvider &&
        other.videoId == videoId;
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
mixin SubtitleLanguageControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<String>> {
  /// The parameter `videoId` of this provider.
  String get videoId;
}

class _SubtitleLanguageControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SubtitleLanguageController,
        List<String>> with SubtitleLanguageControllerRef {
  _SubtitleLanguageControllerProviderElement(super.provider);

  @override
  String get videoId => (origin as SubtitleLanguageControllerProvider).videoId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
