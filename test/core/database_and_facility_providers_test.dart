// ignore_for_file: avoid_redundant_argument_values

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/database/data_import_service.dart';
import 'package:themeparkapp/core/database/database.dart';
import 'package:themeparkapp/core/providers/facility_providers.dart';
import 'package:themeparkapp/core/repositories/facility_details_repository.dart';
import 'package:themeparkapp/core/repositories/favorites_repository.dart';
import 'package:themeparkapp/core/repositories/wait_times_repository.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late WaitTimesRepository waitTimesRepo;
  late FavoritesRepository favoritesRepo;
  late FacilityDetailsRepository facilityDetailsRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    waitTimesRepo = WaitTimesRepository(db);
    favoritesRepo = FavoritesRepository(db);
    facilityDetailsRepo = FacilityDetailsRepository(db);

    // Ensure Region & Location for foreign key integrity
    await db.into(db.regions).insertOnConflictUpdate(
          RegionsCompanion.insert(
            id: 'park_1',
            name: 'Test Park',
            type: 'Park',
          ),
        );
    await db.into(db.locations).insertOnConflictUpdate(
          LocationsCompanion.insert(
            id: 'a1',
            regionId: 'park_1',
            name: 'Roller Coaster',
            type: 'Ride',
          ),
        );
    await db.into(db.locations).insertOnConflictUpdate(
          LocationsCompanion.insert(
            id: 'a10',
            regionId: 'park_1',
            name: 'Safari Diner',
            type: 'Restaurant',
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('WaitTimesRepository', () {
    test('watchLatestWaitTime and getHistoricalWaitTimes', () async {
      final t1 = DateTime(2026, 7, 29, 10, 0);
      final t2 = DateTime(2026, 7, 29, 12, 0);

      await db.into(db.waitTimes).insert(
            WaitTimesCompanion.insert(
              facilityId: 'a1',
              timestamp: t1,
              status: 'Open',
              waitMinutes: const Value(15),
              singleRider: false,
              fastLane: false,
            ),
          );

      await db.into(db.waitTimes).insert(
            WaitTimesCompanion.insert(
              facilityId: 'a1',
              timestamp: t2,
              status: 'Open',
              waitMinutes: const Value(30),
              singleRider: true,
              fastLane: true,
            ),
          );

      final latest = await waitTimesRepo.watchLatestWaitTime('a1').first;
      expect(latest, isNotNull);
      expect(latest?.waitMinutes, equals(30));
      expect(latest?.singleRider, isTrue);

      final history = await waitTimesRepo.getHistoricalWaitTimes('a1', t1);
      expect(history.length, equals(2));
      expect(history.first.waitMinutes, equals(15));
      expect(history.last.waitMinutes, equals(30));
    });
  });

  group('FavoritesRepository', () {
    test('toggleFavorite inserts and removes favorite, watchFavoriteLocations joins locations', () async {
      // Seeded with a1 and a3
      var favs = await favoritesRepo.watchFavoriteLocations().first;
      expect(favs, isNotEmpty);
      final initialCount = favs.length;

      // Toggle favorite a1 -> remove
      await favoritesRepo.toggleFavorite('a1');
      favs = await favoritesRepo.watchFavoriteLocations().first;
      expect(favs.length, equals(initialCount - 1));

      // Toggle favorite a1 -> re-add
      await favoritesRepo.toggleFavorite('a1');
      favs = await favoritesRepo.watchFavoriteLocations().first;
      expect(favs.length, equals(initialCount));
    });
  });

  group('FacilityDetailsRepository', () {
    test('getRestaurantDetails, getMenu, and watchShowtimes', () async {
      final details = await facilityDetailsRepo.getRestaurantDetails('a10');
      expect(details, isNotNull);
      expect(details?.cuisine, equals('American'));
      expect(details?.priceRange, equals(r'$$'));

      final menu = await facilityDetailsRepo.getMenu('a10');
      expect(menu, isNotEmpty);
      expect(menu.first.category.name, equals('Entrees'));
      expect(menu.first.items, isNotEmpty);

      final shows = await facilityDetailsRepo.watchShowtimes('a100').first;
      expect(shows, isNotEmpty);
      expect(shows.first.startTime, equals('11:00'));
    });
  });

  group('Riverpod Providers Wiring', () {
    test('providers resolve with overridden AppDatabase', () async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      final waitRepo = container.read(driftWaitTimesRepositoryProvider);
      expect(waitRepo, isNotNull);

      final favRepo = container.read(driftFavoritesRepositoryProvider);
      expect(favRepo, isNotNull);

      final detailsRepo = container.read(facilityDetailsRepositoryProvider);
      expect(detailsRepo, isNotNull);

      // Verify facilityMenuProvider
      final menuAsync = await container.read(facilityMenuProvider('a10').future);
      expect(menuAsync, isNotEmpty);
    });
  });

  group('DataImportService', () {
    test('importAllData populates database tables from JSON assets', () async {
      final importService = DataImportService(db);
      await importService.importAllData();

      final latestWait = await waitTimesRepo.watchLatestWaitTime('a1').first;
      expect(latestWait, isNotNull);

      final menu = await facilityDetailsRepo.getMenu('a10');
      expect(menu, isNotEmpty);
    });
  });
}
