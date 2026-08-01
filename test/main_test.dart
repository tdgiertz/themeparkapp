import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:themeparkapp/core/onboarding_state.dart';
import 'package:themeparkapp/core/permissions.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/core/widgets/responsive_scaffold_shell.dart';
import 'package:themeparkapp/features/onboarding/onboarding.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';
import 'package:themeparkapp/main.dart' as app;

class FakeLocationPermissionNotifier extends LocationPermissionNotifier {
  FakeLocationPermissionNotifier(LocationPermission? initial) {
    state = initial;
  }

  @override
  Future<LocationPermission> check() async {
    return state ?? LocationPermission.always;
  }
}

class FakeOnboardingNotifier extends OnboardingNotifier {
  FakeOnboardingNotifier({required bool initial}) {
    state = initial;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  const mockWaitTimesJson = '''
  {
    "meta": {"timestamp": "2026-07-28T14:30:00Z"},
    "waitTimes": []
  }
  ''';

  final commonOverrides = [
    derivedFavoritesProvider.overrideWith((ref) => Future.value([])),
    upcomingShowsProvider.overrideWith((ref) => Future.value([])),
    allWaitTimesProvider.overrideWith((ref) => Future.value([])),
    allShowtimesProvider.overrideWith((ref) => Future.value([])),
    assetLoaderProvider.overrideWithValue((path) async {
      if (path.contains('favorites')) return mockFavJson;
      if (path.contains('parks')) return mockParksJson;
      if (path.contains('wait_times')) return mockWaitTimesJson;
      return '{}';
    }),
  ];

  group('Main App Entrypoint & Routing Tests', () {
    testWidgets(
      'MyApp shows OnboardingScreen when location permission denied and onboarding not done',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ...commonOverrides,
              locationPermissionProvider.overrideWith(
                (ref) =>
                    FakeLocationPermissionNotifier(LocationPermission.denied),
              ),
              onboardingCompletedProvider.overrideWith(
                (ref) => FakeOnboardingNotifier(initial: false),
              ),
            ],
            child: const app.MyApp(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(OnboardingScreen), findsOneWidget);
      },
    );

    testWidgets(
      'MyApp initializes MaterialApp.router and renders Dashboard by default when onboarding completed',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ...commonOverrides,
              locationPermissionProvider.overrideWith(
                (ref) =>
                    FakeLocationPermissionNotifier(LocationPermission.always),
              ),
              onboardingCompletedProvider.overrideWith(
                (ref) => FakeOnboardingNotifier(initial: true),
              ),
            ],
            child: const app.MyApp(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(ResponsiveScaffoldShell), findsOneWidget);
        expect(find.byKey(const ValueKey('nav_home')), findsOneWidget);
      },
    );

    testWidgets('goRouter navigates between shell branches', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...commonOverrides,
            locationPermissionProvider.overrideWith(
              (ref) =>
                  FakeLocationPermissionNotifier(LocationPermission.always),
            ),
            onboardingCompletedProvider.overrideWith(
              (ref) => FakeOnboardingNotifier(initial: true),
            ),
          ],
          child: const app.MyApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Navigate to Search
      app.goRouter.go('/search');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Navigate to Favorites
      app.goRouter.go('/favorites');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Navigate to Settings
      app.goRouter.go('/settings');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Navigate to Details sub-route under home
      app.goRouter.go('/home/details?facilityId=f1&parkId=p1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Navigate back to Home
      app.goRouter.go('/home');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('MyApp respects custom theme mode and seed color overrides', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...commonOverrides,
            themeModeProvider.overrideWith(() => ThemeModeNotifier()..setThemeMode(ThemeMode.dark)),
            themeSeedColorProvider.overrideWith(
              (ref) => ThemeSeedColor()..setColor(Colors.purple),
            ),
            locationPermissionProvider.overrideWith(
              (ref) =>
                  FakeLocationPermissionNotifier(LocationPermission.always),
            ),
            onboardingCompletedProvider.overrideWith(
              (ref) => FakeOnboardingNotifier(initial: true),
            ),
          ],
          child: const app.MyApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });

    testWidgets('ProviderScope and MyApp boot correctly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(overrides: commonOverrides, child: const app.MyApp()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(app.MyApp), findsOneWidget);
    });
  });
}
