import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/dashboard/dashboard_geofence_provider.dart';
import 'package:themeparkapp/features/dashboard/widgets/alerts_widget.dart';
import 'package:themeparkapp/features/dashboard/widgets/context_widgets.dart';
import 'package:themeparkapp/features/dashboard/widgets/favorite_card_expanded.dart';
import 'package:themeparkapp/features/dashboard/widgets/upcoming_shows_widget.dart';
import 'package:themeparkapp/models/favorite.dart';
import 'package:themeparkapp/models/park.dart';

Color crowdColor(BuildContext context, String? crowd) {
  final cs = Theme.of(context).colorScheme;
  switch (crowd?.toLowerCase()) {
    case 'low':
      return cs.primaryContainer;
    case 'moderate':
      return cs.tertiaryContainer;
    case 'high':
      return cs.errorContainer;
    default:
      return cs.surfaceContainerHigh;
  }
}

class LinearBinding {
  static LinearGradient timeOfDayGradient(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hour = DateTime.now().hour;
    if (hour < 6) return LinearGradient(colors: [cs.surfaceContainerHighest, cs.surface]); // Night
    if (hour < 12) return LinearGradient(colors: [cs.primaryContainer, cs.surfaceContainerHigh]); // Morning
    if (hour < 18) return LinearGradient(colors: [cs.secondaryContainer, cs.surfaceContainerLow]); // Day
    return LinearGradient(colors: [cs.tertiaryContainer, cs.surfaceContainer]); // Evening
  }
}

/// Track whether user has manually modified the dashboard park selection
final isParkSelectionManualProvider = StateProvider<bool>((ref) => false);

/// Dashboard main screen showing parks and user favorites with enhanced layout.
class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parksAsync = ref.watch(parksProvider);
    final favsAsync = ref.watch(favoritesProvider);

    // Location-aware default: if geofenced park is detected and selection wasn't manual, auto-select it
    final detectedParkId = ref.watch(userDetectedParkIdProvider);
    final isManual = ref.watch(isParkSelectionManualProvider);
    if (!isManual && detectedParkId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(selectedDashboardParkProvider) != detectedParkId) {
          ref.read(selectedDashboardParkProvider.notifier).state = detectedParkId;
        }
      });
    }

    return ScreenTypeLayout.builder(
      mobile: (context) => _buildMobileLayout(favsAsync, parksAsync, context, ref),
      tablet: (context) => _buildTabletLayout(favsAsync, parksAsync, context, ref),
      desktop: (context) => _buildDesktopLayout(favsAsync, parksAsync, context, ref),
    );
  }

  /// Prominent Sticky Global Park Selector Chip Ribbon
  Widget _buildParkSelector(BuildContext context, WidgetRef ref, ParksResponse? parks) {
    final selectedParkId = ref.watch(selectedDashboardParkProvider);
    final detectedParkId = ref.watch(userDetectedParkIdProvider);
    final allParks = parks?.parks ?? [];

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 42,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            ChoiceChip(
              key: const ValueKey('park_selector_all'),
              label: const Text('All Parks'),
              selected: selectedParkId == 'all',
              onSelected: (val) {
                if (val) {
                  ref.read(isParkSelectionManualProvider.notifier).state = true;
                  ref.read(selectedDashboardParkProvider.notifier).state = 'all';
                }
              },
            ),
            const SizedBox(width: 8),
            ...allParks.map((p) {
              final isDetected = p.id == detectedParkId;
              final isSelected = selectedParkId == p.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: ValueKey('park_selector_${p.id}'),
                  avatar: isDetected
                      ? Icon(
                          Icons.my_location,
                          size: 16,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  label: Text(
                    isDetected ? '${p.name} (Nearby)' : p.name,
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      ref.read(isParkSelectionManualProvider.notifier).state = true;
                      ref.read(selectedDashboardParkProvider.notifier).state = p.id;
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Mobile layout: sticky park selector at top, vertical feed with compact weather banner, upcoming shows, alerts, and expanded favorites
  Widget _buildMobileLayout(
    AsyncValue<FavoritesResponse> favsAsync,
    AsyncValue<ParksResponse> parksAsync,
    BuildContext context,
    WidgetRef ref,
  ) {
    final selectedParkId = ref.watch(selectedDashboardParkProvider);

    return Column(
      children: [
        _buildParkSelector(context, ref, parksAsync.valueOrNull),
        Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Compact Weather Widget Banner at top
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: WeatherWidget(
                    tempF: 82,
                    condition: 'Clear',
                    precipitationChance: 80,
                    windMph: 9,
                  ),
                ),
                const SizedBox(height: 16),
                // Upcoming Shows & Entertainment horizontal scroll list
                const UpcomingShowsWidget(),
                favsAsync.when(
                  data: (favorites) {
                    final alerts = generateMockAlerts(favorites.favoriteRides, selectedParkId);
                    final filteredFavs = selectedParkId == 'all'
                        ? favorites.favoriteRides
                        : favorites.favoriteRides.where((f) => f.parkId == selectedParkId).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Next Best Action Alerts
                        AlertsWidget(alerts: alerts),
                        // Expanded Favorites Matrix Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Favorites Matrix',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ActionChip(
                                avatar: const Icon(Icons.compare_arrows, size: 14),
                                label: Text(
                                  '${favorites.favoriteRides.length} Cross-Park Rides',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onPressed: () {
                                  ref.read(isParkSelectionManualProvider.notifier).state = true;
                                  ref.read(selectedDashboardParkProvider.notifier).state = 'all';
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFavoritesList(filteredFavs),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Error loading dashboard favorites'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tablet layout: multi-column side-by-side pane layout
  Widget _buildTabletLayout(
    AsyncValue<FavoritesResponse> favsAsync,
    AsyncValue<ParksResponse> parksAsync,
    BuildContext context,
    WidgetRef ref,
  ) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) {
      return _buildMobileLayout(favsAsync, parksAsync, context, ref);
    }
    return _buildDesktopLayout(favsAsync, parksAsync, context, ref);
  }

  /// Desktop/Tablet layout: Multi-pane dashboard.
  /// Sticky Top Park Selector.
  /// Left column: Compact Weather Widget & Action Alerts.
  /// Right column: Upcoming Shows & Expanded Favorites Grid.
  Widget _buildDesktopLayout(
    AsyncValue<FavoritesResponse> favsAsync,
    AsyncValue<ParksResponse> parksAsync,
    BuildContext context,
    WidgetRef ref,
  ) {
    final selectedParkId = ref.watch(selectedDashboardParkProvider);

    return Column(
      children: [
        _buildParkSelector(context, ref, parksAsync.valueOrNull),
        Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                favsAsync.when(
                  data: (favorites) {
                    final alerts = generateMockAlerts(favorites.favoriteRides, selectedParkId);
                    final filteredFavs = selectedParkId == 'all'
                        ? favorites.favoriteRides
                        : favorites.favoriteRides.where((f) => f.parkId == selectedParkId).toList();

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Pane: Compact Weather Widget & Next Best Action Alerts
                        SizedBox(
                          width: 340,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hyper-Local Weather',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              const WeatherWidget(
                                tempF: 82,
                                condition: 'Clear',
                                precipitationChance: 80,
                                windMph: 9,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Live Insights',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              AlertsWidget(alerts: alerts),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Pane: Upcoming Shows & Expanded Favorites Matrix
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const UpcomingShowsWidget(),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Favorites Matrix',
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          'Compare live wait times & continuous historical averages across all resort parks side-by-side.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          ref.read(isParkSelectionManualProvider.notifier).state = true;
                                          ref.read(selectedDashboardParkProvider.notifier).state = 'all';
                                        },
                                        icon: const Icon(Icons.compare_arrows, size: 16),
                                        label: Text('${favorites.favoriteRides.length} Cross-Park Rides'),
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('Add Favorite'),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildFavoritesGrid(
                                context,
                                filteredFavs,
                                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => const Text('Error loading dashboard data'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build favorites as a vertical list (mobile)
  Widget _buildFavoritesList(List<FavoriteRide> favorites) {
    if (favorites.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No favorites added yet.'),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return SizedBox(
          height: 185,
          child: ExpandedFavoriteCard(
            favorite: favorite,
            onSwipeLeft: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening map & directions for ${favorite.name} (${favorite.parkName})'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onSwipeRight: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening menu & virtual queue for ${favorite.name}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Build favorites as a responsive grid (tablet/desktop)
  Widget _buildFavoritesGrid(BuildContext context, List<FavoriteRide> favorites, {required int crossAxisCount}) {
    if (favorites.isEmpty) {
      return const Text('No favorites added yet.');
    }
    // Compute a responsive childAspectRatio to allow proper card heights on all screen sizes
    final width = MediaQuery.of(context).size.width;
    double childAspectRatio;
    if (width > 1500) {
      childAspectRatio = 1.05;
    } else if (width > 1200) {
      childAspectRatio = 0.85;
    } else if (width > 900) {
      childAspectRatio = 0.68;
    } else {
      childAspectRatio = 0.64;
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return ExpandedFavoriteCard(
          favorite: favorite,
          onSwipeLeft: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening map & directions for ${favorite.name} (${favorite.parkName})'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onSwipeRight: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening menu & virtual queue for ${favorite.name}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }
}
