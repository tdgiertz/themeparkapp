import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/park_page.dart';
import 'package:themeparkapp/features/park/widgets/park_map.dart';
import 'package:themeparkapp/features/park/widgets/sparkline_chart.dart';
import 'package:themeparkapp/models/park.dart';
import 'package:themeparkapp/models/park_detail.dart';

/// Mapping of beautiful Unsplash hero images for each park.
const Map<String, String> parkImages = {
  'p1': 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=600&auto=format&fit=crop&q=80', // Animal Kingdom (Safari)
  'p2': 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600&auto=format&fit=crop&q=80', // Magic Kingdom (Castle)
  'p3': 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=600&auto=format&fit=crop&q=80', // Epcot (Spaceship Earth Sphere)
  'p4': 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600&auto=format&fit=crop&q=80', // Hollywood Studios (Cinema)
  'p5': 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=600&auto=format&fit=crop&q=80', // Universal Studios (Globe)
  'p6': 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&auto=format&fit=crop&q=80', // Islands of Adventure (Water)
  'p7': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&auto=format&fit=crop&q=80', // Epic Universe (Celestial)
};

/// Downsampled wait time data provider simulating TimescaleDB continuous aggregates.
final parkWaitTimeTrendProvider = Provider.family<List<int>, String>((ref, parkId) {
  final waitTimesAsync = ref.watch(waitTimesProvider(parkId));
  final waitTimes = waitTimesAsync.valueOrNull?.waitTimes ?? [];
  final openRides = waitTimes.where((w) => w.status == 'Open' && w.waitMinutes != null).toList();

  final currentAvg = openRides.isEmpty
      ? (parkId == 'p1' ? 30 : (parkId == 'p2' ? 45 : (parkId == 'p3' ? 25 : (parkId == 'p4' ? 55 : 35))))
      : (openRides.map((w) => w.waitMinutes!).reduce((a, b) => a + b) / openRides.length).round();

  // Stable deterministic trends using parkId and current average
  final list = <int>[];
  final hash = parkId.hashCode;
  for (var i = 8; i > 0; i--) {
    final offset = ((hash ^ i) % 15) - 7;
    final wait = (currentAvg + offset).clamp(5, 150);
    list.add(wait);
  }
  list.add(currentAvg);
  return list;
});

/// State provider for selected park on large screens
final selectedParkIdProvider = StateProvider<String?>((ref) => null);

/// Upgraded Parks Page supporting Master-Detail layout for desktop/tablet views.
class ParksPage extends ConsumerWidget {
  const ParksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parksAsync = ref.watch(parksProvider);
    final selectedParkId = ref.watch(selectedParkIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Parks')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: parksAsync.when(
          data: (parksResp) {
            if (parksResp.parks.isEmpty) {
              return const Center(child: Text('No parks available.'));
            }

            // Standard breakpoint at 768px width
            return LayoutBuilder(
              builder: (context, constraints) {
                final isLargeScreen = constraints.maxWidth > 768;

                if (isLargeScreen) {
                  // Master-Detail Split Pane for Tablet/Desktop
                  final activeParkId = selectedParkId ?? parksResp.parks.first.id;
                  
                  // Safe initialization of selected park
                  if (selectedParkId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(selectedParkIdProvider.notifier).state = activeParkId;
                    });
                  }

                  final selectedPark = parksResp.parks.firstWhere(
                    (p) => p.id == activeParkId,
                    orElse: () => parksResp.parks.first,
                  );

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Pane: Parks List Grid
                      SizedBox(
                        width: constraints.maxWidth * 0.42,
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            mainAxisExtent: 220,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: parksResp.parks.length,
                          itemBuilder: (context, index) {
                            final p = parksResp.parks[index];
                            final isCurrent = p.id == activeParkId;
                            return ParkHeroCard(
                              park: p,
                              isSelected: isCurrent,
                              onTap: () {
                                ref.read(selectedParkIdProvider.notifier).state = p.id;
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const VerticalDivider(width: 1),
                      const SizedBox(width: 12),
                      // Right Pane: Detail Panel
                      Expanded(
                        child: ParkDetailPane(park: selectedPark),
                      ),
                    ],
                  );
                } else {
                  // Mobile View: Single column Grid of upgraded cards
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisExtent: 200,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: parksResp.parks.length,
                    itemBuilder: (context, index) {
                      final p = parksResp.parks[index];
                      return ParkHeroCard(
                        park: p,
                        isSelected: false,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (_) => ParkPage(parkId: p.id, parkName: p.name),
                        )),
                      );
                    },
                  );
                }
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Error loading parks: $err')),
        ),
      ),
    );
  }
}

/// Upgraded Park Hero Card containing background imagery, gradient overlay,
/// glassmorphism badges, and inline sparkline.
class ParkHeroCard extends ConsumerWidget {
  const ParkHeroCard({
    required this.park,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Park park;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendData = ref.watch(parkWaitTimeTrendProvider(park.id));
    final imageUrl = parkImages[park.id] ?? 'https://images.unsplash.com/photo-1597466765990-64ad1c35dafc?w=500&q=80';

    final waitTimesAsync = ref.watch(waitTimesProvider(park.id));
    final waitTimes = waitTimesAsync.valueOrNull?.waitTimes ?? [];
    final openRides = waitTimes.where((w) => w.status == 'Open' && w.waitMinutes != null).toList();
    final currentAvg = openRides.isEmpty
        ? (park.id == 'p1' ? 30 : (park.id == 'p2' ? 45 : (park.id == 'p3' ? 25 : (park.id == 'p4' ? 55 : 35))))
        : (openRides.map((w) => w.waitMinutes!).reduce((a, b) => a + b) / openRides.length).round();

    final closeTime = park.operatingHours?['close'] ?? '8:00 PM';

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
            : BorderSide.none,
      ),
      elevation: isSelected ? 8 : 4,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Frosted Glassmorphism Badge (top-right corner)
              Positioned(
                top: 12,
                right: 12,
                child: GlassmorphicContainer(
                  width: 120,
                  height: 44,
                  borderRadius: 12,
                  blur: 10,
                  alignment: Alignment.center,
                  border: 0,
                  linearGradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avg Wait: ${currentAvg}m',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Close: $closeTime',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Content Area (bottom)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      park.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Sparkline Trend Visualization
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Wait Time Trend',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SparklineChart(
                          data: trendData,
                          lineColor: Colors.amberAccent,
                          width: 60,
                          height: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detail Panel showing the interactive map and most urgent wait times for the selected park.
class ParkDetailPane extends ConsumerWidget {
  const ParkDetailPane({required this.park, super.key});
  final Park park;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(parkDetailProvider(park.id));
    final waitsAsync = ref.watch(waitTimesProvider(park.id));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detail Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    park.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Hours: ${park.operatingHours?['open'] ?? '9 AM'} - ${park.operatingHours?['close'] ?? '9 PM'}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Map + Urgent wait times split layout
            Expanded(
              child: detailAsync.when(
                data: (detail) => waitsAsync.when(
                  data: (waits) {
                    final allFacilities = detail.children.expand((l) => l.children).toList();
                    final urgentWaits = waits.waitTimes
                        .where((w) => w.status == 'Open' && w.waitMinutes != null)
                        .toList()
                      ..sort((a, b) => (b.waitMinutes ?? 0).compareTo(a.waitMinutes ?? 0));
                    
                    final topUrgent = urgentWaits.take(5).toList();

                    return Row(
                      children: [
                        // Interactive Vector Map
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ParkMapWidget(
                              parkId: park.id,
                              facilities: allFacilities,
                              waitTimes: waits.waitTimes,
                              isMobile: false,
                              onFacilityTapped: (facility) {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(facility.name),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Type: ${facility.type}'),
                                        Text('Category: ${facility.category}'),
                                        if (facility.thrillLevel != null)
                                          Text('Thrill Level: ${facility.thrillLevel}'),
                                        if (facility.heightRequirementInches != null)
                                          Text('Height Req: ${facility.heightRequirementInches}"'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const VerticalDivider(width: 1),
                        const SizedBox(width: 16),
                        // Top Wait Times List
                        SizedBox(
                          width: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Most Urgent Wait Times',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              if (topUrgent.isEmpty)
                                const Expanded(
                                  child: Center(
                                    child: Text('No active wait times'),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: topUrgent.length,
                                    itemBuilder: (context, index) {
                                      final w = topUrgent[index];
                                      final fac = allFacilities.firstWhere(
                                        (f) => f.id == w.rideId,
                                        orElse: () => Facility(
                                          id: w.rideId,
                                          type: 'Ride',
                                          category: 'Attraction',
                                          name: 'Attraction ${w.rideId}',
                                        ),
                                      );
                                      final waitColor = w.waitMinutes != null
                                          ? (w.waitMinutes! <= 20
                                              ? Colors.green.shade600
                                              : (w.waitMinutes! <= 50
                                                  ? Colors.orange.shade600
                                                  : Colors.red.shade600))
                                          : Colors.grey.shade600;

                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          title: Text(
                                            fac.name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: waitColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${w.waitMinutes}m',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(child: Text('Error: $err')),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
