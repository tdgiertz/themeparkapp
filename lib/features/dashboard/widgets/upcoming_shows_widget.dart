import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active park filter context for the global dashboard ('all' or specific park id).
final selectedDashboardParkProvider = StateProvider<String>((ref) => 'all');

/// Model for an upcoming show or entertainment event.
class ShowEvent {
  const ShowEvent({
    required this.id,
    required this.parkId,
    required this.parkName,
    required this.title,
    required this.startTime,
    required this.venue,
    required this.category, // 'Parade', 'Stage Show', 'Nighttime Spectacular', 'Character Meet'
    required this.durationMinutes,
  });

  final String id;
  final String parkId;
  final String parkName;
  final String title;
  final String startTime;
  final String venue;
  final String category;
  final int durationMinutes;
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

/// Horizontally scrolling widget highlighting upcoming shows & entertainment.
class UpcomingShowsWidget extends ConsumerWidget {
  const UpcomingShowsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedParkId = ref.watch(selectedDashboardParkProvider);
    final shows = selectedParkId == 'all'
        ? mockUpcomingShows
        : mockUpcomingShows.where((s) => s.parkId == selectedParkId).toList();

    if (shows.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              const SizedBox(width: 8),
              Text(
                '${shows.length} Scheduled',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: shows.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final show = shows[index];
              return _ShowCard(show: show);
            },
          ),
        ),
        const SizedBox(height: 12),
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
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: cs.surfaceContainerHigh,
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    show.parkName,
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              show.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.place, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    show.venue,
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
