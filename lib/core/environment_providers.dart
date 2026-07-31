import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

/// Represents broad device classes used for adaptive UI.
enum DeviceType { mobile, tablet, desktop }

/// Simple screen width holder for UI to write current width into.
final screenWidthProvider = StateProvider<double>((_) => 0);

/// Device type derived from `screenWidthProvider`.
final deviceTypeProvider = Provider<DeviceType>((ref) {
  final width = ref.watch(screenWidthProvider);
  if (width <= 600) return DeviceType.mobile;
  if (width <= 1024) return DeviceType.tablet;
  return DeviceType.desktop;
});

/// Connectivity stream provider (online/offline + type).
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Battery level provider (percent 0-100) polled once and on change.
final _battery = Battery();
final batteryLevelProvider = FutureProvider<int>((ref) async {
  try {
    final level = await _battery.batteryLevel;
    return level;
  } catch (_) {
    return 100; // optimistic default
  }
});

/// Location stream provider using Geolocator. Consumers should request
/// permissions and handle errors appropriately.
final locationStreamProvider = StreamProvider<Position>((ref) {
  return Geolocator.getPositionStream(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
  );
});

/// Derived media quality preference used by widgets to downgrade heavy media.
/// Simple heuristic: if connectivity is none or battery < 20 => low quality.
enum MediaQuality { high, low }

final mediaQualityProvider = Provider<MediaQuality>((ref) {
  final conn = ref.watch(connectivityStreamProvider).asData?.value;
  final battery = ref.watch(batteryLevelProvider).asData?.value ?? 100;

  if (conn == ConnectivityResult.none) return MediaQuality.low;
  if (battery < 20) return MediaQuality.low;
  // For cell connections we conservatively prefer low when unknown.
  if (conn == ConnectivityResult.ethernet || conn == ConnectivityResult.wifi) {
    return MediaQuality.high;
  }
  return MediaQuality.low;
});
