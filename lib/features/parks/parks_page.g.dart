// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parks_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedParkId)
final selectedParkIdProvider = SelectedParkIdProvider._();

final class SelectedParkIdProvider
    extends $NotifierProvider<SelectedParkId, String?> {
  SelectedParkIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedParkIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedParkIdHash();

  @$internal
  @override
  SelectedParkId create() => SelectedParkId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedParkIdHash() => r'df6488e6a41b5f123991ac91ca9774e8f285d0d7';

abstract class _$SelectedParkId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(GlobalParkFilter)
final globalParkFilterProvider = GlobalParkFilterProvider._();

final class GlobalParkFilterProvider
    extends $NotifierProvider<GlobalParkFilter, ParkFilters> {
  GlobalParkFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalParkFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalParkFilterHash();

  @$internal
  @override
  GlobalParkFilter create() => GlobalParkFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParkFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParkFilters>(value),
    );
  }
}

String _$globalParkFilterHash() => r'e13231d7b18d636b2891ef6dc6355a0d4d1b86a2';

abstract class _$GlobalParkFilter extends $Notifier<ParkFilters> {
  ParkFilters build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ParkFilters, ParkFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ParkFilters, ParkFilters>,
              ParkFilters,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ParkWaitTimeSort)
final parkWaitTimeSortProvider = ParkWaitTimeSortProvider._();

final class ParkWaitTimeSortProvider
    extends $NotifierProvider<ParkWaitTimeSort, String> {
  ParkWaitTimeSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parkWaitTimeSortProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parkWaitTimeSortHash();

  @$internal
  @override
  ParkWaitTimeSort create() => ParkWaitTimeSort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$parkWaitTimeSortHash() => r'7f328ef7658e49afb38bc9390b4902b1b173a869';

abstract class _$ParkWaitTimeSort extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ParkFilterDrawerOpen)
final parkFilterDrawerOpenProvider = ParkFilterDrawerOpenProvider._();

final class ParkFilterDrawerOpenProvider
    extends $NotifierProvider<ParkFilterDrawerOpen, bool> {
  ParkFilterDrawerOpenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parkFilterDrawerOpenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parkFilterDrawerOpenHash();

  @$internal
  @override
  ParkFilterDrawerOpen create() => ParkFilterDrawerOpen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$parkFilterDrawerOpenHash() =>
    r'2b55cd310a35f91e1dac100fedebc7c29d0cdf69';

abstract class _$ParkFilterDrawerOpen extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
