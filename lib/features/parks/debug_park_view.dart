import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/park_providers.dart';

class DebugParkView extends ConsumerWidget {
  const DebugParkView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parksAsyncValue = ref.watch(driftParksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drift Database Verification'),
      ),
      body: parksAsyncValue.when(
        data: (parks) {
          if (parks.isEmpty) {
            return const Center(child: Text('No parks found.'));
          }
          return ListView.builder(
            itemCount: parks.length,
            itemBuilder: (context, index) {
              final park = parks[index];
              return ListTile(
                title: Text(park.name),
                subtitle: Text('ID: ${park.id} | Type: ${park.type}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
