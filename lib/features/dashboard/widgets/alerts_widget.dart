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
    return Dismissible(
      key: Key(alert.id),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: alert.backgroundColor.withOpacity(0.15),
          border: Border.all(
            color: alert.backgroundColor.withOpacity(0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: alert.backgroundColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                alert.icon,
                color: alert.backgroundColor,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (alert.actionLabel != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: alert.onAction,
                child: Text(
                  alert.actionLabel!,
                  style: TextStyle(
                    fontSize: 11,
                    color: alert.backgroundColor,
                    fontWeight: FontWeight.bold,
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

/// Generator for mock alerts based on favorites data.
List<DashboardAlert> generateMockAlerts(List<FavoriteRide> favorites) {
  final alerts = <DashboardAlert>[];

  // 1. Wait Time Drop Alerts
  if (favorites.isNotEmpty) {
    final favWithLowWait = favorites.where((f) {
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
          message: '${ride.name}\'s wait time just dropped to ${wait}m—the lowest it has been all day!',
          icon: Icons.trending_down,
          backgroundColor: Colors.green.shade600,
          actionLabel: 'Directions',
          onAction: () {},
        ),
      );
    }
  }

  // 2. Schedule Reminders (e.g. 30 min before showtime)
  alerts.add(
    DashboardAlert(
      id: 'schedule_reminder_parade',
      type: 'schedule',
      title: 'Festival of Fantasy Parade – Starts in 25m',
      message: 'Grab a viewing spot on Main Street, U.S.A. before crowds form!',
      icon: Icons.access_time_filled,
      backgroundColor: Colors.purple.shade600,
      actionLabel: 'Set Reminder',
      onAction: () {},
    ),
  );

  // 3. Downtime Notifications
  if (favorites.isNotEmpty) {
    final closedRides = favorites.where((f) {
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
          backgroundColor: Colors.orange.shade700,
          actionLabel: 'View Alt',
          onAction: () {},
        ),
      );
    }
  }

  return alerts;
}
