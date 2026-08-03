import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:themeparkapp/core/database/database.dart';

/// Service responsible for parsing JSON asset files and populating the Drift database tables.
class DataImportService {
  DataImportService(this.db);

  final AppDatabase db;

  /// Helper to load JSON string from asset or fallback to empty object if asset is missing.
  Future<String?> _loadAssetString(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      return null;
    }
  }

  /// Imports wait time records from a JSON asset, appending them to the WaitTimes table.
  /// Maps 'rideId' or 'facilityId' to 'facilityId'.
  Future<void> importWaitTimes({String assetPath = 'assets/data/wait_times.json'}) async {
    final raw = await _loadAssetString(assetPath);
    if (raw == null) return;

    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final meta = jsonMap['meta'] as Map<String, dynamic>?;
    final defaultTimestampStr = meta?['timestamp'] as String?;
    final defaultTimestamp = defaultTimestampStr != null
        ? DateTime.tryParse(defaultTimestampStr) ?? DateTime.now()
        : DateTime.now();

    final waitTimesList = jsonMap['waitTimes'] as List<dynamic>? ?? [];

    await db.batch((batch) {
      for (final item in waitTimesList) {
        final map = item as Map<String, dynamic>;
        final facilityId = (map['rideId'] ?? map['facilityId']) as String?;
        if (facilityId == null) continue;

        final updatedAtStr = map['updatedAt'] as String?;
        final timestamp = updatedAtStr != null
            ? DateTime.tryParse(updatedAtStr) ?? defaultTimestamp
            : defaultTimestamp;

        final status = (map['status'] as String?) ?? 'Closed';
        final waitMinutes = map['waitMinutes'] as int?;
        final singleRider = (map['singleRider'] as bool?) ?? false;
        final fastLane = (map['fastLane'] as bool?) ?? false;

        batch.insert(
          db.waitTimes,
          WaitTimesCompanion.insert(
            facilityId: facilityId,
            timestamp: timestamp,
            status: status,
            waitMinutes: Value(waitMinutes),
            singleRider: singleRider,
            fastLane: fastLane,
          ),
        );
      }
    });
  }

  /// Imports bookmarked facilities into the Favorites table.
  /// Maps 'rideId' or 'facilityId' to 'facilityId'.
  Future<void> importFavorites({String assetPath = 'assets/data/favorites.json'}) async {
    final raw = await _loadAssetString(assetPath);
    if (raw == null) return;

    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final lastUpdatedStr = jsonMap['lastUpdated'] as String?;
    final savedAt = lastUpdatedStr != null
        ? DateTime.tryParse(lastUpdatedStr) ?? DateTime.now()
        : DateTime.now();

    final favoriteRides = jsonMap['favoriteRides'] as List<dynamic>? ?? [];

    for (final item in favoriteRides) {
      final map = item as Map<String, dynamic>;
      final facilityId = (map['rideId'] ?? map['facilityId']) as String?;
      if (facilityId == null) continue;

      await db.into(db.favorites).insertOnConflictUpdate(
            FavoritesCompanion.insert(
              facilityId: facilityId,
              savedAt: Value(savedAt),
            ),
          );
    }
  }

  /// Imports restaurant metadata into RestaurantDetails table and updates Locations operating hours.
  Future<void> importRestaurantDetails({String assetPath = 'assets/data/restaurants.json'}) async {
    final raw = await _loadAssetString(assetPath);
    if (raw == null) return;

    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final restaurants = jsonMap['restaurants'] as List<dynamic>? ?? [];

    for (final item in restaurants) {
      final map = item as Map<String, dynamic>;
      final facilityId = map['facilityId'] as String?;
      if (facilityId == null) continue;

      final cuisine = map['cuisine'] as String?;
      final priceRange = map['priceRange'] as String?;

      await db.into(db.restaurantDetails).insertOnConflictUpdate(
            RestaurantDetailsCompanion.insert(
              facilityId: facilityId,
              cuisine: Value(cuisine),
              priceRange: Value(priceRange),
            ),
          );

      final operatingHours = map['operatingHours'] as Map<String, dynamic>?;
      if (operatingHours != null) {
        final open = operatingHours['open'] as String?;
        final close = operatingHours['close'] as String?;

        await (db.update(db.locations)..where((tbl) => tbl.id.equals(facilityId))).write(
          LocationsCompanion(
            openTime: Value(open),
            closeTime: Value(close),
          ),
        );
      }
    }
  }

  /// Imports menus into MenuCategories and MenuItems tables.
  /// Resolves restaurantId (e.g. 'r1') to facilityId (e.g. 'a10') using restaurants.json if needed.
  Future<void> importMenus({
    String assetPath = 'assets/data/menus.json',
    String restaurantsAssetPath = 'assets/data/restaurants.json',
  }) async {
    final raw = await _loadAssetString(assetPath);
    if (raw == null) return;

    // Create a mapping from restaurant ID to facility ID
    final restToFacilityMap = <String, String>{};
    final restRaw = await _loadAssetString(restaurantsAssetPath);
    if (restRaw != null) {
      final restJson = json.decode(restRaw) as Map<String, dynamic>;
      final restaurants = restJson['restaurants'] as List<dynamic>? ?? [];
      for (final r in restaurants) {
        final rMap = r as Map<String, dynamic>;
        final id = rMap['id'] as String?;
        final facId = rMap['facilityId'] as String?;
        if (id != null && facId != null) {
          restToFacilityMap[id] = facId;
        }
      }
    }

    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final menusList = jsonMap['menus'] as List<dynamic>? ?? [];

    for (final menuData in menusList) {
      final menuMap = menuData as Map<String, dynamic>;
      final restId = menuMap['restaurantId'] as String?;
      final facilityId = (restId != null ? restToFacilityMap[restId] ?? restId : null) ??
          menuMap['facilityId'] as String?;
      if (facilityId == null) continue;

      final categories = menuMap['categories'] as List<dynamic>? ?? [];
      for (final catData in categories) {
        final catMap = catData as Map<String, dynamic>;
        final catName = (catMap['name'] as String?) ?? 'General';

        final categoryId = await db.into(db.menuCategories).insert(
              MenuCategoriesCompanion.insert(
                facilityId: facilityId,
                name: catName,
              ),
            );

        final items = catMap['items'] as List<dynamic>? ?? [];
        for (final itemData in items) {
          final itemMap = itemData as Map<String, dynamic>;
          final itemName = (itemMap['name'] as String?) ?? '';
          final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
          final description = itemMap['description'] as String?;

          await db.into(db.menuItems).insert(
                MenuItemsCompanion.insert(
                  categoryId: categoryId,
                  name: itemName,
                  price: price,
                  description: Value(description),
                ),
              );
        }
      }
    }
  }

  /// Imports show schedules into the Showtimes table.
  Future<void> importShowtimes({String assetPath = 'assets/data/shows.json'}) async {
    final raw = await _loadAssetString(assetPath);
    if (raw == null) return;

    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final showsList = jsonMap['shows'] as List<dynamic>? ?? [];

    await db.batch((batch) {
      for (final item in showsList) {
        final map = item as Map<String, dynamic>;
        final facilityId = map['facilityId'] as String?;
        if (facilityId == null) continue;

        final showtimes = map['showtimes'] as List<dynamic>? ?? [];
        for (final st in showtimes) {
          final timeStr = st.toString();
          batch.insert(
            db.showtimes,
            ShowtimesCompanion.insert(
              facilityId: facilityId,
              startTime: timeStr,
            ),
          );
        }
      }
    });
  }

  /// Imports all datasets into the database.
  Future<void> importAllData() async {
    await importWaitTimes();
    await importFavorites();
    await importRestaurantDetails();
    await importMenus();
    await importShowtimes();
  }
}
