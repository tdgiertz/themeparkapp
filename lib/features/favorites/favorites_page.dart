import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/core/logging/logger.dart';
import 'package:themeparkapp/core/models/enums.dart';
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
              final rawStatus = f.currentWait?['status'];
              final statusEnum = rawStatus is WaitTimeStatus
                  ? rawStatus
                  : WaitTimeStatus.fromString(rawStatus?.toString());
              final status = statusEnum.displayName;
              final waitMinutes = f.currentWait?['waitMinutes'];
              return ListTile(
                leading: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(f.name),
                subtitle: Text(f.parkName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(status),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    Text(waitMinutes != null ? '${waitMinutes}m' : '-'),
                  ],
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) {
            talker.handle(err, st);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading favorites: $err'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'RETRY',
                      onPressed: () {
                        ref.invalidate(favoritesProvider);
                      },
                    ),
                  ),
                );
              }
            });
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error loading favorites: $err'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(favoritesProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry loading favorites'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
