import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:themeparkapp/core/permissions.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';
import 'package:themeparkapp/features/park/park_page.dart';
import 'package:themeparkapp/features/park/widgets/park_map.dart';
import 'package:themeparkapp/features/park/widgets/pulse_dot.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';


void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  // Setup simulated file loader
  Future<String> fileLoader(String path) async {
    return File(path).readAsString();
  }

  group('Park Explorer State Management', () {
    test('Selected filters state provider works', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filters = container.read(selectedFiltersProvider('p1'));
      expect(filters, isEmpty);

      container.read(selectedFiltersProvider('p1').notifier).state = {'thrill', 'dining'};
      expect(container.read(selectedFiltersProvider('p1')), equals({'thrill', 'dining'}));
    });

    test('Heatmap active state provider works', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(heatmapEnabledProvider('p1')), isFalse);
      container.read(heatmapEnabledProvider('p1').notifier).state = true;
      expect(container.read(heatmapEnabledProvider('p1')), isTrue);
    });
  });

  group('Park Explorer Page Layout & Widgets', () {
    testWidgets('ParkPage renders on Mobile with FAB and list default', (WidgetTester tester) async {
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
            locationPermissionProvider.overrideWith((ref) => MockLocationPermissionNotifier()),
            userLocationProvider('p1').overrideWith(MockUserLocationNotifier.new),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ParkPage(parkId: 'p1', parkName: 'Animal Kingdom'),
          ),
        ),
      );

      final context = tester.element(find.byType(ParkPage));
      final container = ProviderScope.containerOf(context);
      await tester.runAsync(() async {
        await container.read(parkDetailProvider('p1').notifier).refresh();
        await container.read(waitTimesProvider('p1').notifier).refresh();
      });
      await tester.pump();

      // Mobile mode toggle segment bar should render
      expect(find.text('Split'), findsOneWidget);
      expect(find.text('Full Map'), findsOneWidget);
      
      // Should render the mobile inline accordion attraction tiles
      expect(find.byType(InlineAccordionAttractionTile), findsWidgets);
      expect(find.byType(PulseDot), findsWidgets);
    });

    testWidgets('ParkPage renders on Tablet with split view, map, and collapsible side panel toggle', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            assetLoaderProvider.overrideWithValue(fileLoader),
            locationPermissionProvider.overrideWith((ref) => MockLocationPermissionNotifier()),
            userLocationProvider('p1').overrideWith(MockUserLocationNotifier.new),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ParkPage(parkId: 'p1', parkName: 'Animal Kingdom'),
          ),
        ),
      );

      final context = tester.element(find.byType(ParkPage));
      final container = ProviderScope.containerOf(context);
      await tester.runAsync(() async {
        await container.read(parkDetailProvider('p1').notifier).refresh();
        await container.read(waitTimesProvider('p1').notifier).refresh();
      });
      await tester.pump();

      // Map and inline accordion list tiles should be visible side-by-side
      expect(find.byType(ParkMapWidget), findsOneWidget);
      expect(find.byType(InlineAccordionAttractionTile), findsWidgets);
      
      // Mobile FAB should not render on tablet
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('ParkPage renders on Desktop with advanced checkbox sidebar and data grid', (WidgetTester tester) async {
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
            locationPermissionProvider.overrideWith((ref) => MockLocationPermissionNotifier()),
            userLocationProvider('p1').overrideWith(MockUserLocationNotifier.new),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ParkPage(parkId: 'p1', parkName: 'Animal Kingdom'),
          ),
        ),
      );

      final context = tester.element(find.byType(ParkPage));
      final container = ProviderScope.containerOf(context);
      await tester.runAsync(() async {
        await container.read(parkDetailProvider('p1').notifier).refresh();
        await container.read(waitTimesProvider('p1').notifier).refresh();
      });
      await tester.pump();

      // Map should be visible
      expect(find.byType(ParkMapWidget), findsOneWidget);

      // Advanced Filters checkbox sidebar should render
      expect(find.text('Advanced Filters'), findsOneWidget);
      expect(find.byType(Checkbox), findsAtLeastNWidgets(5));

      // Dense Desktop table rows should render
      expect(find.byType(DesktopAttractionRow), findsWidgets);
    });
  });
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest();
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse();
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 43;
  
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final bytes = [
      0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
      0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x21, 0xf9, 0x04, 0x01, 0x00,
      0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
      0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3b
    ];
    return Stream<List<int>>.fromIterable([bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class MockLocationPermissionNotifier extends LocationPermissionNotifier {
  MockLocationPermissionNotifier() : super();

  @override
  Future<LocationPermission> check() async {
    state = LocationPermission.denied;
    return LocationPermission.denied;
  }
}

class MockUserLocationNotifier extends UserLocationNotifier {
  MockUserLocationNotifier(Ref ref) : super(ref, 'p1');
}

