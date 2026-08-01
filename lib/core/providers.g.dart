// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Application-wide Riverpod providers.
/// Keep business logic decoupled from UI and expose state via providers.

@ProviderFor(Counter)
final counterProvider = CounterProvider._();

/// Application-wide Riverpod providers.
/// Keep business logic decoupled from UI and expose state via providers.
final class CounterProvider extends $NotifierProvider<Counter, int> {
  /// Application-wide Riverpod providers.
  /// Keep business logic decoupled from UI and expose state via providers.
  CounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterHash();

  @$internal
  @override
  Counter create() => Counter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$counterHash() => r'4243b34530f53accfd9014a9f0e316fe304ada3e';

/// Application-wide Riverpod providers.
/// Keep business logic decoupled from UI and expose state via providers.

abstract class _$Counter extends $Notifier<int> {
  int build();
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
    element.handleCreate(ref, build);
  }
}

/// Theme mode provider: system / light / dark

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// Theme mode provider: system / light / dark
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// Theme mode provider: system / light / dark
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'21098a6ac98ee372e04ca080813cee7a17a665e6';

/// Theme mode provider: system / light / dark

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Theme seed color state notifier with SharedPreferences persistence.

@ProviderFor(ThemeSeedColor)
final themeSeedColorProvider = ThemeSeedColorProvider._();

/// Theme seed color state notifier with SharedPreferences persistence.
final class ThemeSeedColorProvider
    extends $NotifierProvider<ThemeSeedColor, Color?> {
  /// Theme seed color state notifier with SharedPreferences persistence.
  ThemeSeedColorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeSeedColorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeSeedColorHash();

  @$internal
  @override
  ThemeSeedColor create() => ThemeSeedColor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color?>(value),
    );
  }
}

String _$themeSeedColorHash() => r'575117da8d6f8790f015fb9da1fb7519771d72a9';

/// Theme seed color state notifier with SharedPreferences persistence.

abstract class _$ThemeSeedColor extends $Notifier<Color?> {
  Color? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Color?, Color?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Color?, Color?>,
              Color?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Example async provider that simulates fetching details

@ProviderFor(details)
final detailsProvider = DetailsProvider._();

/// Example async provider that simulates fetching details

final class DetailsProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Example async provider that simulates fetching details
  DetailsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detailsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detailsHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return details(ref);
  }
}

String _$detailsHash() => r'85dd60afb465bce62d6fd9e2e954843655fed888';

/// Asset loader provider: can be overridden in tests
/// to avoid Flutter asset bundling.

@ProviderFor(assetLoader)
final assetLoaderProvider = AssetLoaderProvider._();

/// Asset loader provider: can be overridden in tests
/// to avoid Flutter asset bundling.

final class AssetLoaderProvider
    extends
        $FunctionalProvider<
          Future<String> Function(String),
          Future<String> Function(String),
          Future<String> Function(String)
        >
    with $Provider<Future<String> Function(String)> {
  /// Asset loader provider: can be overridden in tests
  /// to avoid Flutter asset bundling.
  AssetLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetLoaderHash();

  @$internal
  @override
  $ProviderElement<Future<String> Function(String)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<String> Function(String) create(Ref ref) {
    return assetLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<String> Function(String) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<String> Function(String)>(
        value,
      ),
    );
  }
}

String _$assetLoaderHash() => r'5e1da121fa7412e26de6e419583549ebe7d08f0c';

/// ---------------------- Parks (StateNotifier) ----------------------

@ProviderFor(Parks)
final parksProvider = ParksProvider._();

/// ---------------------- Parks (StateNotifier) ----------------------
final class ParksProvider extends $AsyncNotifierProvider<Parks, ParksResponse> {
  /// ---------------------- Parks (StateNotifier) ----------------------
  ParksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parksHash();

  @$internal
  @override
  Parks create() => Parks();
}

String _$parksHash() => r'754202e106d1c6aa5f6b85413d44c4b7b70a714f';

/// ---------------------- Parks (StateNotifier) ----------------------

abstract class _$Parks extends $AsyncNotifier<ParksResponse> {
  FutureOr<ParksResponse> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ParksResponse>, ParksResponse>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ParksResponse>, ParksResponse>,
              AsyncValue<ParksResponse>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// ---------------------- Favorites (FutureProvider) ----------------------

@ProviderFor(favorites)
final favoritesProvider = FavoritesProvider._();

/// ---------------------- Favorites (FutureProvider) ----------------------

final class FavoritesProvider
    extends
        $FunctionalProvider<
          AsyncValue<FavoritesResponse>,
          FavoritesResponse,
          FutureOr<FavoritesResponse>
        >
    with
        $FutureModifier<FavoritesResponse>,
        $FutureProvider<FavoritesResponse> {
  /// ---------------------- Favorites (FutureProvider) ----------------------
  FavoritesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesHash();

  @$internal
  @override
  $FutureProviderElement<FavoritesResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FavoritesResponse> create(Ref ref) {
    return favorites(ref);
  }
}

String _$favoritesHash() => r'd5a71c182bce96742b8ab3640c156b153bc08e90';

/// ---------------------- ParkDetail (family StateNotifier) ----------------------

@ProviderFor(ParkDetailNotifier)
final parkDetailProvider = ParkDetailNotifierFamily._();

/// ---------------------- ParkDetail (family StateNotifier) ----------------------
final class ParkDetailNotifierProvider
    extends $AsyncNotifierProvider<ParkDetailNotifier, ParkDetail> {
  /// ---------------------- ParkDetail (family StateNotifier) ----------------------
  ParkDetailNotifierProvider._({
    required ParkDetailNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'parkDetailProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$parkDetailNotifierHash();

  @override
  String toString() {
    return r'parkDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ParkDetailNotifier create() => ParkDetailNotifier();

  @override
  bool operator ==(Object other) {
    return other is ParkDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$parkDetailNotifierHash() =>
    r'3919c4449d939ba17bd5fe018b6b1d502715a0c9';

/// ---------------------- ParkDetail (family StateNotifier) ----------------------

final class ParkDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ParkDetailNotifier,
          AsyncValue<ParkDetail>,
          ParkDetail,
          FutureOr<ParkDetail>,
          String
        > {
  ParkDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'parkDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// ---------------------- ParkDetail (family StateNotifier) ----------------------

  ParkDetailNotifierProvider call(String parkId) =>
      ParkDetailNotifierProvider._(argument: parkId, from: this);

  @override
  String toString() => r'parkDetailProvider';
}

/// ---------------------- ParkDetail (family StateNotifier) ----------------------

abstract class _$ParkDetailNotifier extends $AsyncNotifier<ParkDetail> {
  late final _$args = ref.$arg as String;
  String get parkId => _$args;

  FutureOr<ParkDetail> build(String parkId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ParkDetail>, ParkDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ParkDetail>, ParkDetail>,
              AsyncValue<ParkDetail>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// ---------------------- WaitTimes (family StateNotifier) ----------------------

@ProviderFor(WaitTimes)
final waitTimesProvider = WaitTimesFamily._();

/// ---------------------- WaitTimes (family StateNotifier) ----------------------
final class WaitTimesProvider
    extends $AsyncNotifierProvider<WaitTimes, WaitTimesResponse> {
  /// ---------------------- WaitTimes (family StateNotifier) ----------------------
  WaitTimesProvider._({
    required WaitTimesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'waitTimesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$waitTimesHash();

  @override
  String toString() {
    return r'waitTimesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WaitTimes create() => WaitTimes();

  @override
  bool operator ==(Object other) {
    return other is WaitTimesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$waitTimesHash() => r'0a5960bcb76229263e8a8773edc95d1c1dc3b1b1';

/// ---------------------- WaitTimes (family StateNotifier) ----------------------

final class WaitTimesFamily extends $Family
    with
        $ClassFamilyOverride<
          WaitTimes,
          AsyncValue<WaitTimesResponse>,
          WaitTimesResponse,
          FutureOr<WaitTimesResponse>,
          String
        > {
  WaitTimesFamily._()
    : super(
        retry: null,
        name: r'waitTimesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// ---------------------- WaitTimes (family StateNotifier) ----------------------

  WaitTimesProvider call(String parkId) =>
      WaitTimesProvider._(argument: parkId, from: this);

  @override
  String toString() => r'waitTimesProvider';
}

/// ---------------------- WaitTimes (family StateNotifier) ----------------------

abstract class _$WaitTimes extends $AsyncNotifier<WaitTimesResponse> {
  late final _$args = ref.$arg as String;
  String get parkId => _$args;

  FutureOr<WaitTimesResponse> build(String parkId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<WaitTimesResponse>, WaitTimesResponse>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WaitTimesResponse>, WaitTimesResponse>,
              AsyncValue<WaitTimesResponse>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
