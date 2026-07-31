import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/features/favorites/favorites_page.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/models/favorite.dart';

class MockFavoritesNotifier extends FavoritesNotifier {
  MockFavoritesNotifier(Ref ref, AsyncValue<FavoritesResponse> state) : super(ref) {
    this.state = state;
  }
}

void main() {
  testWidgets('FavoritesPage loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((ref) => MockFavoritesNotifier(ref, const AsyncValue.loading())),
        ],
        child: const MaterialApp(home: FavoritesPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('FavoritesPage error state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith(
              (ref) => MockFavoritesNotifier(ref, const AsyncValue.error('Error', StackTrace.empty))),
        ],
        child: const MaterialApp(home: FavoritesPage()),
      ),
    );

    expect(find.text('Error loading favorites'), findsOneWidget);
  });

  testWidgets('FavoritesPage data state with data', (WidgetTester tester) async {
    final mockFavorites = [
      FavoriteRide(
        rideId: 'f1',
        parkId: 'p1',
        name: 'Attraction 1',
        parkName: 'Park 1',
        currentWait: {'status': 'Open', 'waitMinutes': 45},
      ),
      FavoriteRide(
        rideId: 'f2',
        parkId: 'p1',
        name: 'Attraction 2',
        parkName: 'Park 1',
        currentWait: {'status': 'Closed'},
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((ref) => MockFavoritesNotifier(ref, AsyncValue.data(FavoritesResponse(userId: 'u1', lastUpdated: DateTime.now().toIso8601String(), favoriteRides: mockFavorites)))),
        ],
        child: const MaterialApp(home: FavoritesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('Attraction 1'), findsOneWidget);
    expect(find.text('Attraction 2'), findsOneWidget);
    expect(find.textContaining('45'), findsOneWidget);
    expect(find.text('-'), findsOneWidget); // null/closed wait time
  });
  
  testWidgets('FavoritesPage empty data state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((ref) => MockFavoritesNotifier(ref, AsyncValue.data(FavoritesResponse(userId: 'u1', lastUpdated: DateTime.now().toIso8601String(), favoriteRides: [])))),
        ],
        child: const MaterialApp(home: FavoritesPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNothing);
  });
}
