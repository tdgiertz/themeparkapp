import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDashboardParkProvider = StateProvider<String>((ref) => 'all');

// We redeclare ShowEvent here or keep the existing file's signature clean.
// Let's rewrite upcoming_shows_widget.dart completely with the required logic.

class ShowEvent {
  const ShowEvent({
    required this.id,
    required this.parkId,
    required this.parkName,
    required this.title,
    required this.startTime,
    required this.venue,
    required this.category,
    required this.durationMinutes,
    this.isOnlyPerformanceToday = false,
    this.scarcityTag,
  });

  final String id;
  final String parkId;
  final String parkName;
  final String title;
  final String startTime;
  final String venue;
  final String category;
  final int durationMinutes;
  final bool isOnlyPerformanceToday;
  final String? scarcityTag; // 'Only Performance Today', 'Final Show', 'Requires Virtual Queue'
}

/// Mock upcoming shows & entertainment dataset.
final mockUpcomingShows = <ShowEvent>[
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
    id: 'show_2',
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

DateTime? parseShowTime(String timeStr, DateTime currentDate) {
  try {
    final clean = timeStr.trim().replaceAll(RegExp(r'\s+'), ' ');
    final parts = clean.split(' ');
    if (parts.length != 2) return null;
    final hm = parts[0].split(':');
    if (hm.length != 2) return null;
    int hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final ampm = parts[1].toUpperCase();

    if (ampm == 'PM' && hour < 12) hour += 12;
    if (ampm == 'AM' && hour == 12) hour = 0;

    return DateTime(currentDate.year, currentDate.month, currentDate.day, hour, minute);
  } catch (_) {
    return null;
  }
}

class UpcomingShowsWidget extends ConsumerWidget {
  const UpcomingShowsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedParkId = ref.watch(selectedDashboardParkProvider);
    
    // We assume current time is 2026-07-31T14:40:30-05:00
    final currentTime = DateTime(2026, 7, 31, 14, 40, 30);
    const transitMinutes = 12;

    // Filter by park first
    final parkShows = selectedParkId == 'all'
        ? mockUpcomingShows
        : mockUpcomingShows.where((s) => s.parkId == selectedParkId).toList();

    // Calculate buffer and filter out negative buffers
    final validShows = <MapEntry<ShowEvent, int>>[];
    for (final show in parkShows) {
      final showTime = parseShowTime(show.startTime, currentTime);
      if (showTime == null) continue;
      
      final buffer = showTime.difference(currentTime).inMinutes - transitMinutes;
      if (buffer >= 0) {
        validShows.add(MapEntry(show, buffer));
      }
    }

    // Sort: Exclusivity Boost first, then by buffer
    validShows.sort((a, b) {
      final pinA = a.key.isOnlyPerformanceToday;
      final pinB = b.key.isOnlyPerformanceToday;

      if (pinA && !pinB) return -1;
      if (!pinA && pinB) return 1;

      return a.value.compareTo(b.value);
    });

    final sortedShows = validShows.map((e) => e.key).toList();

    if (sortedShows.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Upcoming Shows & Entertainment',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${sortedShows.length} Shows Today',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: sortedShows.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final show = sortedShows[index];
              return _ShowCard(show: show);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ShowCard extends StatelessWidget {
  const _ShowCard({required this.show});

  final ShowEvent show;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surfaceContainerHigh,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    show.startTime,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    show.parkName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              show.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.place_outlined, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    show.venue,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (show.scarcityTag != null) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        show.scarcityTag!,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
