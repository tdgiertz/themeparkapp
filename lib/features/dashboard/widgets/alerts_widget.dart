import 'package:flutter/material.dart';
import 'package:themeparkapp/models/favorite.dart';

class DashboardAlert {
  DashboardAlert({
    required this.id,
    required this.type, // 'reopened', 'last_call', 'target_reached', 'time_to_go', 'opportunity'
    required this.title,
    required this.message,
    required this.accentColor,
    required this.icon,
    this.scarcityTag,
    this.trendTag,
    this.statusTag,
    required this.actionTag,
    required this.parkId,
    this.onAction,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final Color accentColor;
  final IconData icon;
  final String? scarcityTag;
  final String? trendTag;
  final String? statusTag;
  final String actionTag; // 'View on Map', 'Get Walking Directions', 'Modify Alert Threshold'
  final String parkId;
  final VoidCallback? onAction;
}

class AlertsWidget extends StatelessWidget {
  const AlertsWidget({
    required this.alerts,
    this.onDismiss,
    super.key,
  });

  final List<DashboardAlert> alerts;
  final void Function(String alertId)? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amber, size: 20),
              const SizedBox(width: 6),
              Text(
                'Live Action Center',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: alerts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return _AlertCard(
              alert: alert,
              onDismiss: () {
                onDismiss?.call(alert.id);
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.onDismiss,
  });

  final DashboardAlert alert;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dismissible(
      key: Key(alert.id),
      onDismissed: (_) => onDismiss(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: cs.errorContainer,
        child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: alert.accentColor,
              width: 5,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: alert.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      alert.icon,
                      color: alert.accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Badges & Action Section
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (alert.scarcityTag != null)
                          _Badge(
                            label: alert.scarcityTag!,
                            color: Colors.orange,
                            icon: Icons.star_border_rounded,
                          ),
                        if (alert.trendTag != null)
                          _Badge(
                            label: alert.trendTag!,
                            color: Colors.blue,
                            icon: Icons.trending_up,
                          ),
                        if (alert.statusTag != null)
                          _Badge(
                            label: alert.statusTag!,
                            color: Colors.red,
                            icon: Icons.info_outline,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: alert.onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alert.accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      alert.actionTag,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic alert generator evaluating favorites and generating alert cards.
List<DashboardAlert> generateDynamicAlerts({
  required List<FavoriteRide> favorites,
  required String selectedParkId,
  required DateTime currentTime,
  required BuildContext context,
}) {
  final list = <DashboardAlert>[];

  // We map favorites JSON park IDs ("1" -> "p2", "3" -> "p5") to ensure compatibility
  String normalizeParkId(String rawId) {
    if (rawId == '1') return 'p2';
    if (rawId == '3') return 'p5';
    return rawId;
  }

  final normalizedFavs = favorites.map((f) {
    return FavoriteRide(
      rideId: f.rideId,
      name: f.name,
      parkId: normalizeParkId(f.parkId),
      parkName: f.parkName,
      currentWait: f.currentWait,
    );
  }).toList();

  final filteredFavs = selectedParkId == 'all'
      ? normalizedFavs
      : normalizedFavs.where((f) => f.parkId == selectedParkId).toList();

  for (final f in filteredFavs) {
    final status = f.currentWait?['status'] as String? ?? 'Closed';
    final wait = f.currentWait?['waitMinutes'] as int? ?? 0;
    
    // Simulate user-defined threshold for demo. We'll say Pirates has a threshold of 50.
    final maxWaitThreshold = f.rideId == '1' ? 50 : 30;

    // 1. Reopened (Status Change): Offline/Closed -> Open in last 10 minutes
    // We mock this logic: if ride is Open and updatedAt is very recent (e.g. within 10 min)
    // For demo, we'll mark Pirates (id: "1") as just reopened if we want to demonstrate it
    bool isReopened = false;
    if (status == 'Open' && f.rideId == '1') {
      isReopened = true;
    }

    if (isReopened) {
      list.add(
        DashboardAlert(
          id: 'reopened_${f.rideId}',
          type: 'reopened',
          title: 'Just Reopened',
          message: 'Just Reopened: ${f.name} is back online.',
          accentColor: Colors.purple,
          icon: Icons.replay_circle_filled_rounded,
          statusTag: 'Open',
          actionTag: 'Get Walking Directions',
          parkId: f.parkId,
          onAction: () {},
        ),
      );
    }

    // 2. Last Call (Closing Soon): Queue Closure Time - (Current Time + Estimated Transit) <= 45 minutes
    // Let's mock a ride closing soon. E.g. Hagrid's (id: "88") closes at 15:30.
    // Current time: 14:40. Estimated Transit: 15 mins. Difference: 35 mins <= 45 mins.
    bool isLastCall = f.rideId == '88' && status == 'Delayed'; // Let's trigger last call for demo
    if (isLastCall) {
      list.add(
        DashboardAlert(
          id: 'last_call_${f.rideId}',
          type: 'last_call',
          title: 'Last Call',
          message: 'Last Call: ${f.name} closes in 35 mins.',
          accentColor: Colors.amber.shade800,
          icon: Icons.hourglass_bottom_rounded,
          scarcityTag: 'Final Show',
          statusTag: 'Delayed',
          actionTag: 'View on Map',
          parkId: f.parkId,
          onAction: () {},
        ),
      );
    }

    // 3. Target Reached (Threshold Drop): User-defined max_wait threshold >= Current Wait Time
    if (status == 'Open' && wait <= maxWaitThreshold && !isReopened) {
      list.add(
        DashboardAlert(
          id: 'target_reached_${f.rideId}',
          type: 'target_reached',
          title: 'Target Reached',
          message: 'Target Reached: ${f.name} is currently $wait mins.',
          accentColor: Colors.green,
          icon: Icons.check_circle_outline_rounded,
          trendTag: '📉',
          actionTag: 'Modify Alert Threshold',
          parkId: f.parkId,
          onAction: () {},
        ),
      );
    }

    // 4. Opportunity (Downward Trend): rolling delta drop >= 20% in last 15-30 mins
    // Let's simulate a downward trend for demo if not already handled
    if (status == 'Open' && f.rideId == '1') {
      list.add(
        DashboardAlert(
          id: 'opportunity_${f.rideId}',
          type: 'opportunity',
          title: 'Trending Down',
          message: 'Trending Down: ${f.name} dropped 15 mins in the last half hour.',
          accentColor: Colors.blue,
          icon: Icons.trending_down_rounded,
          trendTag: '📉',
          actionTag: 'Get Walking Directions',
          parkId: f.parkId,
          onAction: () {},
        ),
      );
    }
  }

  // 5. Time to Go (Approaching Showtime): Show Start Time - (Current Time + Estimated Transit) <= 20 minutes
  // Let's simulate a show starting soon (e.g. at 15:00, transit 10 mins)
  if (selectedParkId == 'all' || selectedParkId == 'p2') {
    list.add(
      DashboardAlert(
        id: 'time_to_go_show1',
        type: 'time_to_go',
        title: 'Starting Soon',
        message: 'Starting Soon: Festival of Fantasy Parade begins in 10 mins (8 min walk).',
        accentColor: Theme.of(context).colorScheme.primary,
        icon: Icons.directions_walk_rounded,
        scarcityTag: 'Only Performance Today',
        actionTag: 'Get Walking Directions',
        parkId: 'p2',
        onAction: () {},
      ),
    );
  }

  // Sort: Reopened > Last Call > Target Reached > Time to Go > Opportunity
  final priorityMap = {
    'reopened': 0,
    'last_call': 1,
    'target_reached': 2,
    'time_to_go': 3,
    'opportunity': 4,
  };

  list.sort((a, b) {
    final pA = priorityMap[a.type] ?? 99;
    final pB = priorityMap[b.type] ?? 99;
    return pA.compareTo(pB);
  });

  return list;
}
