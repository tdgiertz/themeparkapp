import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/core/environment_providers.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/core/widgets/adaptive_image.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

/// Details page for the selected item.
class DetailsPage extends ConsumerWidget {
  /// Creates the details page.
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(detailsProvider);
    final mediaQuality = ref.watch(mediaQualityProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.details_title)),
      body: Column(
        children: [
          if (mediaQuality == MediaQuality.low)
            const MaterialBanner(
              content: Text('Low network or battery — using lighter media'),
              actions: [],
            ),
          Expanded(
            child: ScreenTypeLayout.builder(
              mobile: (context) => Center(
                child: async.when(
                  data: (value) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      const AdaptiveNetworkImage(
                        highResUrl: 'https://example.com/high.jpg',
                        lowResUrl: 'https://example.com/low.jpg',
                        width: 300,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                      Text(value),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: Text(loc.back),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(detailsProvider),
                        child: Text(loc.reload),
                      ),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, st) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $err'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(detailsProvider),
                        child: Text(loc.retry),
                      ),
                    ],
                  ),
                ),
              ),
              tablet: (context) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: async.when(
                        data: (value) => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AdaptiveNetworkImage(
                              highResUrl: 'https://example.com/high.jpg',
                              lowResUrl: 'https://example.com/low.jpg',
                              width: 640,
                              height: 320,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              value,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => context.pop(),
                                  child: Text(loc.back),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => ref.refresh(detailsProvider),
                                  child: Text(loc.reload),
                                ),
                              ],
                            ),
                          ],
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, st) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Error: $err'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => ref.refresh(detailsProvider),
                              child: Text(loc.retry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              desktop: (context) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Card(
                    margin: const EdgeInsets.all(24),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: async.when(
                        data: (value) => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AdaptiveNetworkImage(
                              highResUrl: 'https://example.com/high.jpg',
                              lowResUrl: 'https://example.com/low.jpg',
                              width: 900,
                              height: 360,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              value,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => context.pop(),
                                  child: Text(loc.back),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => ref.refresh(detailsProvider),
                                  child: Text(loc.reload),
                                ),
                              ],
                            ),
                          ],
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, st) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Error: $err'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => ref.refresh(detailsProvider),
                              child: Text(loc.retry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
