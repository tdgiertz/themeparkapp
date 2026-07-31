import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

/// Exposes and manages location permission state for the app.
final locationPermissionProvider =
    StateNotifierProvider<LocationPermissionNotifier, LocationPermission?>(
  (ref) => LocationPermissionNotifier(),
);

class LocationPermissionNotifier extends StateNotifier<LocationPermission?> {
  LocationPermissionNotifier() : super(null) {
    _init();
  }

  Future<void> _init() async {
    await check();
  }

  /// Checks current permission without prompting.
  Future<LocationPermission> check() async {
    try {
      final p = await Geolocator.checkPermission();
      state = p;
      return p;
    } catch (_) {
      state = LocationPermission.denied;
      return LocationPermission.denied;
    }
  }

  /// Requests permission from the user (may show native prompt).
  Future<LocationPermission> request() async {
    final p = await Geolocator.requestPermission();
    state = p;
    return p;
  }

  /// Convenience: check then request if needed.
  Future<LocationPermission> checkAndRequestIfNeeded() async {
    var p = await check();
    if (p == LocationPermission.denied) {
      p = await request();
    }
    return p;
  }
}

/// Simple widget to expose a localized explanation and a button to
/// request permissions on demand. Use in onboarding or settings.
class LocationPermissionRequestTile extends ConsumerWidget {
  const LocationPermissionRequestTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perm = ref.watch(locationPermissionProvider);
    final label = perm == null
        ? 'Permission: unknown'
        : perm == LocationPermission.always ||
                perm == LocationPermission.whileInUse
            ? 'Location: granted'
            : 'Location: denied';

    final loc = AppLocalizations.of(context);

    return ListTile(
      title: Text(label),
      subtitle: Text(loc?.onboarding_body ?? 'Used for in-park maps and contextual features'),
      trailing: ElevatedButton(
        onPressed: () => ref
            .read(locationPermissionProvider.notifier)
            .checkAndRequestIfNeeded(),
        child: Text(loc?.onboarding_request_button ?? 'Request'),
      ),
    );
  }
}
