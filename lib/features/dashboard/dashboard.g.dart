// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Track whether user has manually modified the dashboard park selection

@ProviderFor(IsParkSelectionManual)
final isParkSelectionManualProvider = IsParkSelectionManualProvider._();

/// Track whether user has manually modified the dashboard park selection
final class IsParkSelectionManualProvider
    extends $NotifierProvider<IsParkSelectionManual, bool> {
  /// Track whether user has manually modified the dashboard park selection
  IsParkSelectionManualProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isParkSelectionManualProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isParkSelectionManualHash();

  @$internal
  @override
  IsParkSelectionManual create() => IsParkSelectionManual();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isParkSelectionManualHash() =>
    r'bb9ab00b70e2c3d8f6d62dc5aee6d44827b04440';

/// Track whether user has manually modified the dashboard park selection

abstract class _$IsParkSelectionManual extends $Notifier<bool> {
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
