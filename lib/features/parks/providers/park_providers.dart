import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/core/models/enums.dart';
import 'package:themeparkapp/core/models/favorite.dart';
import 'package:themeparkapp/core/repositories/repositories.dart';
import 'package:themeparkapp/features/dashboard/widgets/upcoming_shows_widget.dart';
import 'package:themeparkapp/features/parks/models/live_data_models.dart';
import 'package:themeparkapp/features/parks/models/park_models.dart';

// Repository Providers
final parkRepositoryProvider = Provider<ParkRepository>(
  (ref) => FakeParkRepository(),
);
final waitTimesRepositoryProvider = Provider<WaitTimesRepository>(
  (ref) => FakeWaitTimesRepository(),
);
final showtimesRepositoryProvider = Provider<ShowtimesRepository>(
  (ref) => FakeShowtimesRepository(),
);
final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FakeFavoritesRepository(),
);
final restaurantsRepositoryProvider = Provider<RestaurantsRepository>(
  (ref) => FakeRestaurantsRepository(),
);
final menusRepositoryProvider = Provider<MenusRepository>(
  (ref) => FakeMenusRepository(),
);

/// Provider for the static park data
final parksProvider = FutureProvider<List<Park>>((ref) {
  final repo = ref.watch(parkRepositoryProvider);
  return repo.fetchParks();
});

/// Provider for live wait times for all rides
final allWaitTimesProvider = FutureProvider<List<RideWaitTime>>((ref) {
  final repo = ref.watch(waitTimesRepositoryProvider);
  return repo.fetchWaitTimes();
});

/// Provider for live showtimes for all shows
final allShowtimesProvider = FutureProvider<List<Showtime>>((ref) async {
  final repo = ref.watch(showtimesRepositoryProvider);
  final schedules = await repo.fetchShowtimes();
  final parks = await ref.watch(parksProvider.future);

  final showtimes = <Showtime>[];
  for (final schedule in schedules) {
    // Find the facility
    Facility? facility;
    for (final park in parks) {
      for (final child in park.children) {
        try {
          facility = child.children.firstWhere(
            (f) => f.id == schedule.facilityId,
          );
          break;
        } catch (_) {}
      }
      if (facility != null) break;
    }

    if (facility != null) {
      for (final time in schedule.showtimes) {
        showtimes.add(
          Showtime(
            showId: schedule.facilityId,
            name: facility.name,
            time: time,
          ),
        );
      }
    }
  }
  return showtimes;
});

/// Provider for derived user favorites
final derivedFavoritesProvider = FutureProvider<List<FavoriteRide>>((
  ref,
) async {
  final repo = ref.watch(favoritesRepositoryProvider);
  final userFavs = await repo.fetchFavorites();
  final waitTimes = await ref.watch(allWaitTimesProvider.future);
  final parks = await ref.watch(parksProvider.future);

  final uiFavorites = <FavoriteRide>[];

  for (final favRef in userFavs.favoriteRides) {
    // Find wait time
    RideWaitTime? wait;
    try {
      wait = waitTimes.firstWhere((w) => w.rideId == favRef.rideId);
    } catch (_) {}

    // Find park and name
    var parkId = '';
    var parkName = '';
    var rideName = '';
    for (final park in parks) {
      for (final child in park.children) {
        try {
          final facility = child.children.firstWhere(
            (f) => f.id == favRef.rideId,
          );
          parkId = park.id;
          parkName = park.name;
          rideName = facility.name;
          break;
        } catch (_) {}
      }
      if (parkId.isNotEmpty) break;
    }

    if (rideName.isNotEmpty) {
      uiFavorites.add(
        FavoriteRide(
          rideId: favRef.rideId,
          name: rideName,
          parkId: parkId,
          parkName: parkName,
          currentWait: wait != null
              ? {'status': WaitTimeStatus.open.jsonValue, 'waitMinutes': wait.waitMinutes}
              : null,
        ),
      );
    }
  }

  return uiFavorites;
});

/// Derived provider that computes the highlights for a specific park.
final parkHighlightsProvider = FutureProvider.family<ParkHighlights, String>((
  ref,
  parkId,
) async {
  final waitTimes = await ref.watch(allWaitTimesProvider.future);
  final showtimes = await ref.watch(allShowtimesProvider.future);
  final parks = await ref.watch(parksProvider.future);

  final park = parks.firstWhere(
    (p) => p.id == parkId,
    orElse: () => throw Exception('Park not found'),
  );

  // Get all ride IDs in this park
  final parkRideIds = park.children
      .expand((child) => child.children)
      .map((facility) => facility.id)
      .toSet();

  // Filter wait times for rides in this park and sort to find shortest (top 2)
  final parkWaitTimes =
      waitTimes.where((wt) => parkRideIds.contains(wt.rideId)).toList()
        ..sort((a, b) => a.waitMinutes.compareTo(b.waitMinutes));
  final shortestWaitTimes = parkWaitTimes.take(2).toList();

  final parkShowtimes = showtimes
      .where((st) => parkRideIds.contains(st.showId))
      .toList();
  final nextShowtimes = parkShowtimes.isNotEmpty
      ? [parkShowtimes.first]
      : <Showtime>[];

  return ParkHighlights(
    shortestWaitTimes: shortestWaitTimes,
    nextShowtimes: nextShowtimes,
  );
});

/// Derived provider for upcoming show events combining park data and show schedules
final upcomingShowsProvider = FutureProvider<List<ShowEvent>>((ref) async {
  try {
    final parks = await ref.watch(parksProvider.future);
    final schedules = await ref
        .watch(showtimesRepositoryProvider)
        .fetchShowtimes();

    final scheduleMap = <String, List<String>>{
      for (final s in schedules) s.facilityId: s.showtimes,
    };

    final shows = <ShowEvent>[];

    for (final park in parks) {
      for (final land in park.children) {
        for (final facility in land.children) {
          if (facility.categoryEnum.isShow ||
              scheduleMap.containsKey(facility.id)) {
            final times = scheduleMap[facility.id] ?? const [];

            for (final rawTime in times) {
              final formattedTime = formatShowtimeString(rawTime);
              shows.add(
                ShowEvent(
                  id: facility.id,
                  parkId: park.id,
                  parkName: park.name,
                  title: facility.name,
                  startTime: formattedTime,
                  venue: land.name,
                  category: facility.category.isNotEmpty
                      ? facility.category
                      : FacilityCategory.show.displayName,
                  durationMinutes: 20,
                  isOnlyPerformanceToday: times.length == 1,
                  scarcityTag: times.length == 1
                      ? 'Only Performance Today'
                      : null,
                ),
              );
            }
          }
        }
      }
    }

    return shows;
  } catch (_) {
    return <ShowEvent>[];
  }
});

String formatShowtimeString(String time24) {
  try {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    var hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final ampm = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final minStr = minute.toString().padLeft(2, '0');
    return '$hour:$minStr $ampm';
  } catch (_) {
    return time24;
  }
}
