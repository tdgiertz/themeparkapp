// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'park_explorer_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected filter chips for a park.
/// Allowed filters are: 'thrill', 'toddler', 'indoor', 'dining'

@ProviderFor(SelectedFilters)
final selectedFiltersProvider = SelectedFiltersFamily._();

/// Selected filter chips for a park.
/// Allowed filters are: 'thrill', 'toddler', 'indoor', 'dining'
final class SelectedFiltersProvider
    extends $NotifierProvider<SelectedFilters, Set<String>> {
  /// Selected filter chips for a park.
  /// Allowed filters are: 'thrill', 'toddler', 'indoor', 'dining'
  SelectedFiltersProvider._({
    required SelectedFiltersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'selectedFiltersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedFiltersHash();

  @override
  String toString() {
    return r'selectedFiltersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SelectedFilters create() => SelectedFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedFiltersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedFiltersHash() => r'1998776f43cea56bdfe0d5d6de2b314739294222';

/// Selected filter chips for a park.
/// Allowed filters are: 'thrill', 'toddler', 'indoor', 'dining'

final class SelectedFiltersFamily extends $Family
    with
        $ClassFamilyOverride<
          SelectedFilters,
          Set<String>,
          Set<String>,
          Set<String>,
          String
        > {
  SelectedFiltersFamily._()
    : super(
        retry: null,
        name: r'selectedFiltersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Selected filter chips for a park.
  /// Allowed filters are: 'thrill', 'toddler', 'indoor', 'dining'

  SelectedFiltersProvider call(String parkId) =>
      SelectedFiltersProvider._(argument: parkId, from: this);

  @override
  String toString() => r'selectedFiltersProvider';
}

/// Selected filter chips for a park.
/// Allowed filters are: 'thrill', 'toddler', 'indoor', 'dining'

abstract class _$SelectedFilters extends $Notifier<Set<String>> {
  late final _$args = ref.$arg as String;
  String get parkId => _$args;

  Set<String> build(String parkId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Track whether the heatmap overlay is active (Desktop).

@ProviderFor(HeatmapEnabled)
final heatmapEnabledProvider = HeatmapEnabledFamily._();

/// Track whether the heatmap overlay is active (Desktop).
final class HeatmapEnabledProvider
    extends $NotifierProvider<HeatmapEnabled, bool> {
  /// Track whether the heatmap overlay is active (Desktop).
  HeatmapEnabledProvider._({
    required HeatmapEnabledFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'heatmapEnabledProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$heatmapEnabledHash();

  @override
  String toString() {
    return r'heatmapEnabledProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HeatmapEnabled create() => HeatmapEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HeatmapEnabledProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$heatmapEnabledHash() => r'15799bf3364a59ee48bececdf665cf5d3b9740e7';

/// Track whether the heatmap overlay is active (Desktop).

final class HeatmapEnabledFamily extends $Family
    with $ClassFamilyOverride<HeatmapEnabled, bool, bool, bool, String> {
  HeatmapEnabledFamily._()
    : super(
        retry: null,
        name: r'heatmapEnabledProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Track whether the heatmap overlay is active (Desktop).

  HeatmapEnabledProvider call(String parkId) =>
      HeatmapEnabledProvider._(argument: parkId, from: this);

  @override
  String toString() => r'heatmapEnabledProvider';
}

/// Track whether the heatmap overlay is active (Desktop).

abstract class _$HeatmapEnabled extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get parkId => _$args;

  bool build(String parkId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Track the hour offset for the historical crowd flow heatmap (0 = current, 3 = 3 hours ago).

@ProviderFor(HistoryHourOffset)
final historyHourOffsetProvider = HistoryHourOffsetFamily._();

/// Track the hour offset for the historical crowd flow heatmap (0 = current, 3 = 3 hours ago).
final class HistoryHourOffsetProvider
    extends $NotifierProvider<HistoryHourOffset, int> {
  /// Track the hour offset for the historical crowd flow heatmap (0 = current, 3 = 3 hours ago).
  HistoryHourOffsetProvider._({
    required HistoryHourOffsetFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'historyHourOffsetProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyHourOffsetHash();

  @override
  String toString() {
    return r'historyHourOffsetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HistoryHourOffset create() => HistoryHourOffset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryHourOffsetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyHourOffsetHash() => r'281a8ca74dcaa8029e7d36df061ca060cd7a81dd';

/// Track the hour offset for the historical crowd flow heatmap (0 = current, 3 = 3 hours ago).

final class HistoryHourOffsetFamily extends $Family
    with $ClassFamilyOverride<HistoryHourOffset, int, int, int, String> {
  HistoryHourOffsetFamily._()
    : super(
        retry: null,
        name: r'historyHourOffsetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Track the hour offset for the historical crowd flow heatmap (0 = current, 3 = 3 hours ago).

  HistoryHourOffsetProvider call(String parkId) =>
      HistoryHourOffsetProvider._(argument: parkId, from: this);

  @override
  String toString() => r'historyHourOffsetProvider';
}

/// Track the hour offset for the historical crowd flow heatmap (0 = current, 3 = 3 hours ago).

abstract class _$HistoryHourOffset extends $Notifier<int> {
  late final _$args = ref.$arg as String;
  String get parkId => _$args;

  int build(String parkId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Manage the user's location, streaming real GPS if allowed, falling back to park center.

@ProviderFor(UserLocation)
final userLocationProvider = UserLocationFamily._();

/// Manage the user's location, streaming real GPS if allowed, falling back to park center.
final class UserLocationProvider
    extends $NotifierProvider<UserLocation, ParkCoordinate> {
  /// Manage the user's location, streaming real GPS if allowed, falling back to park center.
  UserLocationProvider._({
    required UserLocationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userLocationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userLocationHash();

  @override
  String toString() {
    return r'userLocationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserLocation create() => UserLocation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParkCoordinate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParkCoordinate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserLocationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userLocationHash() => r'296076432c236039b899a596074df12abd097a22';

/// Manage the user's location, streaming real GPS if allowed, falling back to park center.

final class UserLocationFamily extends $Family
    with
        $ClassFamilyOverride<
          UserLocation,
          ParkCoordinate,
          ParkCoordinate,
          ParkCoordinate,
          String
        > {
  UserLocationFamily._()
    : super(
        retry: null,
        name: r'userLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Manage the user's location, streaming real GPS if allowed, falling back to park center.

  UserLocationProvider call(String parkId) =>
      UserLocationProvider._(argument: parkId, from: this);

  @override
  String toString() => r'userLocationProvider';
}

/// Manage the user's location, streaming real GPS if allowed, falling back to park center.

abstract class _$UserLocation extends $Notifier<ParkCoordinate> {
  late final _$args = ref.$arg as String;
  String get parkId => _$args;

  ParkCoordinate build(String parkId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ParkCoordinate, ParkCoordinate>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ParkCoordinate, ParkCoordinate>,
              ParkCoordinate,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
