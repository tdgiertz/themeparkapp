import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/models/favorite.dart';
import 'package:themeparkapp/core/models/park.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/core/repositories/repositories.dart';
import 'package:themeparkapp/core/theme.dart';
import 'package:themeparkapp/features/dashboard/widgets/favorite_card_expanded.dart';
import 'package:themeparkapp/features/dashboard/widgets/upcoming_shows_widget.dart';
import 'package:themeparkapp/features/park/widgets/sparkline_chart.dart';
import 'package:themeparkapp/features/parks/models/extra_models.dart';
import 'package:themeparkapp/features/parks/models/park_models.dart' as pk;
import 'package:themeparkapp/features/parks/parks_page.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';
import 'package:themeparkapp/features/settings/widgets/theme_color_settings_tile.dart';

class MockParkRepository implements ParkRepository {
  @override
  Future<List<pk.Park>> fetchParks() async => [];
}

class MockShowtimesRepository implements ShowtimesRepository {
  @override
  Future<List<ShowSchedule>> fetchShowtimes() async => [];
}

class MockSelectedDashboardPark extends SelectedDashboardPark {
  @override
  String build() => 'all';
}

void main() {
  group('Phase 3 Golden Tests', () {
    // We can define a helper to build widgets inside a proper Material App and ProviderScope
    Widget buildTestWidget(
      Widget child, {
      ThemeData? theme,
      List<dynamic> overrides = const [],
    }) {
      return ProviderScope(
        overrides: [
          assetLoaderProvider.overrideWithValue(
            (_) async => '{"waitTimes": []}',
          ),
          ...overrides.cast(),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.lightTheme(),
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: child)),
        ),
      );
    }

    testWidgets('1. SparklineChart with 5 data points', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SparklineChart(
            data: [10, 25, 15, 30, 20],
            width: 200,
            height: 100,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(SparklineChart),
        matchesGoldenFile('goldens/sparkline_chart.png'),
      );
    });

    testWidgets(
      '2. ExpandedFavoriteCard — open state with up trend indicator',
      (tester) async {
        final mockOpenFavorite = FavoriteRide(
          rideId: 'r1',
          name: 'Space Mountain',
          parkId: 'p2',
          parkName: 'Magic Kingdom',
          currentWait: {'waitMinutes': 45, 'status': 'Open', 'trend': 'up'},
        );

        // Wrap in a sized box to mimic typical constraints
        await tester.pumpWidget(
          buildTestWidget(
            SizedBox(
              width: 350,
              height: 180,
              child: ExpandedFavoriteCard(favorite: mockOpenFavorite),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await expectLater(
          find.byType(ExpandedFavoriteCard),
          matchesGoldenFile('goldens/expanded_favorite_card_open.png'),
        );
      },
    );

    testWidgets(
      '3. ExpandedFavoriteCard — OFFLINE/closed state with diagonal stripes',
      (tester) async {
        final mockClosedFavorite = FavoriteRide(
          rideId: 'r2',
          name: 'Splash Mountain',
          parkId: 'p2',
          parkName: 'Magic Kingdom',
          currentWait: {
            'waitMinutes': 0,
            'status': 'Closed',
            'trend': 'steady',
          },
        );

        await tester.pumpWidget(
          buildTestWidget(
            SizedBox(
              width: 350,
              height: 180,
              child: ExpandedFavoriteCard(favorite: mockClosedFavorite),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await expectLater(
          find.byType(ExpandedFavoriteCard),
          matchesGoldenFile('goldens/expanded_favorite_card_closed.png'),
        );
      },
    );

    testWidgets(
      '4. ParkNavigationRibbon — first park selected vs. second park selected',
      (tester) async {
        final mockParks = [
          Park(
            id: 'p1',
            name: 'Animal Kingdom',
            type: 'park',
            operatingHours: {},
          ),
          Park(
            id: 'p2',
            name: 'Magic Kingdom',
            type: 'park',
            operatingHours: {},
          ),
        ];

        await tester.pumpWidget(
          buildTestWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ParkNavigationRibbon(
                  parks: mockParks,
                  selectedParkId: 'p1',
                  onParkSelected: (id) {},
                ),
                const SizedBox(height: 16),
                ParkNavigationRibbon(
                  parks: mockParks,
                  selectedParkId: 'p2',
                  onParkSelected: (id) {},
                ),
              ],
            ),
          ),
        );

        // Network images for park cards might fail in tests, so we need to mock HttpOverrides or allow network.
        // Since it uses Image.network without a proper mock, it might show the errorBuilder.
        // Wait, in `ParkNavigationRibbon`, there is an errorBuilder. So it will just render the fallback icon. That is fine for a golden test.
        // Just pumpAndSettle with a timeout if it fails.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(Column).first,
          matchesGoldenFile('goldens/park_navigation_ribbon.png'),
        );
      },
    );

    testWidgets('5. UpcomingShowsWidget — static hardcoded show data', (
      tester,
    ) async {
      final sampleShows = [
        const ShowEvent(
          id: 'show_1',
          parkId: 'p2',
          parkName: 'Magic Kingdom',
          title: 'Festival of Fantasy Parade',
          startTime: '3:00 PM',
          venue: 'Main Street, U.S.A.',
          category: 'Parade',
          durationMinutes: 20,
          isOnlyPerformanceToday: true,
          scarcityTag: 'Only Performance Today',
        ),
        const ShowEvent(
          id: 'a100',
          parkId: 'p1',
          parkName: 'Animal Kingdom',
          title: 'Festival of the Lion King',
          startTime: '3:30 PM',
          venue: 'Harambe Theater',
          category: 'Stage Show',
          durationMinutes: 30,
          scarcityTag: 'Requires Virtual Queue',
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
          isOnlyPerformanceToday: true,
          scarcityTag: 'Final Show',
        ),
        const ShowEvent(
          id: 'show_4',
          parkId: 'p4',
          parkName: 'Hollywood Studios',
          title: 'Fantasmic!',
          startTime: '8:30 PM',
          venue: 'Hollywood Hills Amphitheater',
          category: 'Nighttime Spectacular',
          durationMinutes: 29,
        ),
        const ShowEvent(
          id: 'show_5',
          parkId: 'p2',
          parkName: 'Magic Kingdom',
          title: 'Happily Ever After',
          startTime: '9:20 PM',
          venue: 'Cinderella Castle',
          category: 'Nighttime Spectacular',
          durationMinutes: 18,
        ),
        const ShowEvent(
          id: 'show_6',
          parkId: 'p1',
          parkName: 'Animal Kingdom',
          title: 'Finding Nemo: The Big Blue... and Beyond!',
          startTime: '4:15 PM',
          venue: 'Theater in the Wild',
          category: 'Stage Show',
          durationMinutes: 25,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(width: 400, height: 200, child: UpcomingShowsWidget()),
          overrides: [
            selectedDashboardParkProvider.overrideWith(
              () => MockSelectedDashboardPark(),
            ),
            upcomingShowsProvider.overrideWith((ref) async => sampleShows),
          ],
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(UpcomingShowsWidget),
        matchesGoldenFile('goldens/upcoming_shows_widget.png'),
      );
    });

    testWidgets(
      '6. ThemeColorSettingsTile — light theme and dark theme variants',
      (tester) async {
        // Need two side-by-side or stacked tiles with different themes.
        // Since Theme is inherited, we can wrap each tile in its own Theme widget.
        await tester.pumpWidget(
          buildTestWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Theme(
                  data: AppTheme.lightTheme(),
                  child: Material(
                    color: AppTheme.lightTheme().scaffoldBackgroundColor,
                    child: const ThemeColorSettingsTile(),
                  ),
                ),
                const SizedBox(height: 16),
                Theme(
                  data: AppTheme.darkTheme(),
                  child: Material(
                    color: AppTheme.darkTheme().scaffoldBackgroundColor,
                    child: const ThemeColorSettingsTile(),
                  ),
                ),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle();
        await expectLater(
          find.byType(Column).first,
          matchesGoldenFile('goldens/theme_color_settings_tile.png'),
        );
      },
    );
  });
}
