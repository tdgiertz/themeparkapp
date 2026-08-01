import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themeparkapp/core/models/favorite.dart';
import 'package:themeparkapp/core/models/park.dart';
import 'package:themeparkapp/core/models/park_detail.dart';
import 'package:themeparkapp/core/models/wait_time.dart';
import 'package:themeparkapp/core/theme.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';

part 'providers.g.dart';

/// Application-wide Riverpod providers.
/// Keep business logic decoupled from UI and expose state via providers.

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}

/// Theme mode provider: system / light / dark
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  // ignore: use_setters_to_change_properties
  void updateThemeMode(ThemeMode mode) => state = mode;
}

/// Theme seed color state notifier with SharedPreferences persistence.
@Riverpod(keepAlive: true)
class ThemeSeedColor extends _$ThemeSeedColor {
  static const String _key = 'theme_seed_color';

  @override
  Color? build() {
    _loadFromPrefs();
    return AppTheme.primaryAccent;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorVal = prefs.getInt(_key);
      if (colorVal != null) {
        state = Color(colorVal);
      }
    } catch (_) {}
  }

  Future<void> setColor(Color color) async {
    state = color;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, color.toARGB32());
    } catch (_) {}
  }
}

/// Example async provider that simulates fetching details
@riverpod
Future<String> details(Ref ref) async {
  // simulate network delay
  await Future<void>.delayed(const Duration(milliseconds: 350));
  return 'Details loaded from provider';
}

/// Asset loader provider: can be overridden in tests
/// to avoid Flutter asset bundling.
@Riverpod(keepAlive: true)
Future<String> Function(String) assetLoader(Ref ref) {
  return rootBundle.loadString;
}

// Type alias to keep provider signatures short and readable.
typedef AssetLoader = Future<String> Function(String);

/// ---------------------- Parks (StateNotifier) ----------------------
@Riverpod(keepAlive: true)
class Parks extends _$Parks {
  // Timestamp of last successful load. Null if never loaded
  // or explicitly marked stale.
  DateTime? lastLoaded;

  // Consider data stale after this duration.
  static const Duration _staleDuration = Duration(minutes: 5);

  bool get isStale =>
      lastLoaded == null ||
      DateTime.now().difference(lastLoaded!) > _staleDuration;

  void markStale() => lastLoaded = null;

  @override
  FutureOr<ParksResponse> build() async {
    return _load();
  }

  Future<ParksResponse> _load() async {
    final loader = ref.read(assetLoaderProvider);
    final raw = await loader('assets/data/parks.json');
    final response = ParksResponse.fromJson(json.decode(raw) as Map<String, dynamic>);
    lastLoaded = DateTime.now();
    return response;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

/// ---------------------- Favorites (FutureProvider) ----------------------
@riverpod
Future<FavoritesResponse> favorites(Ref ref) async {
  final rides = await ref.watch(derivedFavoritesProvider.future);
  return FavoritesResponse(
    userId: 'user-9876',
    lastUpdated: DateTime.now().toIso8601String(),
    favoriteRides: rides,
  );
}

/// ---------------------- ParkDetail (family StateNotifier) ----------------------
@Riverpod(keepAlive: true)
class ParkDetailNotifier extends _$ParkDetailNotifier {
  DateTime? lastLoaded;
  static const Duration _staleDuration = Duration(minutes: 5);
  
  bool get isStale =>
      lastLoaded == null ||
      DateTime.now().difference(lastLoaded!) > _staleDuration;
      
  void markStale() => lastLoaded = null;

  @override
  FutureOr<ParkDetail> build(String parkId) async {
    return _load();
  }

  Future<ParkDetail> _load() async {
    try {
      final loader = ref.read(assetLoaderProvider);
      final raw = await loader('assets/data/parks.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>? ?? {};
      final parks = data['parks'] as List? ?? decoded['parks'] as List? ?? [];
      Map<String, dynamic>? parkData;
      for (final p in parks) {
        if (p is Map && p['id'] == parkId) {
          parkData = Map<String, dynamic>.from(p);
          break;
        }
      }
      
      final response = parkData != null
          ? ParkDetail.fromJson({'park': parkData})
          : ParkDetail.fromJson(<String, dynamic>{});
          
      lastLoaded = DateTime.now();
      return response;
    } catch (_) {
      return ParkDetail.fromJson(<String, dynamic>{});
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

/// ---------------------- WaitTimes (family StateNotifier) ----------------------
@Riverpod(keepAlive: true)
class WaitTimes extends _$WaitTimes {
  DateTime? lastLoaded;
  static const Duration _staleDuration = Duration(minutes: 5);
  
  bool get isStale =>
      lastLoaded == null ||
      DateTime.now().difference(lastLoaded!) > _staleDuration;
      
  void markStale() => lastLoaded = null;

  @override
  FutureOr<WaitTimesResponse> build(String parkId) async {
    return _loadInitial();
  }

  Future<WaitTimesResponse> _loadInitial() async {
    final loader = ref.read(assetLoaderProvider);
    final raw = await loader('assets/data/wait_times.json');
    final response = WaitTimesResponse.fromJson(json.decode(raw) as Map<String, dynamic>);
    lastLoaded = DateTime.now();
    return response;
  }

  Future<void> refresh() async {
    final currentResponse = state.value;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final loader = ref.read(assetLoaderProvider);
      final raw = await loader('assets/data/wait_times_update.json');
      final updateResponse = WaitTimesResponse.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );

      final baseResponse =
          currentResponse ??
          WaitTimesResponse.fromJson(
            json.decode(await loader('assets/data/wait_times.json'))
                as Map<String, dynamic>,
          );

      final mergedMap = {for (final w in baseResponse.waitTimes) w.rideId: w};
      for (final update in updateResponse.waitTimes) {
        mergedMap[update.rideId] = update;
      }

      final newResponse = WaitTimesResponse(
        meta: updateResponse.meta ?? baseResponse.meta,
        waitTimes: mergedMap.values.cast<WaitTime>().toList(),
      );
      
      lastLoaded = DateTime.now();
      return newResponse;
    });
    
    // Fallback block mapping logic... handled properly by AsyncValue.guard
    if (state.hasError && currentResponse != null) {
      state = AsyncData(currentResponse);
    }
  }
}
