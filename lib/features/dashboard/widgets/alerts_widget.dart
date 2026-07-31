import 'package:flutter/material.dart';
import 'package:themeparkapp/models/favorite.dart';

/// Represents a single actionable alert/insight.
class DashboardAlert {
  DashboardAlert({
    required this.id,
    required this.type, // 'wait_drop', 'schedule', 'downtime'
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.actionLabel,
    this.onAction,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final String? actionLabel;
  final VoidCallback? onAction;
}

/// Widget displaying "Next Best Action" alerts and insights.
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
          child: Text(
            'Next Best Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: alerts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return _AlertTile(
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

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.alert,
    required this.onDismiss,
  });

  final DashboardAlert alert;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bgContainer;
    Color fgOnContainer;

    switch (alert.type) {
      case 'wait_drop':
        bgContainer = cs.primaryContainer;
        fgOnContainer = cs.onPrimaryContainer;
      case 'schedule':
        bgContainer = cs.secondaryContainer;
        fgOnContainer = cs.onSecondaryContainer;
      case 'downtime':
        bgContainer = cs.errorContainer;
        fgOnContainer = cs.onErrorContainer;
      default:
        bgContainer = cs.surfaceContainerHigh;
        fgOnContainer = cs.onSurface;
    }

    return Dismissible(
      key: Key(alert.id),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: fgOnContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    alert.icon,
                    color: fgOnContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: fgOnContainer,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: fgOnContainer.withValues(alpha: 0.8),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (alert.actionLabel != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: alert.onAction,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    alert.actionLabel!,
                    style: TextStyle(
                      fontSize: 11,
                      color: fgOnContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Generator for mock alerts based on favorites data and selected park context.
List<DashboardAlert> generateMockAlerts(List<FavoriteRide> favorites, [String selectedParkId = 'all']) {
  final alerts = <DashboardAlert>[];

  final filteredFavorites = selectedParkId == 'all'
      ? favorites
      : favorites.where((f) => f.parkId == selectedParkId).toList();

  // 1. Wait Time Drop Alerts
  if (filteredFavorites.isNotEmpty) {
    final favWithLowWait = filteredFavorites.where((f) {
      final wait = f.currentWait?['waitMinutes'] as int? ?? 0;
      final status = f.currentWait?['status'] as String? ?? '';
      return status == 'Open' && wait <= 25;
    }).toList();

    if (favWithLowWait.isNotEmpty) {
      final ride = favWithLowWait.first;
      final wait = ride.currentWait?['waitMinutes'] as int? ?? 0;
      alerts.add(
        DashboardAlert(
          id: 'wait_drop_${ride.rideId}',
          type: 'wait_drop',
          title: '${ride.name} – Wait Time Drop!',
          message: "${ride.name}'s wait time just dropped to ${wait}m—the lowest it has been all day!",
          icon: Icons.trending_down,
          backgroundColor: const Color(0xFF10B981),
          actionLabel: 'Directions',
          onAction: () {},
        ),
      );
    }
  }

  // 2. Schedule Reminders (e.g. 30 min before showtime)
  if (selectedParkId == 'all' || selectedParkId == 'p2') {
    alerts.add(
      DashboardAlert(
        id: 'schedule_reminder_parade',
        type: 'schedule',
        title: 'Festival of Fantasy Parade – Starts in 25m',
        message: 'Grab a viewing spot on Main Street, U.S.A. before crowds form!',
        icon: Icons.access_time_filled,
        backgroundColor: const Color(0xFF8B5CF6),
        actionLabel: 'Set Reminder',
        onAction: () {},
      ),
    );
  } else if (selectedParkId == 'p1') {
    alerts.add(
      DashboardAlert(
        id: 'schedule_reminder_lion_king',
        type: 'schedule',
        title: 'Festival of the Lion King – Starts in 20m',
        message: 'Head to Harambe Theater for the next performance!',
        icon: Icons.access_time_filled,
        backgroundColor: const Color(0xFF8B5CF6),
        actionLabel: 'Set Reminder',
        onAction: () {},
      ),
    );
  }

  // 3. Downtime Notifications
  if (filteredFavorites.isNotEmpty) {
    final closedRides = filteredFavorites.where((f) {
      final status = f.currentWait?['status'] as String? ?? '';
      return status != 'Open';
    }).toList();

    if (closedRides.isNotEmpty) {
      final ride = closedRides.first;
      alerts.add(
        DashboardAlert(
          id: 'downtime_${ride.rideId}',
          type: 'downtime',
          title: '${ride.name} is Temporarily Offline',
          message: 'Ride is currently experiencing technical difficulties. We will notify you when it reopens.',
          icon: Icons.warning_amber_rounded,
          backgroundColor: const Color(0xFFEF4444),
          actionLabel: 'View Alt',
          onAction: () {},
        ),
      );
    }
  }

  return alerts;
}
