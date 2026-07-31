import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themeparkapp/core/theme.dart';
import 'package:themeparkapp/models/favorite.dart';
import 'package:themeparkapp/models/park.dart';
import 'package:themeparkapp/models/park_detail.dart';
import 'package:themeparkapp/models/wait_time.dart';

/// Application-wide Riverpod providers.
/// Keep business logic decoupled from UI and expose state via providers.
final counterProvider = StateProvider<int>((ref) => 0);

/// Theme mode provider: system / light / dark
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Theme seed color state notifier with SharedPreferences persistence.
class ThemeSeedColorNotifier extends StateNotifier<Color?> {
  ThemeSeedColorNotifier() : super(AppTheme.primaryAccent) {
    _loadFromPrefs();
  }

  static const String _key = 'theme_seed_color';

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
      await prefs.setInt(_key, color.value);
    } catch (_) {}
  }
}

final themeSeedColorProvider =
    StateNotifierProvider<ThemeSeedColorNotifier, Color?>((ref) {
  return ThemeSeedColorNotifier();
});

/// Example async provider that simulates fetching details
final detailsProvider = FutureProvider<String>((ref) async {
  // simulate network delay
  await Future<void>.delayed(const Duration(milliseconds: 350));
  return 'Details loaded from provider';
});

/// Asset loader provider: can be overridden in tests
/// to avoid Flutter asset bundling.
final assetLoaderProvider = Provider<Future<String> Function(String)>(
  (ref) => rootBundle.loadString,
);

// Type alias to keep provider signatures short and readable.
typedef AssetLoader = Future<String> Function(String);

/// ---------------------- Parks (StateNotifier) ----------------------
class ParksNotifier extends StateNotifier<AsyncValue<ParksResponse>> {
  ParksNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }
  final Ref ref;

  // Timestamp of last successful load. Null if never loaded
  // or explicitly marked stale.
  DateTime? lastLoaded;

  // Consider data stale after this duration.
  static const Duration _staleDuration = Duration(minutes: 5);

  bool get isStale =>
      lastLoaded == null ||
      DateTime.now().difference(lastLoaded!) > _staleDuration;

  void markStale() => lastLoaded = null;

  Future<void> _load() async {
    try {
      final loader = ref.read(assetLoaderProvider);
      final raw = await loader('assets/data/parks.json');
      if (mounted) {
        state = AsyncValue.data(
          ParksResponse.fromJson(json.decode(raw) as Map<String, dynamic>),
        );
        lastLoaded = DateTime.now();
      }
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}

final parksProvider =
    StateNotifierProvider<ParksNotifier, AsyncValue<ParksResponse>>((ref) {
      return ParksNotifier(ref);
    });

/// ---------------------- Favorites (StateNotifier) ----------------------
class FavoritesNotifier extends StateNotifier<AsyncValue<FavoritesResponse>> {
  FavoritesNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }
  final Ref ref;

  DateTime? lastLoaded;
  static const Duration _staleDuration = Duration(minutes: 5);
  bool get isStale =>
      lastLoaded == null ||
      DateTime.now().difference(lastLoaded!) > _staleDuration;
  void markStale() => lastLoaded = null;

  Future<void> _load() async {
    try {
      final loader = ref.read(assetLoaderProvider);
      final raw = await loader('assets/data/favorites.json');
      if (mounted) {
        state = AsyncValue.data(
          FavoritesResponse.fromJson(json.decode(raw) as Map<String, dynamic>),
        );
        lastLoaded = DateTime.now();
      }
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<FavoritesResponse>>((
      ref,
    ) {
      return FavoritesNotifier(ref);
    });

/// ---------------------- ParkDetail (family StateNotifier) ----------------------
class ParkDetailNotifier extends StateNotifier<AsyncValue<ParkDetail>> {
  ParkDetailNotifier(this.ref, this.parkId)
    : super(const AsyncValue.loading()) {
    _load();
  }
  final Ref ref;
  final String parkId;

  DateTime? lastLoaded;
  static const Duration _staleDuration = Duration(minutes: 5);
  bool get isStale =>
      lastLoaded == null ||
      DateTime.now().difference(lastLoaded!) > _staleDuration;
  void markStale() => lastLoaded = null;

  Future<void> _load() async {
    try {
      final loader = ref.read(assetLoaderProvider);
      final raw = await loader('assets/data/attractions.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final parks = decoded['parks'] as List? ?? [];
      final parkData = parks.firstWhere(
        (e) => (e as Map<String, dynamic>)['id'] == parkId,
        orElse: () => null,
      );
      if (mounted) {
        if (parkData != null) {
          state = AsyncValue.data(
            ParkDetail.fromJson({'park': parkData}),
          );
        } else {
          state = AsyncValue.data(ParkDetail.fromJson(<String, dynamic>{}));
        }
        lastLoaded = DateTime.now();
      }
    } catch (_) {
      if (mounted) {
        state = AsyncValue.data(ParkDetail.fromJson(<String, dynamic>{}));
      }
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}

final parkDetailProvider =
    StateNotifierProvider.family<
      ParkDetailNotifier,
      AsyncValue<ParkDetail>,
      String
    >((ref, parkId) {
      return ParkDetailNotifier(ref, parkId);
    });

/// ---------------------- WaitTimes (family StateNotifier) ----------------------
class WaitTimesNotifier extends StateNotifier<AsyncValue<WaitTimesResponse>> {
  WaitTimesNotifier(this.ref, this.parkId) : super(const AsyncValue.loading()) {
    _loadInitial();
  }
  final Ref ref;
  final String parkId;

  DateTime? lastLoaded;
  static const Duration _staleDuration = Duration(minutes: 5);
  bool get isStale =>
      lastLoaded == null ||
      DateTime.now().difference(lastLoaded!) > _staleDuration;
  void markStale() => lastLoaded = null;

  Future<void> _loadInitial() async {
    try {
      final loader = ref.read(assetLoaderProvider);
      final raw = await loader('assets/data/wait_times.json');
      if (mounted) {
        state = AsyncValue.data(
          WaitTimesResponse.fromJson(json.decode(raw) as Map<String, dynamic>),
        );
        lastLoaded = DateTime.now();
      }
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    final currentResponse = state.valueOrNull;

    try {
      final loader = ref.read(assetLoaderProvider);
      final raw = await loader('assets/data/wait_times_update.json');
      final updateResponse = WaitTimesResponse.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );

      final baseResponse = currentResponse ??
          WaitTimesResponse.fromJson(
            json.decode(await loader('assets/data/wait_times.json'))
                as Map<String, dynamic>,
          );

      final mergedMap = {for (final w in baseResponse.waitTimes) w.rideId: w};
      for (final update in updateResponse.waitTimes) {
        mergedMap[update.rideId] = update;
      }

      if (mounted) {
        state = AsyncValue.data(
          WaitTimesResponse(
            meta: updateResponse.meta ?? baseResponse.meta,
            waitTimes: mergedMap.values.toList(),
          ),
        );
        lastLoaded = DateTime.now();
      }
    } catch (_) {
      if (mounted) {
        if (currentResponse != null) {
          state = AsyncValue.data(currentResponse);
        } else {
          await _loadInitial();
        }
      }
    }
  }
}

final waitTimesProvider =
    StateNotifierProvider.family<
      WaitTimesNotifier,
      AsyncValue<WaitTimesResponse>,
      String
    >((ref, parkId) {
      return WaitTimesNotifier(ref, parkId);
    });
