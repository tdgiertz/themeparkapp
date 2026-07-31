import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:themeparkapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end Test', () {
    testWidgets('Complete app flows', (WidgetTester tester) async {
      // 1. App boot & Onboarding flow
      app.main();
      await tester.pumpAndSettle();

      // Check if we are on the Onboarding screen
      final skipButton = find.byKey(const ValueKey('onboarding_skip'));
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // 2. Dashboard flow - Park Selection
      // Ensure we are on Dashboard
      final navHome = find.byKey(const ValueKey('nav_home'));
      expect(navHome, findsOneWidget);
      await tester.tap(navHome);
      await tester.pumpAndSettle();

      // Tap 'All Parks' in the dashboard selector
      final allParksSelector = find.byKey(const ValueKey('park_selector_all'));
      if (allParksSelector.evaluate().isNotEmpty) {
        await tester.scrollUntilVisible(allParksSelector, 100.0, scrollable: find.byType(Scrollable).first);
        await tester.tap(allParksSelector);
        await tester.pumpAndSettle();
      }

      // 3. Search AI flow
      final navSearch = find.byKey(const ValueKey('nav_search'));
      await tester.tap(navSearch);
      await tester.pumpAndSettle();

      // The search text field might be mobile or desktop
      final searchMobile = find.byKey(const ValueKey('search_textfield_mobile'));
      final searchDesktop = find.byKey(const ValueKey('search_textfield_desktop'));
      final searchField = searchMobile.evaluate().isNotEmpty ? searchMobile : searchDesktop;
      
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Help me plan my day at Magic Kingdom');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // 4. Park Explorer flow
      final navParks = find.byKey(const ValueKey('nav_parks'));
      await tester.tap(navParks);
      await tester.pumpAndSettle();

      // Find the park card for Magic Kingdom (p2)
      final parkCardBtn = find.byKey(const ValueKey('park_card_explorer_btn_p2'));
      // Scroll to it if it's in a scrollable list
      if (parkCardBtn.evaluate().isNotEmpty) {
        // It might be off-screen
        await tester.scrollUntilVisible(parkCardBtn, 200.0, scrollable: find.byType(Scrollable).first);
        await tester.tap(parkCardBtn);
        await tester.pumpAndSettle();
        
        // Tap a facility item (e.g. p2_f1)
        final facilityItem = find.byKey(const ValueKey('facility_list_item_p2_f1'));
        if (facilityItem.evaluate().isNotEmpty) {
           await tester.scrollUntilVisible(facilityItem, 200.0, scrollable: find.byType(Scrollable).first);
           await tester.tap(facilityItem);
           await tester.pumpAndSettle();

           // Navigate back
           final backButton = find.byTooltip('Back');
           if (backButton.evaluate().isNotEmpty) {
             await tester.tap(backButton);
             await tester.pumpAndSettle();
           }
        }
      }

      // 5. Favorites page flow
      final navFavorites = find.byKey(const ValueKey('nav_favorites'));
      await tester.tap(navFavorites);
      await tester.pumpAndSettle();
      
      // Verify we are on favorites page by looking for the "Favorites" text
      expect(find.text('Favorites'), findsWidgets);
    });
  });
}
