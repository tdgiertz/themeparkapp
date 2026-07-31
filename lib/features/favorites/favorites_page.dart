import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/core/providers.dart';

/// Full page showing the user's favorites.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: favsAsync.when(
          data: (favorites) => ListView.separated(
            itemCount: favorites.favoriteRides.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final f = favorites.favoriteRides[index];
              final status = f.currentWait?['status']?.toString() ?? 'n/a';
              final waitMinutes = f.currentWait?['waitMinutes'];
              return ListTile(
                leading: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
                title: Text(f.name),
                subtitle: Text(f.parkName),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(label: Text(status)),
                    Text(waitMinutes != null ? '${waitMinutes}m' : '-'),
                  ],
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading favorites')),
        ),
      ),
    );
  }
}
