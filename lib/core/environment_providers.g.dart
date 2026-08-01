// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Simple screen width holder for UI to write current width into.

@ProviderFor(ScreenWidth)
final screenWidthProvider = ScreenWidthProvider._();

/// Simple screen width holder for UI to write current width into.
final class ScreenWidthProvider extends $NotifierProvider<ScreenWidth, double> {
  /// Simple screen width holder for UI to write current width into.
  ScreenWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'screenWidthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$screenWidthHash();

  @$internal
  @override
  ScreenWidth create() => ScreenWidth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$screenWidthHash() => r'6b208c50200adf137d9bb42b2a6fc0056ca42db1';

/// Simple screen width holder for UI to write current width into.

abstract class _$ScreenWidth extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
