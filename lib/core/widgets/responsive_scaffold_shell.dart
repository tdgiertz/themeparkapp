import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:themeparkapp/core/environment_providers.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

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
        ref.read(screenWidthProvider.notifier).setWidth(width);
      }
    });

    final deviceType = width <= 600
        ? DeviceType.mobile
        : (width <= 1024 ? DeviceType.tablet : DeviceType.desktop);

    final navigationShell = widget.navigationShell;
    final loc = AppLocalizations.of(context)!;

    // Desktop: show a persistent left-hand sidebar with text labels.
    if (deviceType == DeviceType.desktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: _collapsed ? 72 : 260,
              color:
                  Theme.of(context).drawerTheme.backgroundColor ??
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
                                loc.appTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          IconButton(
                            tooltip: _collapsed ? loc.nav_home : loc.nav_home,
                            icon: Icon(
                              _collapsed
                                  ? Icons.chevron_right
                                  : Icons.chevron_left,
                            ),
                            onPressed: () =>
                                setState(() => _collapsed = !_collapsed),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    _SidebarTile(
                      collapsed: _collapsed,
                      icon: Icons.home,
                      label: loc.nav_home,
                      selected: navigationShell.currentIndex == 0,
                      onTap: () => _onTap(context, 0),
                    ),
                    _SidebarTile(
                      collapsed: _collapsed,
                      icon: Icons.assistant,
                      label: loc.nav_search,
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
                      label: loc.nav_settings,
                      selected: navigationShell.currentIndex == 4,
                      onTap: () => _onTap(context, 4),
                    ),
                    const Spacer(),
                    // Trip Context Widget
                    if (!_collapsed) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primaryContainer,
                                Theme.of(context).colorScheme.tertiaryContainer,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.wb_sunny,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    size: 24,
                                  ),
                                  Text(
                                    '14 Days Left',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Orlando, FL',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '84°F • Sunny',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.75,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        child: Tooltip(
                          message:
                              '14 Days until Arrival | Orlando: 84°F Sunny',
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.wb_sunny,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
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
            key: const ValueKey('nav_home'),
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: loc.nav_home,
          ),
          NavigationDestination(
            key: const ValueKey('nav_search'),
            icon: const Icon(Icons.assistant_outlined),
            selectedIcon: const Icon(Icons.assistant),
            label: loc.nav_search,
          ),
          const NavigationDestination(
            key: ValueKey('nav_parks'),
            icon: Icon(Icons.park_outlined),
            selectedIcon: Icon(Icons.park),
            label: 'Parks',
          ),
          const NavigationDestination(
            key: ValueKey('nav_favorites'),
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            key: const ValueKey('nav_settings'),
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: loc.nav_settings,
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
      color: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
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
