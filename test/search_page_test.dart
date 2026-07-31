import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:themeparkapp/features/search/search_page.dart';

void main() {
  testWidgets('SearchPage mobile layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SearchPage()),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.textContaining('Welcome'), findsOneWidget); 
    // Need more specific text match based on actual implementation of chat welcome message
  });

  testWidgets('SearchPage desktop layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SearchPage()),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    // Focus check might need specific key or logic
  });
}
