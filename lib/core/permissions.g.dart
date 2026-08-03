// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes and manages location permission state for the app.

@ProviderFor(LocationPermissionNotifier)
final locationPermissionProvider = LocationPermissionNotifierProvider._();

/// Exposes and manages location permission state for the app.
final class LocationPermissionNotifierProvider
    extends $NotifierProvider<LocationPermissionNotifier, LocationPermission?> {
  /// Exposes and manages location permission state for the app.
  LocationPermissionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPermissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPermissionNotifierHash();

  @$internal
  @override
  LocationPermissionNotifier create() => LocationPermissionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationPermission? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationPermission?>(value),
    );
  }
}

String _$locationPermissionNotifierHash() =>
    r'f2935749b862d8bd60df32d081d40b51f9b7ffa4';

/// Exposes and manages location permission state for the app.

abstract class _$LocationPermissionNotifier
    extends $Notifier<LocationPermission?> {
  LocationPermission? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LocationPermission?, LocationPermission?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocationPermission?, LocationPermission?>,
              LocationPermission?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
