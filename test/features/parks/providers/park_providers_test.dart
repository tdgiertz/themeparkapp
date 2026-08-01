import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/repositories/repositories.dart';
import 'package:themeparkapp/features/parks/models/extra_models.dart';
import 'package:themeparkapp/features/parks/models/live_data_models.dart';
import 'package:themeparkapp/features/parks/models/park_models.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';

class MockParkRepository implements ParkRepository {
  @override
  Future<List<Park>> fetchParks() async {
    return [
      const Park(
        id: 'park1',
        type: 'ThemePark',
        name: 'Magic Park',
        operatingHours: OperatingHours(open: '09:00', close: '21:00'),
        crowdLevel: 'Moderate',
        children: [
          ParkChild(
            id: 'land1',
            type: 'Land',
            name: 'Fantasyland',
            children: [
              Facility(
                id: 'ride1',
                type: 'Attraction',
                category: 'Ride',
                name: 'Magic Ride',
                thrillLevel: 'Low',
                heightRequirementInches: 0,
              ),
              Facility(
                id: 'show1',
                type: 'Attraction',
                category: 'Show',
                name: 'Magic Show',
                thrillLevel: 'Low',
                heightRequirementInches: 0,
              ),
            ],
          )
        ],
      )
    ];
  }
}

class MockWaitTimesRepository implements WaitTimesRepository {
  @override
  Future<List<RideWaitTime>> fetchWaitTimes() async {
    return [
      const RideWaitTime(rideId: 'ride1', name: 'Magic Ride', waitMinutes: 15),
      const RideWaitTime(rideId: 'ride2', name: 'Unknown Ride', waitMinutes: 30),
    ];
  }
}

class MockShowtimesRepository implements ShowtimesRepository {
  @override
  Future<List<ShowSchedule>> fetchShowtimes() async {
    return [
      const ShowSchedule(facilityId: 'show1', showtimes: ['10:00', '12:00']),
    ];
  }
}

class MockFavoritesRepository implements FavoritesRepository {
  @override
  Future<UserFavorites> fetchFavorites() async {
    return const UserFavorites(
      userId: 'user1',
      lastUpdated: '2026-08-01T00:00:00Z',
      favoriteRides: [FavoriteRideRef(rideId: 'ride1')],
    );
  }
}

void main() {
  group('Park Providers', () {
    test('parksProvider fetches parks', () async {
      final container = ProviderContainer(
        overrides: [
          parkRepositoryProvider.overrideWithValue(MockParkRepository()),
        ],
      );
      addTearDown(container.dispose);

      final parks = await container.read(parksProvider.future);
      expect(parks.length, 1);
      expect(parks.first.id, 'park1');
    });

    test('allWaitTimesProvider fetches wait times', () async {
      final container = ProviderContainer(
        overrides: [
          waitTimesRepositoryProvider.overrideWithValue(MockWaitTimesRepository()),
        ],
      );
      addTearDown(container.dispose);

      final waitTimes = await container.read(allWaitTimesProvider.future);
      expect(waitTimes.length, 2);
    });

    test('allShowtimesProvider correlates schedules with facility names', () async {
      final container = ProviderContainer(
        overrides: [
          parkRepositoryProvider.overrideWithValue(MockParkRepository()),
          showtimesRepositoryProvider.overrideWithValue(MockShowtimesRepository()),
        ],
      );
      addTearDown(container.dispose);

      final showtimes = await container.read(allShowtimesProvider.future);
      expect(showtimes.length, 2); // 2 times for show1
      expect(showtimes[0].showId, 'show1');
      expect(showtimes[0].name, 'Magic Show');
      expect(showtimes[0].time, '10:00');
    });

    test('derivedFavoritesProvider builds UI models with wait times and park info', () async {
      final container = ProviderContainer(
        overrides: [
          parkRepositoryProvider.overrideWithValue(MockParkRepository()),
          waitTimesRepositoryProvider.overrideWithValue(MockWaitTimesRepository()),
          favoritesRepositoryProvider.overrideWithValue(MockFavoritesRepository()),
        ],
      );
      addTearDown(container.dispose);

      final favorites = await container.read(derivedFavoritesProvider.future);
      expect(favorites.length, 1);
      expect(favorites.first.rideId, 'ride1');
      expect(favorites.first.name, 'Magic Ride');
      expect(favorites.first.parkId, 'park1');
      expect(favorites.first.currentWait?['waitMinutes'], 15);
    });

    test('parkHighlightsProvider sorts and filters wait times and showtimes for a park', () async {
      final container = ProviderContainer(
        overrides: [
          parkRepositoryProvider.overrideWithValue(MockParkRepository()),
          waitTimesRepositoryProvider.overrideWithValue(MockWaitTimesRepository()),
          showtimesRepositoryProvider.overrideWithValue(MockShowtimesRepository()),
        ],
      );
      addTearDown(container.dispose);

      final highlights = await container.read(parkHighlightsProvider('park1').future);
      
      expect(highlights.shortestWaitTimes.length, 1); // Only ride1 is in park1
      expect(highlights.shortestWaitTimes.first.rideId, 'ride1');
      expect(highlights.shortestWaitTimes.first.waitMinutes, 15);

      expect(highlights.nextShowtimes.length, 1); // We only pick the first showtime for the highlight
      expect(highlights.nextShowtimes.first.showId, 'show1');
    });
  });
}
