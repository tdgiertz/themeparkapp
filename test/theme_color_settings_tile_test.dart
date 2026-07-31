import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themeparkapp/widgets/theme_color_settings_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'ThemeColorSettingsTile renders title, subtitle, and ColorIndicator',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: ThemeColorSettingsTile())),
        ),
      );

      expect(find.text('Theme Color'), findsOneWidget);
      expect(
        find.text('Customize application accent & seed color'),
        findsOneWidget,
      );
      expect(find.byType(ColorIndicator), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    },
  );
}
