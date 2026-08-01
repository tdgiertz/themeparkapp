import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themeparkapp/core/permissions.dart';
import 'package:themeparkapp/features/onboarding/onboarding.dart';

class MockLocationPermissionNotifier extends LocationPermissionNotifier {
  MockLocationPermissionNotifier(LocationPermission? initial) {
    state = initial;
  }

  @override
  Future<LocationPermission> check() async =>
      state ?? LocationPermission.denied;
}

void main() {
  testWidgets(
    'C. OnboardingScreen - Core renders, Skip tap, Location validation',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            locationPermissionProvider.overrideWith(
              (ref) =>
                  MockLocationPermissionNotifier(LocationPermission.denied),
            ),
          ],
          child: const MaterialApp(home: OnboardingScreen()),
        ),
      );

      // Verify Title and Body Text
      expect(find.text('Enable location for in-park features'), findsOneWidget);
      expect(
        find.text(
          'We use your location to show nearby attractions, live wait times, and context-aware maps while you are in the park.',
        ),
        findsOneWidget,
      );

      // Verify Buttons
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Check initial state of the location tile
      expect(find.text('Location: denied'), findsOneWidget);

      // Tap Skip button
      await tester.tap(find.byKey(const ValueKey('onboarding_skip')));

      // Onboarding skip logic writes to SharedPreferences
      await tester.pumpAndSettle();
    },
  );
}
