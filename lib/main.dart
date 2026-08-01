import 'package:flutter/material.dart';
// Using built-in ThemeData to avoid external theme package during tests
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:themeparkapp/core/onboarding_state.dart';
import 'package:themeparkapp/core/permissions.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/core/theme.dart';
import 'package:themeparkapp/core/widgets/responsive_scaffold_shell.dart';
import 'package:themeparkapp/features/dashboard/dashboard.dart';
import 'package:themeparkapp/features/favorites/favorites_page.dart';
import 'package:themeparkapp/features/onboarding/onboarding.dart';
import 'package:themeparkapp/features/park/facility_detail_page.dart';
import 'package:themeparkapp/features/parks/parks_page.dart';
import 'package:themeparkapp/features/search/search_page.dart';
import 'package:themeparkapp/features/settings/settings_page.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

/// Application entrypoint.
///
/// Initializes and runs the top-level `ProviderScope` and `MyApp`.
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Global navigator keys used by the app shell branches.
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _shellNavigatorSearchKey =
    GlobalKey<NavigatorState>(debugLabel: 'search');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');
final GlobalKey<NavigatorState> _shellNavigatorParksKey =
  GlobalKey<NavigatorState>(debugLabel: 'parks');
final GlobalKey<NavigatorState> _shellNavigatorFavoritesKey =
  GlobalKey<NavigatorState>(debugLabel: 'favorites');

/// Primary `GoRouter` instance for the application routes.
final GoRouter goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ResponsiveScaffoldShell(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const Dashboard(),
              routes: [
                GoRoute(
                  path: 'details',
                  builder: (context, state) {
                    final facilityId = state.queryParameters['facilityId'] ?? '';
                    final parkId = state.queryParameters['parkId'] ?? '';
                    return FacilityDetailPage(facilityId: facilityId, parkId: parkId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Search branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSearchKey,
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        // Parks branch (top-level list can be separate)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorParksKey,
          routes: [
            GoRoute(
              path: '/parks',
              builder: (context, state) => const ParksPage(),
            ),
          ],
        ),
        // Favorites branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorFavoritesKey,
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        // Settings branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Root application widget wired with Riverpod `ProviderScope`.
class MyApp extends ConsumerWidget {
  /// Creates the application instance.
  const MyApp({super.key});

  @override
  /// Builds the top-level `MaterialApp` and wires routing, theming,
  /// and localization delegates.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedColor = ref.watch(themeSeedColorProvider);
    // Trigger initial permission check on app start by reading notifier.
    ref.read(locationPermissionProvider.notifier).check();

    final loc = AppLocalizations.of(context);
    // If location permission is denied and onboarding not completed, show onboarding to request it.
    final perm = ref.watch(locationPermissionProvider);
    final onboardingDone = ref.watch(onboardingCompletedProvider);

    if ((perm == LocationPermission.denied || perm == LocationPermission.deniedForever) && !onboardingDone) {
      return MaterialApp(
        title: loc?.appTitle ?? 'Flutter Demo',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme(selectedColor),
        darkTheme: AppTheme.darkTheme(selectedColor),
        themeMode: themeMode,
        home: const OnboardingScreen(),
      );
    }

    return MaterialApp.router(
      title: loc?.appTitle ?? 'Flutter Demo',
      routerConfig: goRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme(selectedColor),
      darkTheme: AppTheme.darkTheme(selectedColor),
      themeMode: themeMode,
    );
  }
}

/// App shell that adapts its navigation UI to the available width.
///
/// Displays a `NavigationRail` for wide screens and a `NavigationBar`
/// for narrow/mobile screens while preserving the provided
/// `StatefulNavigationShell` (and thus branch state).
