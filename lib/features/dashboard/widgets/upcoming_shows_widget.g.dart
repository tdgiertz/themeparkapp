// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_shows_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedDashboardPark)
final selectedDashboardParkProvider = SelectedDashboardParkProvider._();

final class SelectedDashboardParkProvider
    extends $NotifierProvider<SelectedDashboardPark, String> {
  SelectedDashboardParkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDashboardParkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDashboardParkHash();

  @$internal
  @override
  SelectedDashboardPark create() => SelectedDashboardPark();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedDashboardParkHash() =>
    r'c7dd4e0c9791bed2c6aed3b280c59ac5803fb970';

abstract class _$SelectedDashboardPark extends $Notifier<String> {
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
