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

String _$selectedParkIdHash() => r'b6ba3b40fe565379ba0e0e08ca583d044f9a2e6d';

abstract class _$SelectedParkId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
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

String _$globalParkFilterHash() => r'ff0eddd04403b1cef0578784896fb6a6bcd7b234';

abstract class _$GlobalParkFilter extends $Notifier<ParkFilters> {
  ParkFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ParkFilters, ParkFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ParkFilters, ParkFilters>,
              ParkFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
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

String _$parkWaitTimeSortHash() => r'240b973b88f0db70352d0db95f5b3cc161a10d6c';

abstract class _$ParkWaitTimeSort extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
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
    r'0ae749c78d3eeba8b9506dd0e554d787ba521fdc';

abstract class _$ParkFilterDrawerOpen extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
