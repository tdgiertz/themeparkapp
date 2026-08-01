import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/features/park/facility_detail_page.dart';
import 'package:themeparkapp/features/parks/providers/park_providers.dart';

final selectedDashboardParkProvider = StateProvider<String>((ref) => 'all');

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
  final String?
  scarcityTag; // 'Only Performance Today', 'Final Show', 'Requires Virtual Queue'
}

DateTime? parseShowTime(String timeStr, DateTime currentDate) {
  try {
    final clean = timeStr.trim().replaceAll(RegExp(r'\s+'), ' ');
    final parts = clean.split(' ');
    if (parts.length != 2) return null;
    final hm = parts[0].split(':');
    if (hm.length != 2) return null;
    var hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final ampm = parts[1].toUpperCase();

    if (ampm == 'PM' && hour < 12) hour += 12;
    if (ampm == 'AM' && hour == 12) hour = 0;

    return DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
      hour,
      minute,
    );
  } on Object catch (_) {
    return null;
  }
}

class UpcomingShowsWidget extends ConsumerWidget {
  const UpcomingShowsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedParkId = ref.watch(selectedDashboardParkProvider);
    final showsAsync = ref.watch(upcomingShowsProvider);
    final allShows = showsAsync.value ?? const <ShowEvent>[];

    final currentTime = DateTime(2026, 7, 31, 14, 40, 30);
    const transitMinutes = 12;

    final parkShows = selectedParkId == 'all'
        ? allShows
        : allShows.where((s) => s.parkId == selectedParkId).toList();

    final validShows = <MapEntry<ShowEvent, int>>[];
    for (final show in parkShows) {
      final showTime = parseShowTime(show.startTime, currentTime);
      if (showTime == null) continue;

      final buffer =
          showTime.difference(currentTime).inMinutes - transitMinutes;
      if (buffer >= 0) {
        validShows.add(MapEntry(show, buffer));
      }
    }

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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  FacilityDetailPage(facilityId: show.id, parkId: show.parkId),
            ),
          );
        },
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      show.startTime,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      show.parkName,
                      style: theme.textTheme.labelSmall?.copyWith(
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      show.venue,
                      style: theme.textTheme.labelSmall?.copyWith(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: cs.tertiary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          show.scarcityTag!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: cs.onTertiaryContainer,
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
      ),
    );
  }
}
