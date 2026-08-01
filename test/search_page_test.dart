import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:themeparkapp/core/models/park_detail.dart';
import 'package:themeparkapp/core/permissions.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/park_explorer_state.dart';
import 'package:themeparkapp/features/search/search_page.dart';
import 'package:themeparkapp/features/search/search_state.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  Future<String> fileLoader(String path) async {
    return File(path).readAsString();
  }

  group('SearchPage Responsive Layout Tests', () {
    testWidgets('SearchPage renders mobile layout elements correctly', (
      WidgetTester tester,
    ) async {
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
            locationPermissionProvider.overrideWith(
              (ref) => MockLocationPermissionNotifier(),
            ),
            userLocationProvider(
              'p2',
            ).overrideWith(MockUserLocationNotifier.new),
          ],
          child: const MaterialApp(home: SearchPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Mobile TextField present
      expect(
        find.byKey(const ValueKey('search_textfield_mobile')),
        findsOneWidget,
      );
      // Verify initial welcome message text in bubble
      expect(
        find.textContaining('Welcome! I am your AI travel agent assistant.'),
        findsOneWidget,
      );
      // Verify live location indicator bar
      expect(find.textContaining('Live Location:'), findsOneWidget);
      // Verify Mic gesture button
      expect(find.byIcon(Icons.mic), findsWidgets);
    });

    testWidgets('SearchPage renders 3-pane desktop layout correctly', (
      WidgetTester tester,
    ) async {
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
            locationPermissionProvider.overrideWith(
              (ref) => MockLocationPermissionNotifier(),
            ),
            userLocationProvider(
              'p2',
            ).overrideWith(MockUserLocationNotifier.new),
          ],
          child: const MaterialApp(home: SearchPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Desktop TextField present
      expect(
        find.byKey(const ValueKey('search_textfield_desktop')),
        findsOneWidget,
      );
      // Header for chat thread pane
      expect(find.text('Chat History & Thread'), findsOneWidget);
      // Active Interactive Widget Pane default welcome text
      expect(find.text('Active Interactive Widget Panel'), findsOneWidget);
      // Vector map CustomPaint pane
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('SearchPage User Gestures & State Updates', () {
    testWidgets(
      'Submitting text query via send button adds user and agent messages',
      (WidgetTester tester) async {
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
              locationPermissionProvider.overrideWith(
                (ref) => MockLocationPermissionNotifier(),
              ),
              userLocationProvider(
                'p2',
              ).overrideWith(MockUserLocationNotifier.new),
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final input = find.byKey(const ValueKey('search_textfield_mobile'));
        await tester.enterText(input, 'Where is the nearest pretzel?');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));

        // Check query text rendered
        expect(find.text('Where is the nearest pretzel?'), findsOneWidget);
        // Check response rendered pretzel options
        expect(find.textContaining('pretzel'), findsWidgets);
        // Suggested facility card rendered
        expect(find.text('View'), findsWidgets);
      },
    );

    testWidgets(
      'Tapping voice input mic button displays voice dictation overlay and cancel button',
      (WidgetTester tester) async {
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
              locationPermissionProvider.overrideWith(
                (ref) => MockLocationPermissionNotifier(),
              ),
              userLocationProvider(
                'p2',
              ).overrideWith(MockUserLocationNotifier.new),
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Tap mic icon container
        final micFinder = find.byIcon(Icons.mic).first;
        await tester.tap(micFinder);
        await tester.pump();

        // Voice overlay overlay title present
        expect(find.text('AI TRAVEL AGENT DICTATION'), findsOneWidget);
        expect(find.text('Listening...'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Tap Cancel button on overlay
        await tester.tap(find.text('Cancel'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Overlay dismissed
        expect(find.text('AI TRAVEL AGENT DICTATION'), findsNothing);
      },
    );

    testWidgets(
      'Selecting facility on Desktop populates Pane 2 with restaurant menu and dietary chips',
      (WidgetTester tester) async {
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
              locationPermissionProvider.overrideWith(
                (ref) => MockLocationPermissionNotifier(),
              ),
              userLocationProvider(
                'p2',
              ).overrideWith(MockUserLocationNotifier.new),
            ],
            child: const MaterialApp(home: SearchPage()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Select facility details for active interactive widget pane
        final context = tester.element(find.byType(SearchPage));
        final container = ProviderScope.containerOf(context);
        final sampleFacility = Facility(
          id: 'pretzel_1',
          type: 'Facility',
          category: 'Dining',
          name: 'Fantasyland Pretzel Oasis',
          thrillLevel: 'Low',
          heightRequirementInches: 0,
        );
        container.read(searchProvider.notifier).selectFacility(sampleFacility);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Pane 2 now displays restaurant details and dietary chips
        expect(find.text('Dietary Restrictions Filter:'), findsOneWidget);
        expect(find.text('Grizzly Giant Burger'), findsOneWidget);
        expect(find.text('Wilderness Salad'), findsOneWidget);

        // Tap 'Vegan' dietary filter ChoiceChip
        final veganChip = find.widgetWithText(ChoiceChip, 'Vegan');
        await tester.tap(veganChip);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Grizzly Giant Burger (non-vegan) is filtered out
        expect(find.text('Grizzly Giant Burger'), findsNothing);
        expect(find.text('Wilderness Salad'), findsOneWidget);

        // Close button clears selected facility
        final closeButton = find.byIcon(Icons.close);
        await tester.tap(closeButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Active Interactive Widget Panel'), findsOneWidget);
      },
    );

    testWidgets('AppBar clear button resets conversation state', (
      WidgetTester tester,
    ) async {
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
            locationPermissionProvider.overrideWith(
              (ref) => MockLocationPermissionNotifier(),
            ),
            userLocationProvider(
              'p2',
            ).overrideWith(MockUserLocationNotifier.new),
          ],
          child: const MaterialApp(home: SearchPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Enter query
      final input = find.byKey(const ValueKey('search_textfield_mobile'));
      await tester.enterText(input, 'Suggest dining near me');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Suggest dining near me'), findsOneWidget);

      // Tap delete sweep icon in AppBar
      await tester.tap(find.byIcon(Icons.delete_sweep));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Query cleared, restored to initial welcome state
      expect(find.text('Suggest dining near me'), findsNothing);
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
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final bytes = [
      0x47,
      0x49,
      0x46,
      0x38,
      0x39,
      0x61,
      0x01,
      0x00,
      0x01,
      0x00,
      0x80,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0xff,
      0xff,
      0xff,
      0x21,
      0xf9,
      0x04,
      0x01,
      0x00,
      0x00,
      0x00,
      0x00,
      0x2c,
      0x00,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x01,
      0x00,
      0x00,
      0x02,
      0x02,
      0x44,
      0x01,
      0x00,
      0x3b,
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
  MockUserLocationNotifier(Ref ref) : super(ref, 'p2');
}
