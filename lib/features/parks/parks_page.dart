import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:themeparkapp/core/models/park.dart';
import 'package:themeparkapp/core/models/park_detail.dart';
import 'package:themeparkapp/core/models/wait_time.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/facility_detail_page.dart';
import 'package:themeparkapp/features/park/park_page.dart';
import 'package:themeparkapp/features/park/widgets/park_map.dart';
import 'package:themeparkapp/features/park/widgets/sparkline_chart.dart';

part 'parks_page.g.dart';

/// Mapping of beautiful Unsplash hero images for each park.
const Map<String, String> parkImages = {
  'p1':
      'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=600&auto=format&fit=crop&q=80', // Animal Kingdom (Safari)
  'p2':
      'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600&auto=format&fit=crop&q=80', // Magic Kingdom (Castle)
  'p3':
      'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=600&auto=format&fit=crop&q=80', // Epcot (Spaceship Earth Sphere)
  'p4':
      'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=600&auto=format&fit=crop&q=80', // Hollywood Studios (Cinema)
  'p5':
      'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=600&auto=format&fit=crop&q=80', // Universal Studios (Globe)
  'p6':
      'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=600&auto=format&fit=crop&q=80', // Islands of Adventure (Water)
  'p7':
      'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&auto=format&fit=crop&q=80', // Epic Universe (Celestial)
};

/// Downsampled wait time data provider simulating TimescaleDB continuous aggregates.
final parkWaitTimeTrendProvider = Provider.family<List<int>, String>((
  ref,
  parkId,
) {
  final waitTimesAsync = ref.watch(waitTimesProvider(parkId));
  final waitTimes = waitTimesAsync.value?.waitTimes ?? [];
  final openRides = waitTimes
      .where((w) => w.status == 'Open' && w.waitMinutes != null)
      .toList();

  final currentAvg = openRides.isEmpty
      ? (parkId == 'p1'
            ? 30
            : (parkId == 'p2'
                  ? 45
                  : (parkId == 'p3' ? 25 : (parkId == 'p4' ? 55 : 35))))
      : (openRides.map((w) => w.waitMinutes!).reduce((a, b) => a + b) /
                openRides.length)
            .round();

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

@riverpod
class SelectedParkId extends _$SelectedParkId {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties
  void updateSelectedParkId(String? value) => state = value;
}

/// Represents global filter selections for the park page.
class ParkFilters {
  ParkFilters({
    this.ageGroups = const {},
    this.types = const {},
    this.statuses = const {},
  });

  final Set<String> ageGroups;
  final Set<String> types;
  final Set<String> statuses;

  int get activeCount => ageGroups.length + types.length + statuses.length;
}

@riverpod
class GlobalParkFilter extends _$GlobalParkFilter {
  @override
  ParkFilters build() => ParkFilters();

  // ignore: use_setters_to_change_properties
  void updateFilter(ParkFilters value) => state = value;
}

@riverpod
class ParkWaitTimeSort extends _$ParkWaitTimeSort {
  @override
  String build() => 'Name (A-Z)';

  // ignore: use_setters_to_change_properties
  void updateSort(String value) => state = value;
}

@riverpod
class ParkFilterDrawerOpen extends _$ParkFilterDrawerOpen {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  // ignore: use_setters_to_change_properties
  void updateOpen({required bool open}) => state = open;
}

// Upgraded Parks Page supporting Master-Detail layout for desktop/tablet views.
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
                  // Tablet/Desktop Layout: Top horizontal tab ribbon + 2/3 Map & 1/3 Wait Times split
                  final activeParkId =
                      selectedParkId ?? parksResp.parks.first.id;

                  // Safe initialization of selected park
                  if (selectedParkId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(selectedParkIdProvider.notifier).updateSelectedParkId(
                            activeParkId,
                          );
                    });
                  }

                  final selectedPark = parksResp.parks.firstWhere(
                    (p) => p.id == activeParkId,
                    orElse: () => parksResp.parks.first,
                  );

                  return Column(
                    children: [
                      // Top horizontal ribbon tab bar for park selection
                      ParkNavigationRibbon(
                        parks: parksResp.parks,
                        selectedParkId: activeParkId,
                        onParkSelected: (id) {
                          ref.read(selectedParkIdProvider.notifier).updateSelectedParkId(id);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Main Content Area: Left 2/3 Map, Right 1/3 Urgent Wait Times
                      Expanded(child: DesktopParkDashboard(park: selectedPark)),
                    ],
                  );
                } else {
                  // Mobile View: Single column List of upgraded cards with dynamic quick context expansion
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: parksResp.parks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = parksResp.parks[index];
                      return ParkHeroCard(
                        park: p,
                        isSelected: false,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ParkPage(parkId: p.id, parkName: p.name),
                          ),
                        ),
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

/// Slim horizontal tab ribbon across the top of desktop/tablet views for park selection.
class ParkNavigationRibbon extends ConsumerWidget {
  const ParkNavigationRibbon({
    required this.parks,
    required this.selectedParkId,
    required this.onParkSelected,
    super.key,
  });

  final List<Park> parks;
  final String selectedParkId;
  final ValueChanged<String> onParkSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: parks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final park = parks[index];
                final isSelected = park.id == selectedParkId;
                final imageUrl =
                    parkImages[park.id] ??
                    'https://images.unsplash.com/photo-1597466765990-64ad1c35dafc?w=500&q=80';

                final trendData = ref.watch(parkWaitTimeTrendProvider(park.id));
                final currentAvg = trendData.isNotEmpty ? trendData.last : 30;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onParkSelected(park.id),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHigh.withValues(
                                alpha: 0.6,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 32,
                                    height: 32,
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.park,
                                      size: 18,
                                      color: isSelected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                park.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outline,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Avg ${currentAvg}m',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? colorScheme.onPrimaryContainer
                                                .withValues(alpha: 0.85)
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          const VerticalDivider(width: 1, indent: 4, endIndent: 4),
          const SizedBox(width: 12),
          _buildFilterButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(globalParkFilterProvider);
    final isActive = filters.activeCount > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref
                  .read(parkFilterDrawerOpenProvider.notifier)
                  .toggle();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: isActive
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isActive)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${filters.activeCount}',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Upgraded Park Hero Card supporting hybrid interaction model:
/// - Tap Park Image, Title, or Right Chevron -> Deep Dive Navigation (Park Explorer).
/// - Tap Downward Chevron or Card Body -> Inline Quick Context Accordion Expansion.
class ParkHeroCard extends ConsumerStatefulWidget {
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
  ConsumerState<ParkHeroCard> createState() => _ParkHeroCardState();
}

class _ParkHeroCardState extends ConsumerState<ParkHeroCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final park = widget.park;
    final trendData = ref.watch(parkWaitTimeTrendProvider(park.id));
    final imageUrl =
        parkImages[park.id] ??
        'https://images.unsplash.com/photo-1597466765990-64ad1c35dafc?w=500&q=80';

    final waitTimesAsync = ref.watch(waitTimesProvider(park.id));
    final waitTimes = waitTimesAsync.value?.waitTimes ?? [];
    final openRides = waitTimes
        .where((w) => w.status == 'Open' && w.waitMinutes != null)
        .toList();
    final currentAvg = openRides.isEmpty
        ? (park.id == 'p1'
              ? 30
              : (park.id == 'p2'
                    ? 45
                    : (park.id == 'p3' ? 25 : (park.id == 'p4' ? 55 : 35))))
        : (openRides.map((w) => w.waitMinutes!).reduce((a, b) => a + b) /
                  openRides.length)
              .round();

    final openTime = park.operatingHours?['open'] ?? '08:00';
    final closeTime = park.operatingHours?['close'] ?? '20:00';
    final hoursDisplay = '$openTime - $closeTime';

    final colorScheme = Theme.of(context).colorScheme;

    // Top 3 urgent wait times for Quick Context
    final sortedRides = List<WaitTime>.from(openRides)
      ..sort((a, b) => (b.waitMinutes ?? 0).compareTo(a.waitMinutes ?? 0));
    final topRides = sortedRides.take(3).toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: widget.isSelected
            ? BorderSide(color: colorScheme.primary, width: 2.5)
            : BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
      ),
      elevation: widget.isSelected ? 4 : 1,
      color: colorScheme.surfaceContainerLow,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Tapping card background toggles Quick Context expansion
            InkWell(
              key: ValueKey('park_card_inkwell_${park.id}'),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upper Section: Left Image, Right compact column
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Park Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 84,
                                  height: 84,
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.park,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Park Title Row with Up/Down Accordion Chevron
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      park.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Up/Down Chevron Indicator for Accordion Expansion
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: colorScheme.primary,
                                    size: 26,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Avg Wait: ${currentAvg}m',
                                      style: TextStyle(
                                        color: colorScheme.onPrimaryContainer,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: colorScheme.outlineVariant
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          hoursDisplay,
                                          style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bottom Section: 100% width Sparkline chart
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SparklineChart(
                        data: trendData,
                        lineColor: colorScheme.primary,
                        width: double.infinity,
                        height: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Inline Quick Context Accordion Body
            if (_isExpanded) ...[
              const Divider(height: 1, indent: 12, endIndent: 12),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Quick Context (TimescaleDB Aggregate)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Live TimescaleDB',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (topRides.isNotEmpty) ...[
                      Text(
                        'Top Wait Times:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: topRides.map<Widget>((w) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Ride ${w.rideId}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (w.waitMinutes ?? 0) > 45
                                        ? colorScheme.errorContainer
                                        : colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${w.waitMinutes}m',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: (w.waitMinutes ?? 0) > 45
                                          ? colorScheme.onErrorContainer
                                          : colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: ValueKey('park_card_explorer_btn_${park.id}'),
                        onPressed: widget.onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: const Text(
                          'Open Full Park Explorer & Map',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

bool _matchesGlobalFilter(Facility f, WaitTime? w, ParkFilters filters) {
  if (filters.activeCount == 0) return true;

  var matchesAge = true;
  if (filters.ageGroups.isNotEmpty) {
    matchesAge = false;
    final isThrill = f.thrillLevel == 'High' || f.thrillLevel == 'Moderate';
    final isLowThrill =
        f.thrillLevel == 'Low' || (f.heightRequirementInches ?? 0) == 0;

    if (filters.ageGroups.contains('All Ages') && isLowThrill) {
      matchesAge = true;
    }
    if (filters.ageGroups.contains('Preschool') && f.thrillLevel == 'Low') {
      matchesAge = true;
    }
    if (filters.ageGroups.contains('Kids') &&
        (f.thrillLevel == 'Low' || f.thrillLevel == 'Moderate')) {
      matchesAge = true;
    }
    if (filters.ageGroups.contains('Tweens') && isThrill) matchesAge = true;
    if (filters.ageGroups.contains('Teens') && isThrill) matchesAge = true;
    if (filters.ageGroups.contains('Adults') && isThrill) matchesAge = true;
  }

  var matchesType = true;
  if (filters.types.isNotEmpty) {
    matchesType = false;
    if (filters.types.contains('Rides') && f.type == 'Ride') matchesType = true;
    if (filters.types.contains('Shows') &&
        (f.type == 'Show' || f.category == 'Entertainment')) {
      matchesType = true;
    }
    if (filters.types.contains('Dining / Restaurants') &&
        (f.type == 'Restaurant' ||
            f.category == 'Dining' ||
            f.name.toLowerCase().contains('cafe'))) {
      matchesType = true;
    }
    if (filters.types.contains('Character Experiences') &&
        (f.type == 'Character' || f.name.toLowerCase().contains('meet'))) {
      matchesType = true;
    }
    if (filters.types.contains('Walkthroughs / Play Areas') &&
        (f.type == 'PlayArea' || f.name.toLowerCase().contains('play'))) {
      matchesType = true;
    }
  }

  var matchesStatus = true;
  if (filters.statuses.isNotEmpty) {
    matchesStatus = false;
    final stat =
        w?.status ?? 'Closed'; // default to Closed if no wait time object
    if (filters.statuses.contains('Operating') && stat == 'Open') {
      matchesStatus = true;
    }
    if (filters.statuses.contains('Temporarily Closed / Down') &&
        stat == 'Closed') {
      matchesStatus = true;
    }
    if (filters.statuses.contains('Under Refurbishment') &&
        stat == 'Refurbishment') {
      matchesStatus = true;
    }
  }

  return matchesAge && matchesType && matchesStatus;
}

/// Desktop/Tablet Dashboard Pane allocating left 2/3 for interactive vector map (100% height)
/// and right 1/3 for continuous aggregate downsampled wait times list.
class DesktopParkDashboard extends ConsumerWidget {
  const DesktopParkDashboard({required this.park, super.key});
  final Park park;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(parkDetailProvider(park.id));
    final waitsAsync = ref.watch(waitTimesProvider(park.id));
    final filters = ref.watch(globalParkFilterProvider);
    final isDrawerOpen = ref.watch(parkFilterDrawerOpenProvider);
    final sortOrder = ref.watch(parkWaitTimeSortProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left 2/3: The Map Component (Primary Focus - 100% vertical space below tabs)
        Expanded(
          flex: 2,
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            elevation: 2,
            child: Stack(
              children: [
                detailAsync.when(
                  data: (detail) => waitsAsync.when(
                    data: (waits) {
                      final allFacilities = detail.children
                          .expand((l) => l.children)
                          .toList();
                      final filteredFacilities = allFacilities.where((f) {
                        final w = waits.waitTimes
                            .where((wt) => wt.rideId == f.id)
                            .firstOrNull;
                        return _matchesGlobalFilter(f, w, filters);
                      }).toList();

                      return ParkMapWidget(
                        parkId: park.id,
                        facilities: filteredFacilities,
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
                                    Text(
                                      'Thrill Level: ${facility.thrillLevel}',
                                    ),
                                  if (facility.heightRequirementInches != null)
                                    Text(
                                      'Height Req: ${facility.heightRequirementInches}"',
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => FacilityDetailPage(
                                          facilityId: facility.id,
                                          parkId: park.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View Details'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, st) =>
                        Center(child: Text('Error loading wait times: $err')),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) =>
                      Center(child: Text('Error loading park details: $err')),
                ),
                // Overlay header banner on top left of map
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          park.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Hours: ${park.operatingHours?['open'] ?? '9 AM'} - ${park.operatingHours?['close'] ?? '9 PM'}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Right 1/3: Wait Times Component (Secondary Focus)
        Expanded(
          child: Stack(
            children: [
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Wait Times',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: sortOrder,
                              focusColor: Colors.transparent,
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  ref
                                      .read(
                                        parkWaitTimeSortProvider.notifier,
                                      )
                                      .updateSort(newValue);
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 'Name (A-Z)',
                                  child: Text('Sort: A-Z'),
                                ),
                                DropdownMenuItem(
                                  value: 'Name (Z-A)',
                                  child: Text('Sort: Z-A'),
                                ),
                                DropdownMenuItem(
                                  value: 'Wait Time (High to Low)',
                                  child: Text('Sort: Wait (High)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Wait Time (Low to High)',
                                  child: Text('Sort: Wait (Low)'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Continuous Aggregates Downsampled Dataset Subtitle/Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'TimescaleDB Aggregate',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Downsampled live data',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      // Urgent Wait Times List
                      Expanded(
                        child: detailAsync.when(
                          data: (detail) => waitsAsync.when(
                            data: (waits) {
                              final allFacilities = detail.children
                                  .expand((l) => l.children)
                                  .toList();

                              // First filter based on global filters
                              final displayItems =
                                  allFacilities
                                      .map((f) {
                                        final w = waits.waitTimes
                                            .where((wt) => wt.rideId == f.id)
                                            .firstOrNull;
                                        return (facility: f, wait: w);
                                      })
                                      .where(
                                        (item) => _matchesGlobalFilter(
                                          item.facility,
                                          item.wait,
                                          filters,
                                        ),
                                      )
                                      .toList()
                                    ..sort((a, b) {
                                      final wA = a.wait?.waitMinutes ?? 0;
                                      final wB = b.wait?.waitMinutes ?? 0;
                                      final nameA = a.facility.name;
                                      final nameB = b.facility.name;

                                      switch (sortOrder) {
                                        case 'Name (Z-A)':
                                          return nameB.compareTo(nameA);
                                        case 'Wait Time (High to Low)':
                                          if (wA == wB) {
                                            return nameA.compareTo(nameB);
                                          }
                                          return wB.compareTo(wA);
                                        case 'Wait Time (Low to High)':
                                          if (wA == wB) {
                                            return nameA.compareTo(nameB);
                                          }
                                          return wA.compareTo(wB);
                                        case 'Name (A-Z)':
                                        default:
                                          return nameA.compareTo(nameB);
                                      }
                                    });

                              if (displayItems.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No attractions match criteria',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                );
                              }

                              return ListView.separated(
                                itemCount: displayItems.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = displayItems[index];
                                  final fac = item.facility;
                                  final w = item.wait;

                                  final cs = Theme.of(context).colorScheme;
                                  final waitBg = w?.waitMinutes != null
                                      ? (w!.waitMinutes! <= 20
                                            ? cs.primaryContainer
                                            : (w.waitMinutes! <= 50
                                                  ? cs.tertiaryContainer
                                                  : cs.errorContainer))
                                      : cs.surfaceContainerHigh;
                                  final waitFg = w?.waitMinutes != null
                                      ? (w!.waitMinutes! <= 20
                                            ? cs.onPrimaryContainer
                                            : (w.waitMinutes! <= 50
                                                  ? cs.onTertiaryContainer
                                                  : cs.onErrorContainer))
                                      : cs.onSurfaceVariant;

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => FacilityDetailPage(
                                              facilityId: fac.id,
                                              parkId: park.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: cs.outlineVariant.withValues(
                                              alpha: 0.4,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Stack attraction name and badge vertically if horizontal space is tight
                                            Text(
                                              fac.name,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: cs.onSurface,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.attractions_rounded,
                                                      size: 14,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      fac.category,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            cs.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: waitBg,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    w?.waitMinutes != null
                                                        ? '${w!.waitMinutes} min'
                                                        : 'Closed',
                                                    style: TextStyle(
                                                      color: waitFg,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, st) => Center(
                              child: Text('Error loading wait times: $err'),
                            ),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, st) => Center(
                            child: Text('Error loading park detail: $err'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isDrawerOpen)
                const Positioned.fill(child: DesktopFilterDrawer()),
            ],
          ),
        ),
      ],
    );
  }
}

class DesktopFilterDrawer extends ConsumerStatefulWidget {
  const DesktopFilterDrawer({super.key});

  @override
  ConsumerState<DesktopFilterDrawer> createState() =>
      _DesktopFilterDrawerState();
}

class _DesktopFilterDrawerState extends ConsumerState<DesktopFilterDrawer> {
  final Set<String> _localAgeGroups = {};
  final Set<String> _localTypes = {};
  final Set<String> _localStatuses = {};

  @override
  void initState() {
    super.initState();
    final globalState = ref.read(globalParkFilterProvider);
    _localAgeGroups.addAll(globalState.ageGroups);
    _localTypes.addAll(globalState.types);
    _localStatuses.addAll(globalState.statuses);
  }

  void _applyFilters() {
    ref.read(globalParkFilterProvider.notifier).updateFilter(
          ParkFilters(
            ageGroups: Set.from(_localAgeGroups),
            types: Set.from(_localTypes),
            statuses: Set.from(_localStatuses),
          ),
        );
    ref.read(parkFilterDrawerOpenProvider.notifier).updateOpen(open: false);
  }

  void _clearAll() {
    setState(() {
      _localAgeGroups.clear();
      _localTypes.clear();
      _localStatuses.clear();
    });
    ref.read(globalParkFilterProvider.notifier).updateFilter(ParkFilters());
    ref.read(parkFilterDrawerOpenProvider.notifier).updateOpen(open: false);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      elevation: 6,
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: _clearAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        ref
                            .read(parkFilterDrawerOpenProvider.notifier)
                            .updateOpen(open: false);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Target Age Group'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          'All Ages',
                          'Preschool',
                          'Kids',
                          'Tweens',
                          'Teens',
                          'Adults',
                        ].map((age) {
                          final isSelected = _localAgeGroups.contains(age);
                          return FilterChip(
                            label: Text(
                              age,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _localAgeGroups.add(age);
                                } else {
                                  _localAgeGroups.remove(age);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  _buildSectionTitle('Type of Attraction'),
                  ...[
                    'Rides',
                    'Shows',
                    'Dining / Restaurants',
                    'Character Experiences',
                    'Walkthroughs / Play Areas',
                  ].map((type) {
                    return CheckboxListTile(
                      title: Text(type, style: const TextStyle(fontSize: 13)),
                      value: _localTypes.contains(type),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      visualDensity: VisualDensity.compact,
                      onChanged: (val) {
                        setState(() {
                          if (val ?? false) {
                            _localTypes.add(type);
                          } else {
                            _localTypes.remove(type);
                          }
                        });
                      },
                    );
                  }),
                  _buildSectionTitle('Status'),
                  ...[
                    'Operating',
                    'Temporarily Closed / Down',
                    'Under Refurbishment',
                  ].map((status) {
                    return CheckboxListTile(
                      title: Text(status, style: const TextStyle(fontSize: 13)),
                      value: _localStatuses.contains(status),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      visualDensity: VisualDensity.compact,
                      onChanged: (val) {
                        setState(() {
                          if (val ?? false) {
                            _localStatuses.add(status);
                          } else {
                            _localStatuses.remove(status);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: FilledButton(
              onPressed: _applyFilters,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
