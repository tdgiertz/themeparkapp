import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:themeparkapp/features/parks/providers/park_providers.dart';

class ParkCardExample extends ConsumerWidget {

  const ParkCardExample({required this.parkId, super.key});
  final String parkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parksAsyncValue = ref.watch(parksProvider);
    final highlightsAsyncValue = ref.watch(parkHighlightsProvider(parkId));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            parksAsyncValue.when(
              data: (parks) {
                final park = parks.firstWhere((p) => p.id == parkId);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      park.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Hours: ${park.operatingHours.open} - ${park.operatingHours.close}'),
                    Text('Crowd Level: ${park.crowdLevel}'),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error loading park: $e'),
            ),
            const Divider(height: 32),
            Text(
              'Highlights',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            highlightsAsyncValue.when(
              data: (highlights) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (highlights.shortestWaitTimes.isNotEmpty) ...[
                      const Text('Shortest Waits:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...highlights.shortestWaitTimes.map((wt) => Text('${wt.name}: ${wt.waitMinutes} min')),
                      const SizedBox(height: 8),
                    ],
                    if (highlights.nextShowtimes.isNotEmpty) ...[
                      const Text('Next Showtime:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...highlights.nextShowtimes.map((st) => Text('${st.name} at ${st.time}')),
                    ]
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error loading highlights: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
