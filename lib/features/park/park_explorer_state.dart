import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:themeparkapp/core/permissions.dart';

/// Coordinate representation for a location in the park.
class ParkCoordinate {
  const ParkCoordinate(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

/// Selected filter chips for a park.
/// Allowed filters are: 'thrill', 'toddler', 'indoor', 'dining'
final selectedFiltersProvider = StateProvider.family<Set<String>, String>((ref, parkId) {
  return <String>{};
});

/// Track whether the heatmap overlay is active (Desktop).
final heatmapEnabledProvider = StateProvider.family<bool, String>((ref, parkId) {
  return false;
});

/// Track the hour offset for the historical crowd flow heatmap (0 = current, 3 = 3 hours ago).
final historyHourOffsetProvider = StateProvider.family<int, String>((ref, parkId) {
  return 0;
});

/// Manage the user's location, streaming real GPS if allowed, falling back to park center.
class UserLocationNotifier extends StateNotifier<ParkCoordinate> {
  UserLocationNotifier(this.ref, this.parkId) : super(_defaultCenter(parkId)) {
    _init();
  }
  final Ref ref;
  final String parkId;
  StreamSubscription<Position>? _sub;

  static ParkCoordinate _defaultCenter(String parkId) {
    if (parkId == 'p2') {
      return const ParkCoordinate(28.4200, -81.5812); // Magic Kingdom center
    }
    return const ParkCoordinate(28.3575, -81.5907); // Animal Kingdom center
  }

  void _init() {
    final perm = ref.read(locationPermissionProvider);
    if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
      _startListening();
    }
    
    // Listen for permission updates
    ref.listen<LocationPermission?>(locationPermissionProvider, (prev, next) {
      if (next == LocationPermission.always || next == LocationPermission.whileInUse) {
        _startListening();
      } else {
        _stopListening();
      }
    });
  }

  void _startListening() {
    _sub?.cancel();
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(
      (pos) {
        state = ParkCoordinate(pos.latitude, pos.longitude);
      },
      onError: (_) {},
    );
  }

  void _stopListening() {
    _sub?.cancel();
    _sub = null;
  }

  /// Manually update position (e.g. for testing/mocking)
  void setPosition(double lat, double lng) {
    state = ParkCoordinate(lat, lng);
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}

final userLocationProvider =
    StateNotifierProvider.family<UserLocationNotifier, ParkCoordinate, String>((ref, parkId) {
  return UserLocationNotifier(ref, parkId);
});
