import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';
import 'package:themeparkapp/main.dart';

void main() {
  testWidgets('counter increments on MyHomePage', (WidgetTester tester) async {
    Future<String> loader(String path) async => File(path).readAsString();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [assetLoaderProvider.overrideWithValue(loader)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MyHomePage(title: 'Test'),
        ),
      ),
    );
    // Verify initial counter 0
    expect(find.text('0'), findsOneWidget);

    // Tap FAB to increment
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
  });
}
