import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/park_page.dart';
import 'package:themeparkapp/features/dashboard/widgets/alerts_widget.dart';
import 'package:themeparkapp/features/dashboard/widgets/context_widgets.dart';
import 'package:themeparkapp/features/dashboard/widgets/favorite_card_expanded.dart';
import 'package:themeparkapp/models/favorite.dart';
import 'package:themeparkapp/models/park.dart';
import 'package:glassmorphism/glassmorphism.dart';
// models are parsed via providers; specific model imports not required here.

Color _crowdColor(String? crowd) {
  switch (crowd?.toLowerCase()) {
    case 'low':
      return Colors.green.shade600;
    case 'moderate':
      return Colors.orange.shade600;
    case 'high':
      return Colors.red.shade600;
    default:
      return Colors.grey.shade600;
  }
}

Color _waitColor(int waitTime) {
  if (waitTime <= 30) return Colors.green.shade600;
  if (waitTime <= 60) return Colors.orange.shade600;
  return Colors.red.shade600;
}

Widget _parkCard(BuildContext context, Park p) {
  return Card(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: InkWell(
      onTap: () => Navigator.of(context).push<Widget>(
        MaterialPageRoute<Widget>(
          builder: (_) => ParkPage(parkId: p.id, parkName: p.name),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearBinding.timeOfDayGradient(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _crowdColor(p.crowdLevel),
                  child: Text(
                    p.name.isNotEmpty ? p.name[0] : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      GlassmorphicContainer(
                        width: 100,
                        height: 24,
                        borderRadius: 12,
                        blur: 10,
                        alignment: Alignment.center,
                        border: 0,
                        linearGradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.2),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              p.crowdLevel ?? 'Unknown',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class LinearBinding {
  static LinearGradient timeOfDayGradient() {
    final hour = DateTime.now().hour;
    if (hour < 6) return const LinearGradient(colors: [Colors.indigo, Colors.black]); // Night
    if (hour < 12) return const LinearGradient(colors: [Colors.orange, Colors.blue]); // Morning
    if (hour < 18) return const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]); // Day
    return const LinearGradient(colors: [Colors.deepPurple, Colors.orangeAccent]); // Evening
  }
}

/// Dashboard main screen showing parks and user favorites with enhanced layout.
class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parksAsync = ref.watch(parksProvider);
    final favsAsync = ref.watch(favoritesProvider);

    return ScreenTypeLayout.builder(
      mobile: (context) => _buildMobileLayout(favsAsync, parksAsync, context),
      tablet: (context) => _buildTabletLayout(favsAsync, parksAsync, context),
      desktop: (context) => _buildDesktopLayout(favsAsync, parksAsync, context),
    );
  }

  /// Mobile layout: vertical feed with alerts at top, context widgets, then expanded favorites
  Widget _buildMobileLayout(
    AsyncValue<FavoritesResponse> favsAsync,
    AsyncValue<ParksResponse> parksAsync,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          favsAsync.when(
            data: (favorites) {
              final alerts = generateMockAlerts(favorites.favoriteRides);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Next Best Action Alerts
                  AlertsWidget(alerts: alerts),
                  // Global Environmental Context
                  _buildContextWidgets(context, isMobile: true),
                  const SizedBox(height: 16),
                  // Expanded Favorites Matrix
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Favorites Matrix',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          avatar: const Icon(Icons.compare_arrows, size: 14),
                          label: Text(
                            '${favorites.favoriteRides.length} Cross-Park Rides',
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFavoritesList(favorites.favoriteRides),
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
    );
  }

  /// Tablet layout: multi-column side-by-side pane layout
  Widget _buildTabletLayout(
    AsyncValue<FavoritesResponse> favsAsync,
    AsyncValue<ParksResponse> parksAsync,
    BuildContext context,
  ) {
    return _buildDesktopLayout(favsAsync, parksAsync, context);
  }

  /// Desktop/Tablet layout: Multi-pane dashboard.
  /// Left column: Global Context Widgets & Action Alerts.
  /// Right column: Expanded Favorites Grid.
  Widget _buildDesktopLayout(
    AsyncValue<FavoritesResponse> favsAsync,
    AsyncValue<ParksResponse> parksAsync,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: favsAsync.when(
        data: (favorites) {
          final alerts = generateMockAlerts(favorites.favoriteRides);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Pane: Global Context Widgets & Proactive Alerts
              SizedBox(
                width: 340,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Insights',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    AlertsWidget(alerts: alerts),
                    const SizedBox(height: 16),
                    Text(
                      'Environmental Context',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const CrowdIndexGauge(busynessScore: 64),
                    const SizedBox(height: 16),
                    const WeatherWidget(
                      tempF: 82,
                      condition: 'Clear',
                      precipitationChance: 80,
                      windMph: 9,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Pane: Expanded Favorites Matrix (Cross-Park comparison & area charts)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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
                    const SizedBox(height: 20),
                    _buildFavoritesGrid(
                      context,
                      favorites.favoriteRides,
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
    );
  }

  /// Build alerts and context widgets for mobile
  Widget _buildContextWidgets(BuildContext context, {required bool isMobile}) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          CrowdIndexGauge(busynessScore: 64),
          SizedBox(height: 12),
          WeatherWidget(
            tempF: 82,
            condition: 'Clear',
            precipitationChance: 80,
            windMph: 9,
          ),
        ],
      ),
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

  /// Build favorites as a responsive grid (tablet/desktop)
  Widget _buildFavoritesGrid(BuildContext context, List<FavoriteRide> favorites, {required int crossAxisCount}) {
    if (favorites.isEmpty) {
      return const Text('No favorites added yet.');
    }
    // Compute a responsive childAspectRatio to allow slightly taller cards on wide screens
    final width = MediaQuery.of(context).size.width;
    double childAspectRatio;
    if (width > 1500) {
      childAspectRatio = 0.78; // taller cards on very wide screens
    } else if (width > 1200) {
      childAspectRatio = 0.82;
    } else if (width > 900) {
      childAspectRatio = 0.9;
    } else {
      childAspectRatio = 0.95;
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
