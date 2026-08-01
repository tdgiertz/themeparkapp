import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/repositories/repositories.dart';
import 'package:themeparkapp/features/dashboard/dashboard.dart';
import 'package:themeparkapp/features/dashboard/widgets/upcoming_shows_widget.dart';
import 'package:themeparkapp/features/parks/models/extra_models.dart';
import 'package:themeparkapp/features/parks/models/live_data_models.dart';
import 'package:themeparkapp/features/parks/models/park_models.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';

class MockParkRepository implements ParkRepository {
  @override
  Future<List<Park>> fetchParks() async => [];
}

class MockWaitTimesRepository implements WaitTimesRepository {
  @override
  Future<List<RideWaitTime>> fetchWaitTimes() async => [];
}

class MockShowtimesRepository implements ShowtimesRepository {
  @override
  Future<List<ShowSchedule>> fetchShowtimes() async => [];
}

class MockFavoritesRepository implements FavoritesRepository {
  @override
  Future<UserFavorites> fetchFavorites() async =>
      const UserFavorites(userId: '', lastUpdated: '', favoriteRides: []);
}

final sampleTestShows = [
  const ShowEvent(
    id: 'show_1',
    parkId: 'p2',
    parkName: 'Magic Kingdom',
    title: 'Festival of Fantasy Parade',
    startTime: '3:00 PM',
    venue: 'Main Street, U.S.A.',
    category: 'Parade',
    durationMinutes: 20,
  ),
  const ShowEvent(
    id: 'show_3',
    parkId: 'p3',
    parkName: 'Epcot',
    title: 'Luminous: The Symphony of Us',
    startTime: '9:00 PM',
    venue: 'World Showcase Lagoon',
    category: 'Nighttime Spectacular',
    durationMinutes: 18,
  ),
];

final testOverrides = [
  parkRepositoryProvider.overrideWithValue(MockParkRepository()),
  waitTimesRepositoryProvider.overrideWithValue(MockWaitTimesRepository()),
  showtimesRepositoryProvider.overrideWithValue(MockShowtimesRepository()),
  favoritesRepositoryProvider.overrideWithValue(MockFavoritesRepository()),
  upcomingShowsProvider.overrideWith((ref) async => sampleTestShows),
];

void main() {
  testWidgets('UpcomingShowsWidget renders upcoming shows correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides,
        child: const MaterialApp(home: Scaffold(body: UpcomingShowsWidget())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Upcoming Shows & Entertainment'), findsOneWidget);
    expect(find.text('Festival of Fantasy Parade'), findsOneWidget);
    expect(find.text('Luminous: The Symphony of Us'), findsOneWidget);
  });

  testWidgets(
    'Dashboard renders park selector, compact weather, upcoming shows and favorites',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides,
          child: const MaterialApp(home: Scaffold(body: Dashboard())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('All Parks'), findsOneWidget);
      expect(find.text('Upcoming Shows & Entertainment'), findsOneWidget);
      expect(find.text('Favorites Matrix'), findsOneWidget);
    },
  );
}
