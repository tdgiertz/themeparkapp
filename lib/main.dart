import 'package:flutter/material.dart';
// Using built-in ThemeData to avoid external theme package during tests
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/core/environment_providers.dart';
import 'package:themeparkapp/core/onboarding_state.dart';
import 'package:themeparkapp/core/permissions.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/core/theme.dart';
import 'package:themeparkapp/features/dashboard/dashboard.dart';
import 'package:themeparkapp/features/favorites/favorites_page.dart';
import 'package:themeparkapp/features/onboarding/onboarding.dart';
import 'package:themeparkapp/features/park/facility_detail_page.dart';
import 'package:themeparkapp/features/parks/parks_page.dart';
import 'package:themeparkapp/features/search/search_page.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';
import 'package:themeparkapp/widgets/adaptive_image.dart';

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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const OnboardingScreen(),
      );
    }

    return MaterialApp.router(
      title: loc?.appTitle ?? 'Flutter Demo',
      routerConfig: goRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}

/// App shell that adapts its navigation UI to the available width.
///
/// Displays a `NavigationRail` for wide screens and a `NavigationBar`
/// for narrow/mobile screens while preserving the provided
/// `StatefulNavigationShell` (and thus branch state).
class ResponsiveScaffoldShell extends ConsumerStatefulWidget {
  const ResponsiveScaffoldShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ResponsiveScaffoldShell> createState() =>
      _ResponsiveScaffoldShellState();
}

class _ResponsiveScaffoldShellState
    extends ConsumerState<ResponsiveScaffoldShell> {
  bool _collapsed = false;
  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Publish current width so providers can derive device type.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ref.read(screenWidthProvider.notifier).state = width;
      }
    });

    final deviceType = width <= 600
        ? DeviceType.mobile
        : (width <= 1024 ? DeviceType.tablet : DeviceType.desktop);

    final navigationShell = widget.navigationShell;

    // Desktop: show a persistent left-hand sidebar with text labels.
    if (deviceType == DeviceType.desktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: _collapsed ? 72 : 260,
              color: Theme.of(context).drawerTheme.backgroundColor ??
                  Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          if (!_collapsed)
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.appTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          IconButton(
                            tooltip: _collapsed ? 'Expand' : 'Collapse',
                            icon: Icon(_collapsed ? Icons.chevron_right : Icons.chevron_left),
                            onPressed: () => setState(() => _collapsed = !_collapsed),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    _SidebarTile(
                      collapsed: _collapsed,
                      icon: Icons.home,
                      label: AppLocalizations.of(context)!.nav_home,
                      selected: navigationShell.currentIndex == 0,
                      onTap: () => _onTap(context, 0),
                    ),
                    _SidebarTile(
                      collapsed: _collapsed,
                      icon: Icons.assistant,
                      label: AppLocalizations.of(context)?.nav_search ?? 'AI Search',
                      selected: navigationShell.currentIndex == 1,
                      onTap: () => _onTap(context, 1),
                    ),
                    _SidebarTile(
                      collapsed: _collapsed,
                      icon: Icons.park,
                      label: 'Parks',
                      selected: navigationShell.currentIndex == 2,
                      onTap: () => _onTap(context, 2),
                    ),
                    _SidebarTile(
                      collapsed: _collapsed,
                      icon: Icons.favorite,
                      label: 'Favorites',
                      selected: navigationShell.currentIndex == 3,
                      onTap: () => _onTap(context, 3),
                    ),
                    _SidebarTile(
                      collapsed: _collapsed,
                      icon: Icons.settings,
                      label: AppLocalizations.of(context)!.nav_settings,
                      selected: navigationShell.currentIndex == 4,
                      onTap: () => _onTap(context, 4),
                    ),
                    const Spacer(),
                    // Trip Context Widget
                    if (!_collapsed) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo.shade900.withValues(alpha: 0.95),
                                Colors.blue.shade900.withValues(alpha: 0.95),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.wb_sunny, color: Colors.amberAccent, size: 24),
                                  Text(
                                    '14 Days Left',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Orlando, FL',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '84°F • Sunny',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(
                                  value: 0.75,
                                  backgroundColor: Colors.white24,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        child: Tooltip(
                          message: '14 Days until Arrival | Orlando: 84°F Sunny',
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.indigo.shade900,
                            child: const Icon(Icons.wb_sunny, color: Colors.amberAccent, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    int branchToNavIndex(int branchIndex) {
      return branchIndex;
    }

    int navToBranchIndex(int navIndex) {
      return navIndex;
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: branchToNavIndex(navigationShell.currentIndex),
        onDestinationSelected: (index) {
          final target = navToBranchIndex(index);
          navigationShell.goBranch(
            target,
            initialLocation: target == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.nav_home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assistant_outlined),
            selectedIcon: const Icon(Icons.assistant),
            label: AppLocalizations.of(context)?.nav_search ?? 'AI Search',
          ),
          const NavigationDestination(
            icon: Icon(Icons.park_outlined),
            selectedIcon: Icon(Icons.park),
            label: 'Parks',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.nav_settings,
          ),
        ],
      ),
    );
  }
}

/// Small helper tile used in the desktop sidebar to support collapsed state.
class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.collapsed,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final bool collapsed;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon),
              if (!collapsed) ...[
                const SizedBox(width: 18),
                Expanded(child: Text(label)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Details page for the selected item.
class DetailsPage extends ConsumerWidget {
  /// Creates the details page.
  const DetailsPage({super.key});

  @override
  /// Builds the details page UI, handling `AsyncValue` states.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(detailsProvider);
    final mediaQuality = ref.watch(mediaQualityProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.details_title)),
      body: Column(
        children: [
          if (mediaQuality == MediaQuality.low)
            const MaterialBanner(
              content: Text('Low network or battery — using lighter media'),
              actions: [],
            ),
          Expanded(
            child: ScreenTypeLayout.builder(
        mobile: (context) => Center(
          child: async.when(
            data: (value) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const AdaptiveNetworkImage(
                  highResUrl: 'https://example.com/high.jpg',
                  lowResUrl: 'https://example.com/low.jpg',
                  width: 300,
                  height: 180,
                  fit: BoxFit.cover,
                ),
                Text(value),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: Text(AppLocalizations.of(context)!.back),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.refresh(detailsProvider),
                  child: Text(AppLocalizations.of(context)!.reload),
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (err, st) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error: $err'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.refresh(detailsProvider),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
        tablet: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: async.when(
                  data: (value) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdaptiveNetworkImage(
                        highResUrl: 'https://example.com/high.jpg',
                        lowResUrl: 'https://example.com/low.jpg',
                        width: 640,
                        height: 320,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => context.pop(),
                            child: Text(AppLocalizations.of(context)!.back),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => ref.refresh(detailsProvider),
                            child: Text(AppLocalizations.of(context)!.reload),
                          ),
                        ],
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $err'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(detailsProvider),
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        desktop: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: async.when(
                  data: (value) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdaptiveNetworkImage(
                        highResUrl: 'https://example.com/high.jpg',
                        lowResUrl: 'https://example.com/low.jpg',
                        width: 900,
                        height: 360,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => context.pop(),
                            child: Text(AppLocalizations.of(context)!.back),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => ref.refresh(detailsProvider),
                            child: Text(AppLocalizations.of(context)!.reload),
                          ),
                        ],
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $err'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(detailsProvider),
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ],
),
);
  }
}

/// Settings page where the user selects theme and preferences.
class SettingsPage extends ConsumerWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  /// Builds the settings page UI where users can change preferences.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings_title)),
      body: ScreenTypeLayout.builder(
        mobile: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.settings_page),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('System'),
                    selected: themeMode == ThemeMode.system,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(themeModeProvider.notifier).state =
                            ThemeMode.system;
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Light'),
                    selected: themeMode == ThemeMode.light,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(themeModeProvider.notifier).state =
                            ThemeMode.light;
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Dark'),
                    selected: themeMode == ThemeMode.dark,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(themeModeProvider.notifier).state =
                            ThemeMode.dark;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(AppLocalizations.of(context)!.back),
              ),
            ],
          ),
        ),
        tablet: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.settings_page),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('System'),
                                selected: themeMode == ThemeMode.system,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.system;
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Light'),
                                selected: themeMode == ThemeMode.light,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.light;
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Dark'),
                                selected: themeMode == ThemeMode.dark,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.dark;
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.pop(),
                            child: Text(AppLocalizations.of(context)!.back),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 220,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Preview',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Builder(
                                builder: (context) {
                                  final modeName = themeMode
                                      .toString()
                                      .split('.')
                                      .last;
                                  return Text('Current theme: $modeName');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        desktop: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.settings_page,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('System'),
                                selected: themeMode == ThemeMode.system,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.system;
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Light'),
                                selected: themeMode == ThemeMode.light,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.light;
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Dark'),
                                selected: themeMode == ThemeMode.dark,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.dark;
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Builder(
                                builder: (context) {
                                  final modeName = themeMode
                                      .toString()
                                      .split('.')
                                      .last;
                                  return Text('Current theme: $modeName');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Home page widget for the application.
class MyHomePage extends ConsumerWidget {
  /// Creates the home page with the given [title].
  const MyHomePage({required this.title, super.key});

  /// Screen title shown in the app bar.
  final String title;

  /// Builds the main home page showing the counter and navigation.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.home_counter_label),
            Text('$counter', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/home/details'),
                  child: Text(AppLocalizations.of(context)!.details_button),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.go('/settings'),
                  child: Text(AppLocalizations.of(context)!.settings_button),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).state++,
        tooltip: AppLocalizations.of(context)!.increment_tooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
