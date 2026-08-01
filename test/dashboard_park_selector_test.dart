import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:themeparkapp/core/models/favorite.dart';
import 'package:themeparkapp/core/permissions.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/dashboard/dashboard.dart';
import 'package:themeparkapp/features/dashboard/dashboard_geofence_provider.dart';
import 'package:themeparkapp/features/dashboard/widgets/upcoming_shows_widget.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';

class FakeLocationPermissionNotifier extends LocationPermissionNotifier {
  FakeLocationPermissionNotifier(LocationPermission permission) {
    state = permission;
  }

  @override
  Future<LocationPermission> check() async =>
      state ?? LocationPermission.whileInUse;
}

void main() {
  test('detectParkFromCoordinates identifies correct park geofence', () {
    // Magic Kingdom center: 28.4200, -81.5812
    final mkParkId = detectParkFromCoordinates(28.4200, -81.5812);
    expect(mkParkId, equals('p2'));

    // Universal Studios center: 28.4743, -81.4678
    final usParkId = detectParkFromCoordinates(28.4743, -81.4678);
    expect(usParkId, equals('p5'));

    // Outside all parks: London coordinates 51.5074, -0.1278
    final nullParkId = detectParkFromCoordinates(51.5074, -0.1278);
    expect(nullParkId, isNull);
  });

  testWidgets(
    'Dashboard sticky park selector renders choice chips and filters widgets dynamically',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const mockFavJson = '''
    {
      "userId": "user-1",
      "favoriteRides": [
        {
          "rideId": "a46",
          "name": "PeopleMover",
          "parkId": "p2",
          "parkName": "Magic Kingdom",
          "currentWait": {"status": "Open", "waitMinutes": 10, "trend": "down"}
        },
        {
          "rideId": "a88",
          "name": "Hagrid Motorbike",
          "parkId": "p5",
          "parkName": "Universal Studios",
          "currentWait": {"status": "Closed", "waitMinutes": 0, "trend": "flat"}
        }
      ]
    }
    ''';

      const mockParksJson = '''
    {
      "data": {
        "parks": [
          {"id": "p2", "type": "Park", "name": "Magic Kingdom"},
          {"id": "p5", "type": "Park", "name": "Universal Studios"}
        ]
      }
    }
    ''';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            derivedFavoritesProvider.overrideWith(
              (ref) => Future.value([
                FavoriteRide(
                  rideId: 'a46',
                  name: 'PeopleMover',
                  parkId: 'p2',
                  parkName: 'Magic Kingdom',
                  currentWait: {
                    'status': 'Open',
                    'waitMinutes': 10,
                    'trend': 'down',
                  },
                ),
                FavoriteRide(
                  rideId: 'a88',
                  name: 'Hagrid Motorbike',
                  parkId: 'p5',
                  parkName: 'Universal Studios',
                  currentWait: {
                    'status': 'Closed',
                    'waitMinutes': 0,
                    'trend': 'flat',
                  },
                ),
              ]),
            ),

            assetLoaderProvider.overrideWithValue((path) async {
              if (path.contains('favorites.json')) return mockFavJson;
              if (path.contains('parks.json')) return mockParksJson;
              return '{}';
            }),
          ],
          child: const MaterialApp(home: Scaffold(body: Dashboard())),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Sticky Park Selector ribbon choice chips exist
      expect(find.text('All Parks'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Magic Kingdom'), findsOneWidget);
      expect(
        find.widgetWithText(ChoiceChip, 'Universal Studios'),
        findsOneWidget,
      );

      // Default 'All Parks': shows both Magic Kingdom and Universal items
      expect(find.text('PeopleMover', skipOffstage: false), findsOneWidget);
      expect(
        find.text('Hagrid Motorbike', skipOffstage: false),
        findsOneWidget,
      );

      // Tap 'Magic Kingdom' chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Magic Kingdom'));
      await tester.pumpAndSettle();

      // Dynamically filtered: Magic Kingdom item shown, Universal item hidden
      expect(find.text('PeopleMover', skipOffstage: false), findsOneWidget);
      expect(find.text('Hagrid Motorbike', skipOffstage: false), findsNothing);

      // Tap 'Universal Studios' chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Universal Studios'));
      await tester.pumpAndSettle();

      // Dynamically filtered: Universal item shown, Magic Kingdom item hidden
      expect(
        find.text('Hagrid Motorbike', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('PeopleMover', skipOffstage: false), findsNothing);

      // Clean up async timers that persist past the test
      await tester.pumpWidget(Container());
      await tester.pump(const Duration(seconds: 10));
    },
  );

  testWidgets('Dashboard location-aware geofencing auto-selects detected park', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const mockFavJson = '''
    {
      "userId": "user-1",
      "favoriteRides": []
    }
    ''';

    const mockParksJson = '''
    {
      "data": {
        "parks": [
          {"id": "p2", "type": "Park", "name": "Magic Kingdom"},
          {"id": "p5", "type": "Park", "name": "Universal Studios"}
        ]
      }
    }
    ''';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          derivedFavoritesProvider.overrideWith((ref) => Future.value([])),
        upcomingShowsProvider.overrideWith((ref) => Future.value([])),
        allWaitTimesProvider.overrideWith((ref) => Future.value([])),
        allShowtimesProvider.overrideWith((ref) => Future.value([])),
          assetLoaderProvider.overrideWithValue((path) async {
            if (path.contains('favorites.json')) return mockFavJson;
            if (path.contains('parks.json')) return mockParksJson;
            return '{}';
          }),
          locationPermissionProvider.overrideWith(
            (ref) =>
                FakeLocationPermissionNotifier(LocationPermission.whileInUse),
          ),
          userLocationProvider('p2').overrideWith(
            (ref) => UserLocationNotifier(ref, 'p2')..setPosition(28.4200, -81.5812),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: Dashboard())),
      ),
    );

    await tester.pumpAndSettle();

    // Geofence should auto-detect Magic Kingdom and select its chip with nearby badge
    expect(
      find.widgetWithText(ChoiceChip, 'Magic Kingdom (Nearby)'),
      findsOneWidget,
    );
    final context = tester.element(find.byType(Dashboard));
    final container = ProviderScope.containerOf(context);
    expect(container.read(selectedDashboardParkProvider), equals('p2'));

    // Clean up async timers that persist past the test
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 10));
  });
}
