import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/core/theme.dart';

/// Settings tile that displays current theme seed color and allows the user to update it globally via flex_color_picker.
class ThemeColorSettingsTile extends ConsumerWidget {
  const ThemeColorSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColor =
        ref.watch(themeSeedColorProvider) ?? AppTheme.primaryAccent;

    return ListTile(
      title: const Text('Theme Color'),
      subtitle: const Text('Customize application accent & seed color'),
      trailing: ColorIndicator(
        width: 36,
        height: 36,
        borderRadius: 18,
        color: currentColor,
        onSelectFocus: false,
      ),
      onTap: () async {
        final newColor = await showColorPickerDialog(
          context,
          currentColor,
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.both: true,
            ColorPickerType.primary: true,
            ColorPickerType.wheel: true,
            ColorPickerType.accent: false,
            ColorPickerType.bw: false,
            ColorPickerType.custom: false,
          },
        );

        if (context.mounted && newColor != currentColor) {
          await ref.read(themeSeedColorProvider.notifier).setColor(newColor);
        }
      },
    );
  }
}
