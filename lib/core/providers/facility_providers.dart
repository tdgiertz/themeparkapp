import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/core/database/database.dart';
import 'package:themeparkapp/core/repositories/facility_details_repository.dart';
import 'package:themeparkapp/core/repositories/favorites_repository.dart';
import 'package:themeparkapp/core/repositories/wait_times_repository.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';

/// Provider for WaitTimesRepository
final driftWaitTimesRepositoryProvider = Provider<WaitTimesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return WaitTimesRepository(db);
});

/// Provider for FavoritesRepository
final driftFavoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FavoritesRepository(db);
});

/// Provider for FacilityDetailsRepository
final facilityDetailsRepositoryProvider = Provider<FacilityDetailsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return FacilityDetailsRepository(db);
});

/// StreamProvider.family for latest wait time of a given facility
final latestWaitTimeProvider = StreamProvider.family<WaitTime?, String>((ref, facilityId) {
  final repo = ref.watch(driftWaitTimesRepositoryProvider);
  return repo.watchLatestWaitTime(facilityId);
});

/// StreamProvider for favorite locations
final favoriteLocationsProvider = StreamProvider<List<Location>>((ref) {
  final repo = ref.watch(driftFavoritesRepositoryProvider);
  return repo.watchFavoriteLocations();
});

/// FutureProvider.family for facility menu
final facilityMenuProvider = FutureProvider.family<List<MenuCategoryWithItems>, String>((ref, facilityId) {
  final repo = ref.watch(facilityDetailsRepositoryProvider);
  return repo.getMenu(facilityId);
});
