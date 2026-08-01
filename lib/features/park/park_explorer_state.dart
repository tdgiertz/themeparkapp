import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:themeparkapp/core/permissions.dart';

part 'park_explorer_state.g.dart';

/// Coordinate representation for a location in the park.
class ParkCoordinate {
  const ParkCoordinate(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

/// Selected filter chips for a park.
/// Allowed filters are: 'thrill', 'toddler', 'indoor', 'dining'
@riverpod
class SelectedFilters extends _$SelectedFilters {
  @override
  Set<String> build(String parkId) => const {};

  void toggle(String filter) {
    if (state.contains(filter)) {
      state = {...state}..remove(filter);
    } else {
      state = {...state, filter};
    }
  }

  void update(Set<String> newState) {
    state = newState;
  }
}

/// Track whether the heatmap overlay is active (Desktop).
@riverpod
class HeatmapEnabled extends _$HeatmapEnabled {
  @override
  bool build(String parkId) => false;

  void toggle() {
    state = !state;
  }

  void update(bool enabled) {
    state = enabled;
  }
}

/// Track the hour offset for the historical crowd flow heatmap (0 = current, 3 = 3 hours ago).
@riverpod
class HistoryHourOffset extends _$HistoryHourOffset {
  @override
  int build(String parkId) => 0;

  void update(int offset) {
    state = offset;
  }
}

/// Manage the user's location, streaming real GPS if allowed, falling back to park center.
@riverpod
class UserLocation extends _$UserLocation {
  StreamSubscription<Position>? _sub;

  @override
  ParkCoordinate build(String parkId) {
    ref.onDispose(() {
      _stopListening();
    });

    final perm = ref.watch(locationPermissionProvider);
    if (perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse) {
      _startListening();
    } else {
      _stopListening();
    }

    return _defaultCenter(parkId);
  }

  static ParkCoordinate _defaultCenter(String parkId) {
    if (parkId == 'p2') {
      return const ParkCoordinate(28.4200, -81.5812); // Magic Kingdom center
    }
    return const ParkCoordinate(28.3575, -81.5907); // Animal Kingdom center
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
}
