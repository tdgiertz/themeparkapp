import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themeparkapp/core/theme.dart';
import 'package:themeparkapp/widgets/theme_color_settings_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppTheme.darkTheme uses seed color when provided', () {
    const customColor = Colors.purple;
    final theme = AppTheme.darkTheme(customColor);
    expect(theme.colorScheme.primary.toARGB32(), customColor.toARGB32());
  });

  test('AppTheme.lightTheme uses seed color when provided', () {
    const customColor = Colors.green;
    final theme = AppTheme.lightTheme(customColor);
    expect(theme.colorScheme.primary.toARGB32(), customColor.toARGB32());
  });

  testWidgets('ThemeColorSettingsTile renders and shows color indicator', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ThemeColorSettingsTile(),
          ),
        ),
      ),
    );

    expect(find.text('Theme Color'), findsOneWidget);
    expect(find.text('Customize application accent & seed color'), findsOneWidget);
  });
}
