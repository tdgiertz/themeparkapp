import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/models/park_detail.dart';
import 'package:themeparkapp/core/models/wait_time.dart';
import 'package:themeparkapp/core/theme.dart';
import 'package:themeparkapp/features/park/widgets/area_chart.dart';
import 'package:themeparkapp/features/park/widgets/facility_detail_sheet.dart';

void main() {
  group('FacilityDetailSheetContent Widget Tests', () {
    final mockRideFacility = Facility(
      id: 'ride_1',
      type: 'attraction',
      name: 'Space Roller Coaster',
      category: 'Attraction',
      thrillLevel: 'High',
      heightRequirementInches: 44,
    );

    final mockDiningFacility = Facility(
      id: 'dining_1',
      type: 'restaurant',
      name: 'Galactic Cafe & Grill',
      category: 'Dining',
    );

    final mockOpenWait = WaitTime(
      rideId: 'ride_1',
      updatedAt: '2026-07-31T20:00:00Z',
      waitMinutes: 45,
      status: WaitTimeStatus.open,
    );

    final mockClosedWait = WaitTime(
      rideId: 'ride_1',
      updatedAt: '2026-07-31T20:00:00Z',
      waitMinutes: 0,
      status: WaitTimeStatus.closed,
    );

    Widget buildTestSheet({
      required Facility facility,
      WaitTime? wait,
      VoidCallback? onClose,
    }) {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          home: Scaffold(
            body: FacilityDetailSheetContent(
              facility: facility,
              wait: wait,
              parkId: 'park_1',
              onClose: onClose,
            ),
          ),
        ),
      );
    }

    testWidgets(
      'Renders ride facility details, wait time, height requirement, and area chart',
      (tester) async {
        await tester.pumpWidget(
          buildTestSheet(facility: mockRideFacility, wait: mockOpenWait),
        );

        expect(find.text('Space Roller Coaster'), findsOneWidget);
        expect(find.text('Attraction'), findsOneWidget);
        expect(find.text('Thrill: High'), findsOneWidget);
        expect(find.text('Min Height: 44"'), findsOneWidget);
        expect(find.text('Wait Time: 45m'), findsOneWidget);
        expect(find.text('Virtual Queue'), findsOneWidget);
        expect(find.text('Historical Wait Times'), findsOneWidget);
        expect(find.byType(AreaChartWidget), findsOneWidget);
      },
    );

    testWidgets(
      'Renders closed state for ride facility when wait is closed or null',
      (tester) async {
        await tester.pumpWidget(
          buildTestSheet(facility: mockRideFacility, wait: mockClosedWait),
        );

        expect(find.text('Closed'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Join Virtual Queue changes state to joining then joined',
      (tester) async {
        await tester.pumpWidget(
          buildTestSheet(facility: mockRideFacility, wait: mockOpenWait),
        );

        final joinButton = find.text('Join Virtual Queue');
        expect(joinButton, findsOneWidget);

        await tester.tap(joinButton);
        await tester.pump(); // Triggers setState for _isJoiningQueue = true

        expect(find.text('Joining...'), findsOneWidget);

        // Advance time by 1500ms to complete simulated network delay
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pump();

        expect(find.textContaining('Assigned: Group'), findsOneWidget);
        expect(find.textContaining('Estimated Return:'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders dining facility, menu categories, items, and handles dietary filter toggling',
      (tester) async {
        await tester.pumpWidget(buildTestSheet(facility: mockDiningFacility));

        expect(find.text('Galactic Cafe & Grill'), findsOneWidget);
        expect(find.text('Dining Menu'), findsOneWidget);

        // Verify category headers and sample menu items
        expect(find.text('Entrees'), findsOneWidget);
        expect(find.text('Grizzly Giant Burger'), findsOneWidget);
        expect(find.text('Wilderness Salad'), findsOneWidget);

        // Tap 'Vegan' filter chip
        final veganChip = find.widgetWithText(FilterChip, 'Vegan');
        expect(veganChip, findsOneWidget);

        await tester.tap(veganChip);
        await tester.pump();

        // Grizzly Giant Burger should be filtered out (non-vegan)
        expect(find.text('Grizzly Giant Burger'), findsNothing);
        // Wilderness Salad & Vegan Quinoa Bowl should still be present
        expect(find.text('Wilderness Salad'), findsOneWidget);
        expect(find.text('Vegan Quinoa Bowl'), findsOneWidget);
      },
    );

    testWidgets('Tapping close button triggers onClose callback', (
      tester,
    ) async {
      var closed = false;
      await tester.pumpWidget(
        buildTestSheet(
          facility: mockRideFacility,
          wait: mockOpenWait,
          onClose: () {
            closed = true;
          },
        ),
      );

      final closeBtn = find.byIcon(Icons.close);
      expect(closeBtn, findsOneWidget);

      await tester.tap(closeBtn);
      await tester.pump();

      expect(closed, isTrue);
    });
  });
}
