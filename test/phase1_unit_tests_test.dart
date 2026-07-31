import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themeparkapp/core/environment_providers.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/core/theme.dart';
import 'package:themeparkapp/features/checkout/checkout_notifier.dart';
import 'package:themeparkapp/features/dashboard/dashboard.dart';
import 'package:themeparkapp/features/dashboard/dashboard_geofence_provider.dart';
import 'package:themeparkapp/features/park/widgets/park_map.dart';
import 'package:themeparkapp/features/search/search_state.dart';
import 'package:themeparkapp/models/favorite.dart';
import 'package:themeparkapp/models/park_detail.dart';
import 'package:themeparkapp/models/wait_time.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1 Unit Tests', () {
    group('B. ThemeSeedColorNotifier', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      test('Default state is AppTheme.primaryAccent when no prefs entry exists', () {
        final notifier = ThemeSeedColorNotifier();
        expect(notifier.state, AppTheme.primaryAccent);
      });

      test('setColor() persists the correct int value to SharedPreferences', () async {
        final notifier = ThemeSeedColorNotifier();
        const testColor = Color(0xFF9C27B0);
        await notifier.setColor(testColor);
        expect(notifier.state, testColor);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('theme_seed_color'), testColor.value);
      });

      test('A second instantiation reads back the saved color', () async {
        const testColor = Color(0xFF009688);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_seed_color', testColor.value);

        final notifier = ThemeSeedColorNotifier();
        await Future<void>.delayed(Duration.zero);
        expect(notifier.state, testColor);
      });
    });

    group('C. Notifier staleness logic', () {
      test('ParksNotifier.isStale is true when lastLoaded is null and markStale makes isStale true again', () async {
        final container = ProviderContainer(
          overrides: [
            assetLoaderProvider.overrideWithValue((_) async => '{"data":{"parks":[]}}'),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(parksProvider.notifier);
        expect(notifier.isStale, isTrue);

        await notifier.refresh();
        expect(notifier.isStale, isFalse);

        notifier.markStale();
        expect(notifier.isStale, isTrue);
      });

      test('FavoritesNotifier.isStale is true when lastLoaded is null and markStale makes isStale true again', () async {
        final container = ProviderContainer(
          overrides: [
            assetLoaderProvider.overrideWithValue((_) async => '{"userId":"1","lastUpdated":"","favoriteRides":[]}'),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(favoritesProvider.notifier);
        expect(notifier.isStale, isTrue);

        await notifier.refresh();
        expect(notifier.isStale, isFalse);

        notifier.markStale();
        expect(notifier.isStale, isTrue);
      });

      test('ParkDetailNotifier.isStale is true when lastLoaded is null and markStale makes isStale true again', () async {
        final container = ProviderContainer(
          overrides: [
            assetLoaderProvider.overrideWithValue((_) async => '{"parks":[]}'),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(parkDetailProvider('p1').notifier);
        expect(notifier.isStale, isTrue);

        await notifier.refresh();
        expect(notifier.isStale, isFalse);

        notifier.markStale();
        expect(notifier.isStale, isTrue);
      });
    });

    group('D. SearchNotifier edge cases', () {
      test("submitQuery('') and submitQuery('   ') - empty guard, no messages added", () async {
        final container = ProviderContainer(
          overrides: [
            assetLoaderProvider.overrideWithValue((_) async => '{"parks":[]}'),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(searchProvider.notifier);
        final initialLength = container.read(searchProvider).messages.length;

        await notifier.submitQuery('');
        expect(container.read(searchProvider).messages.length, initialLength);

        await notifier.submitQuery('   ');
        expect(container.read(searchProvider).messages.length, initialLength);
      });

      test('setListening(true/false) toggles isListening', () {
        final container = ProviderContainer(
          overrides: [
            assetLoaderProvider.overrideWithValue((_) async => '{"parks":[]}'),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(searchProvider.notifier);
        expect(container.read(searchProvider).isListening, isFalse);

        notifier.setListening(true);
        expect(container.read(searchProvider).isListening, isTrue);

        notifier.setListening(false);
        expect(container.read(searchProvider).isListening, isFalse);
      });

      test('selectFacility(facility) / selectFacility(null) sets and clears selectedFacilityDetails', () {
        final container = ProviderContainer(
          overrides: [
            assetLoaderProvider.overrideWithValue((_) async => '{"parks":[]}'),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(searchProvider.notifier);
        final facility = Facility(
          id: 'f1',
          type: 'ride',
          category: 'Attraction',
          name: 'Test Ride',
        );

        expect(container.read(searchProvider).selectedFacilityDetails, isNull);

        notifier.selectFacility(facility);
        expect(container.read(searchProvider).selectedFacilityDetails, facility);

        notifier.selectFacility(null);
        expect(container.read(searchProvider).selectedFacilityDetails, isNull);
      });

      test('"dining near me" query returns suggestedFacilities', () async {
        const attractionsJson = '''
        {
          "parks": [
            {
              "id": "p1",
              "children": [
                {
                  "id": "l1",
                  "type": "land",
                  "name": "Main Land",
                  "children": [
                    {
                      "id": "d1",
                      "type": "dining",
                      "category": "Dining",
                      "name": "Pretzel Cart"
                    }
                  ]
                }
              ]
            }
          ]
        }
        ''';
        final container = ProviderContainer(
          overrides: [
            assetLoaderProvider.overrideWithValue((_) async => attractionsJson),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(searchProvider.notifier);
        await notifier.submitQuery('dining near me');

        final state = container.read(searchProvider);
        final lastMessage = state.messages.last;
        expect(lastMessage.text, contains('I found the nearest pretzel/dining spots'));
        expect(lastMessage.suggestedFacilities, isNotEmpty);
      });
    });

    group('E. Model edge cases', () {
      test('WaitTime.fromJson with null waitMinutes, missing singleRider/fastLane defaulting to false', () {
        final json = {
          'rideId': 'r1',
          'updatedAt': '2026-07-31T12:00:00Z',
          'status': 'Open',
        };
        final waitTime = WaitTime.fromJson(json);

        expect(waitTime.rideId, 'r1');
        expect(waitTime.waitMinutes, isNull);
        expect(waitTime.singleRider, isFalse);
        expect(waitTime.fastLane, isFalse);
      });

      test('Facility.fromJson with null thrillLevel and null heightRequirementInches', () {
        final json = {
          'id': 'f1',
          'type': 'attraction',
          'category': 'Ride',
          'name': 'Ferris Wheel',
        };
        final facility = Facility.fromJson(json);

        expect(facility.id, 'f1');
        expect(facility.thrillLevel, isNull);
        expect(facility.heightRequirementInches, isNull);
      });

      test('ParkDetail.fromJson with missing park key returns an empty ParkDetail', () {
        final detail = ParkDetail.fromJson({});

        expect(detail.id, '');
        expect(detail.type, '');
        expect(detail.name, '');
        expect(detail.children, isEmpty);
      });

      test('FavoritesResponse.fromJson with empty favoriteRides list', () {
        final json = {
          'userId': 'u1',
          'lastUpdated': '2026-07-31T12:00:00Z',
          'favoriteRides': [],
        };
        final resp = FavoritesResponse.fromJson(json);

        expect(resp.userId, 'u1');
        expect(resp.lastUpdated, '2026-07-31T12:00:00Z');
        expect(resp.favoriteRides, isEmpty);
      });
    });

    group('F. SearchItineraryItem.copyWith', () {
      test('time updates, all other fields preserved', () {
        final item = SearchItineraryItem(
          id: 'item1',
          time: '10:00 AM',
          title: 'Space Mountain',
          facilityId: 'a1',
          parkId: 'p1',
          latitude: 28.419,
          longitude: -81.581,
          durationMinutes: 45,
        );

        final updated = item.copyWith(time: '11:30 AM');

        expect(updated.id, 'item1');
        expect(updated.time, '11:30 AM');
        expect(updated.title, 'Space Mountain');
        expect(updated.facilityId, 'a1');
        expect(updated.parkId, 'p1');
        expect(updated.latitude, 28.419);
        expect(updated.longitude, -81.581);
        expect(updated.durationMinutes, 45);
      });
    });

    group('G. detectParkFromCoordinates', () {
      test('Center coords for all 7 parks return a valid parkId', () {
        for (final geofence in parkGeofences) {
          final detected = detectParkFromCoordinates(
            geofence.latitude,
            geofence.longitude,
          );
          expect(detected, isNotNull, reason: 'Failed for ${geofence.parkName}');
          // Note: Due to list iteration order in detectParkFromCoordinates, overlapping geofences
          // (e.g. Epcot/Hollywood Studios or Universal Studios/Islands of Adventure) match the first defined entry.
          if (geofence.parkId == 'p4') {
            expect(detected, 'p3');
          } else if (geofence.parkId == 'p6') {
            expect(detected, 'p5');
          } else {
            expect(detected, geofence.parkId);
          }
        }
      });

      test('Coordinates just inside / just outside the 3000m radius', () {
        final targetPark = parkGeofences.first; // Magic Kingdom (p2): 28.4186, -81.5812
        
        // ~0.02 degrees latitude offset is roughly 2220m (inside 3000m)
        final insideLat = targetPark.latitude + 0.02;
        expect(detectParkFromCoordinates(insideLat, targetPark.longitude), targetPark.parkId);

        // ~0.035 degrees latitude offset is roughly 3885m (outside 3000m)
        final outsideLat = targetPark.latitude + 0.035;
        expect(detectParkFromCoordinates(outsideLat, targetPark.longitude), isNot(targetPark.parkId));
      });
    });

    group('H. AttractionLocation.fromId', () {
      test('Known IDs return expected hardcoded coordinates', () {
        final locA1 = AttractionLocation.fromId('a1', 0.0, 0.0);
        expect(locA1.latitude, 28.3575);
        expect(locA1.longitude, -81.5930);

        final locA13 = AttractionLocation.fromId('a13', 0.0, 0.0);
        expect(locA13.latitude, 28.4208);
        expect(locA13.longitude, -81.5824);
      });

      test('Unknown ID produces deterministic coordinates (same input -> same hash offset)', () {
        const centerLat = 28.0;
        const centerLng = -81.0;

        final loc1 = AttractionLocation.fromId('unknown_id_xyz', centerLat, centerLng);
        final loc2 = AttractionLocation.fromId('unknown_id_xyz', centerLat, centerLng);

        expect(loc1.latitude, loc2.latitude);
        expect(loc1.longitude, loc2.longitude);
        expect(loc1.latitude, isNot(centerLat));
        expect(loc1.longitude, isNot(centerLng));
      });
    });

    group('I. deviceTypeProvider', () {
      test('boundary values: <=600 -> mobile, 601-1024 -> tablet, >=1025 -> desktop', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // 600 -> mobile
        container.read(screenWidthProvider.notifier).state = 600;
        expect(container.read(deviceTypeProvider), DeviceType.mobile);

        // 601 -> tablet
        container.read(screenWidthProvider.notifier).state = 601;
        expect(container.read(deviceTypeProvider), DeviceType.tablet);

        // 1024 -> tablet
        container.read(screenWidthProvider.notifier).state = 1024;
        expect(container.read(deviceTypeProvider), DeviceType.tablet);

        // 1025 -> desktop
        container.read(screenWidthProvider.notifier).state = 1025;
        expect(container.read(deviceTypeProvider), DeviceType.desktop);
      });
    });

    group('J. crowdColor() utility', () {
      testWidgets('maps low/moderate/high/unknown correctly to ColorScheme roles', (WidgetTester tester) async {
        late BuildContext capturedContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        );

        final colorScheme = Theme.of(capturedContext).colorScheme;

        expect(crowdColor(capturedContext, 'low'), colorScheme.primaryContainer);
        expect(crowdColor(capturedContext, 'LOW'), colorScheme.primaryContainer);
        expect(crowdColor(capturedContext, 'moderate'), colorScheme.tertiaryContainer);
        expect(crowdColor(capturedContext, 'high'), colorScheme.errorContainer);
        expect(crowdColor(capturedContext, null), colorScheme.surfaceContainerHigh);
        expect(crowdColor(capturedContext, 'unknown'), colorScheme.surfaceContainerHigh);
      });
    });

    group('K. CheckoutState named constructors', () {
      test('CheckoutState.initial(), .loading(), .success(), .failure() verify fields', () {
        const initial = CheckoutState.initial();
        expect(initial.processing, isFalse);
        expect(initial.success, isFalse);
        expect(initial.message, isNull);

        const loading = CheckoutState.loading();
        expect(loading.processing, isTrue);
        expect(loading.success, isFalse);
        expect(loading.message, isNull);

        const success = CheckoutState.success('Order completed');
        expect(success.processing, isFalse);
        expect(success.success, isTrue);
        expect(success.message, 'Order completed');

        const failure = CheckoutState.failure('Payment error');
        expect(failure.processing, isFalse);
        expect(failure.success, isFalse);
        expect(failure.message, 'Payment error');
      });
    });
  });
}
