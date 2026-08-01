import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/models/favorite.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/dashboard/dashboard.dart';
import 'package:themeparkapp/features/dashboard/widgets/favorite_card_expanded.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';

void main() {
  testWidgets('ExpandedFavoriteCard renders trend indicator beside wait time', (WidgetTester tester) async {
    final ride = FavoriteRide(
      rideId: '1',
      name: 'Space Mountain',
      parkId: '1',
      parkName: 'Magic Kingdom',
      currentWait: {
        'status': 'Open',
        'waitMinutes': 45,
        'trend': 'up',
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandedFavoriteCard(
            favorite: ride,
          ),
        ),
      ),
    );

    expect(find.text('45'), findsOneWidget);
    expect(find.text('min wait'), findsOneWidget);
    expect(find.text('📈'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
  });

  testWidgets('Dashboard filters favorites contextually and cross-park shortcut resets filter', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const mockFavJson = '''
    {
      "userId": "user-9876",
      "lastUpdated": "2026-07-28T14:30:00Z",
      "favoriteRides": [
        {
          "rideId": "1",
          "name": "Pirates of the Caribbean",
          "parkId": "1",
          "parkName": "Magic Kingdom",
          "currentWait": {
            "status": "Open",
            "waitMinutes": 45,
            "trend": "down",
            "updatedAt": "2026-07-28T14:25:00Z"
          }
        },
        {
          "rideId": "88",
          "name": "Hagrid Motorbike",
          "parkId": "3",
          "parkName": "Universal Studios",
          "currentWait": {
            "status": "Open",
            "waitMinutes": 60,
            "trend": "up",
            "updatedAt": "2026-07-28T14:28:00Z"
          }
        }
      ]
    }
    ''';

    const mockParksJson = '''
    {
      "data": {
        "parks": [
          {"id": "1", "type": "theme-park", "name": "Magic Kingdom"},
          {"id": "3", "type": "theme-park", "name": "Universal Studios"}
        ]
      }
    }
    ''';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          derivedFavoritesProvider.overrideWith((ref) => Future.value([
            FavoriteRide(rideId: '1', name: 'Pirates of the Caribbean', parkId: '1', parkName: 'Magic Kingdom', currentWait: {'status': 'Open', 'waitMinutes': 45}), 
            FavoriteRide(rideId: '88', name: 'Hagrid Motorbike', parkId: '3', parkName: 'Universal Studios', currentWait: {'status': 'Open', 'waitMinutes': 60})
          ])), 
          assetLoaderProvider.overrideWithValue((path) async {
            if (path.contains('favorites.json')) return mockFavJson;
            if (path.contains('parks.json')) return mockParksJson;
            return '{}';
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Dashboard(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Favorites Matrix'), findsOneWidget);
    expect(find.text('Pirates of the Caribbean', skipOffstage: false), findsOneWidget);
    expect(find.text('Hagrid Motorbike', skipOffstage: false), findsOneWidget);

    // Tap ChoiceChip for Magic Kingdom ('1')
    final parkChip = find.widgetWithText(ChoiceChip, 'Magic Kingdom');
    expect(parkChip, findsOneWidget);
    await tester.tap(parkChip);
    await tester.pumpAndSettle();

    // Contextual matrix should only show Magic Kingdom favorites
    expect(find.text('Pirates of the Caribbean', skipOffstage: false), findsOneWidget);
    expect(find.text('Hagrid Motorbike', skipOffstage: false), findsNothing);

    // Tap shortcut button to bypass global filter
    final shortcutFinder = find.text('2 Cross-Park Rides');
    expect(shortcutFinder, findsOneWidget);
    await tester.tap(shortcutFinder);
    await tester.pumpAndSettle();

    // Verify filter is reset and both favorites are shown again
    expect(find.text('Pirates of the Caribbean', skipOffstage: false), findsOneWidget);
    expect(find.text('Hagrid Motorbike', skipOffstage: false), findsOneWidget);
  });
}
