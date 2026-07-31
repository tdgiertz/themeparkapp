import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:themeparkapp/core/permissions.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';

/// Representation of a park's geofence center and radius.
class ParkGeofence {
  const ParkGeofence({
    required this.parkId,
    required this.parkName,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 3000.0,
  });

  final String parkId;
  final String parkName;
  final double latitude;
  final double longitude;
  final double radiusMeters;
}

/// Known park geofences for location-aware auto-selection.
const parkGeofences = <ParkGeofence>[
  ParkGeofence(
    parkId: 'p1',
    parkName: 'Animal Kingdom',
    latitude: 28.3575,
    longitude: -81.5907,
  ),
  ParkGeofence(
    parkId: 'p2',
    parkName: 'Magic Kingdom',
    latitude: 28.4200,
    longitude: -81.5812,
  ),
  ParkGeofence(
    parkId: 'p3',
    parkName: 'Epcot',
    latitude: 28.3747,
    longitude: -81.5494,
  ),
  ParkGeofence(
    parkId: 'p4',
    parkName: 'Hollywood Studios',
    latitude: 28.3575,
    longitude: -81.5582,
  ),
  ParkGeofence(
    parkId: 'p5',
    parkName: 'Universal Studios',
    latitude: 28.4743,
    longitude: -81.4678,
  ),
  ParkGeofence(
    parkId: 'p6',
    parkName: 'Islands of Adventure',
    latitude: 28.4715,
    longitude: -81.4711,
  ),
  ParkGeofence(
    parkId: 'p7',
    parkName: 'Epic Universe',
    latitude: 28.4330,
    longitude: -81.4440,
  ),
];

/// Helper to detect nearest park within geofence radius.
String? detectParkFromCoordinates(double lat, double lng) {
  for (final geofence in parkGeofences) {
    final distance = Geolocator.distanceBetween(
      lat,
      lng,
      geofence.latitude,
      geofence.longitude,
    );
    if (distance <= geofence.radiusMeters) {
      return geofence.parkId;
    }
  }
  return null;
}

/// Provider that monitors user location and returns the detected park ID (or null if outside all parks).
final userDetectedParkIdProvider = Provider<String?>((ref) {
  final perm = ref.watch(locationPermissionProvider);
  if (perm != LocationPermission.always && perm != LocationPermission.whileInUse) {
    return null;
  }
  final coords = ref.watch(userLocationProvider('p2'));
  return detectParkFromCoordinates(coords.latitude, coords.longitude);
});
