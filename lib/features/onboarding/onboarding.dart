import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/core/onboarding_state.dart';
import 'package:themeparkapp/core/permissions.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

/// Simple onboarding screen that explains location usage and exposes
/// the `LocationPermissionRequestTile` to let users grant permission.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc?.appTitle ?? 'Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc?.onboarding_title ?? 'Enable location for in-park features',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              loc?.onboarding_body ??
                  'We use your location to show nearby attractions, live wait times, and context-aware maps while you are in the park.',
            ),
            const SizedBox(height: 24),
            const LocationPermissionRequestTile(),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  key: const ValueKey('onboarding_skip'),
                  onPressed: () async {
                    // Persist that the user skipped onboarding so we don't show it again.
                    await ref
                        .read(onboardingCompletedProvider.notifier)
                        .complete();
                    if (context.mounted) {
                      await Navigator.of(context).maybePop();
                    }
                  },
                  child: Text(loc?.skip ?? 'Skip'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    // Trigger a permission check+request; UI will rebuild when provider updates.
                    await ref
                        .read(locationPermissionProvider.notifier)
                        .checkAndRequestIfNeeded();
                    // User tapped continue — persist onboarding as completed.
                    await ref
                        .read(onboardingCompletedProvider.notifier)
                        .complete();
                  },
                  child: Text(loc?.continueText ?? 'Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
