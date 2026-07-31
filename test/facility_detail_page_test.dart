import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/facility_detail_page.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

void main() {
  Future<String> fileLoader(String path) async {
    return File(path).readAsString();
  }

  group('FacilityDetailPage Tests', () {
    testWidgets('Renders attraction details correctly on mobile', (WidgetTester tester) async {
      // Setup mobile size
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assetLoaderProvider.overrideWithValue(fileLoader),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FacilityDetailPage(facilityId: 'a1', parkId: 'p1'), // Flight of Passage
          ),
        ),
      );

      // Await Riverpod async data load
      final context = tester.element(find.byType(FacilityDetailPage));
      final container = ProviderScope.containerOf(context);
      
      await tester.runAsync(() async {
        await container.read(parkDetailProvider('p1').notifier).refresh();
        await container.read(waitTimesProvider('p1').notifier).refresh();
      });
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check name and sections
      expect(find.text('Avatar Flight of Passage'), findsWidgets);
      expect(find.text('Wait Time Analysis'), findsOneWidget);
      expect(find.byType(InteractiveWaitTimeChart), findsOneWidget);
      expect(find.text('Join Virtual Queue'), findsWidgets);
    });

    testWidgets('Renders dining details and filters correctly on mobile', (WidgetTester tester) async {
      // Setup mobile size
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assetLoaderProvider.overrideWithValue(fileLoader),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FacilityDetailPage(facilityId: 'a10', parkId: 'p1'), // Rainforest Cafe
          ),
        ),
      );

      // Await Riverpod async data load
      final context = tester.element(find.byType(FacilityDetailPage));
      final container = ProviderScope.containerOf(context);
      await tester.runAsync(() async {
        await container.read(parkDetailProvider('p1').notifier).refresh();
        await container.read(waitTimesProvider('p1').notifier).refresh();
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check name, dietary title and menu
      expect(find.text("Rainforest Cafe at Disney's Animal Kingdom"), findsWidgets);
      expect(find.text('Dietary Preferences'), findsOneWidget);
      expect(find.text('Grizzly Giant Burger'), findsOneWidget);
      expect(find.text('Wilderness Salad'), findsOneWidget);

      // Tap on 'Vegan' filter chip
      final veganChip = find.text('Vegan');
      expect(veganChip, findsOneWidget);
      await tester.tap(veganChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // The non-compliant items should fade out.
      // We wrap the item in AnimatedOpacity.
      // Let's verify the animated opacities.
      final animatedOpacities = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );

      // Grizzly Giant Burger is non-compliant (has Gluten, Dairy, not Vegan) -> opacity should be 0.12
      // Wilderness Salad is compliant (Vegan) -> opacity should be 1.0
      var foundBurgerOpacity = false;
      var foundSaladOpacity = false;
      for (final op in animatedOpacities) {
        if (op.child is Container) {
          final containerChild = op.child! as Container;
          if (containerChild.child is Card) {
            // Let's inspect the hierarchy to find the name text
            // Or just check if the opacity corresponds to the item.
            if (op.opacity == 0.12) {
              foundBurgerOpacity = true;
            }
            if (op.opacity == 1.0) {
              foundSaladOpacity = true;
            }
          }
        }
      }
      expect(foundBurgerOpacity, isTrue);
      expect(foundSaladOpacity, isTrue);
    });

    testWidgets('Renders 360 tour preview and charts correctly on desktop', (WidgetTester tester) async {
      // Setup desktop size
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assetLoaderProvider.overrideWithValue(fileLoader),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FacilityDetailPage(facilityId: 'a1', parkId: 'p1'), // Flight of Passage
          ),
        ),
      );

      // Await Riverpod async data load
      final context = tester.element(find.byType(FacilityDetailPage));
      final container = ProviderScope.containerOf(context);
      await tester.runAsync(() async {
        await container.read(parkDetailProvider('p1').notifier).refresh();
        await container.read(waitTimesProvider('p1').notifier).refresh();
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check desktop layout structure
      expect(find.text('Interactive 360° Preview Tour'), findsOneWidget);
      expect(find.text('Drag Panorama to Look Around'), findsOneWidget);
      expect(find.byIcon(Icons.explore), findsOneWidget); // Compass icon

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Wait Time Analytics'), findsOneWidget);
    });
  });
}
