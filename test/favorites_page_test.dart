import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/models/favorite.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/favorites/favorites_page.dart';

void main() {
  testWidgets('FavoritesPage loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith(
            (ref) => Completer<FavoritesResponse>().future,
          ),
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
            // Use a proper Exception object instead of a String. 
            // Riverpod and Dart's async Zone handle these much better.
            (ref) => Future.error(Exception('Error')),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: FavoritesPage())),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(Column),
        matching: find.textContaining('Error loading favorites'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('FavoritesPage data state with data', (
    WidgetTester tester,
  ) async {
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
          favoritesProvider.overrideWith(
            (ref) => Future.value(
              FavoritesResponse(
                userId: 'u1',
                lastUpdated: DateTime.now().toIso8601String(),
                favoriteRides: mockFavorites,
              ),
            ),
          ),
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
          favoritesProvider.overrideWith(
            (ref) => Future.value(
              FavoritesResponse(
                userId: 'u1',
                lastUpdated: DateTime.now().toIso8601String(),
                favoriteRides: [],
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: FavoritesPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNothing);
  });
}
