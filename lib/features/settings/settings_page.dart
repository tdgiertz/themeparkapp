import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/settings/widgets/theme_color_settings_tile.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

/// Settings page where the user selects theme and preferences.
class SettingsPage extends ConsumerWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings_title)),
      body: ScreenTypeLayout.builder(
        mobile: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.settings_page),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('System'),
                    selected: themeMode == ThemeMode.system,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(themeModeProvider.notifier).state =
                            ThemeMode.system;
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Light'),
                    selected: themeMode == ThemeMode.light,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(themeModeProvider.notifier).state =
                            ThemeMode.light;
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Dark'),
                    selected: themeMode == ThemeMode.dark,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(themeModeProvider.notifier).state =
                            ThemeMode.dark;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Card(child: ThemeColorSettingsTile()),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(loc.back),
              ),
            ],
          ),
        ),
        tablet: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.settings_page),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('System'),
                                selected: themeMode == ThemeMode.system,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.system;
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Light'),
                                selected: themeMode == ThemeMode.light,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.light;
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Dark'),
                                selected: themeMode == ThemeMode.dark,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.dark;
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const ThemeColorSettingsTile(),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.pop(),
                            child: Text(loc.back),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 220,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Preview',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Builder(
                                builder: (context) {
                                  final modeName = themeMode
                                      .toString()
                                      .split('.')
                                      .last;
                                  return Text('Current theme: $modeName');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        desktop: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.settings_page,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('System'),
                                selected: themeMode == ThemeMode.system,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.system;
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Light'),
                                selected: themeMode == ThemeMode.light,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.light;
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Dark'),
                                selected: themeMode == ThemeMode.dark,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(themeModeProvider.notifier).state =
                                        ThemeMode.dark;
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const ThemeColorSettingsTile(),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Builder(
                                builder: (context) {
                                  final modeName = themeMode
                                      .toString()
                                      .split('.')
                                      .last;
                                  return Text('Current theme: $modeName');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
