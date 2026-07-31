import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/park/widgets/sparkline_chart.dart';
import 'package:themeparkapp/features/parks/parks_page.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  Future<String> fileLoader(String path) async {
    return File(path).readAsString();
  }

  group('ParksPage Responsive Layout Tests', () {
    testWidgets('ParksPage renders horizontal tab ribbon and 2/3 map + 1/3 wait times layout on Desktop/Tablet', (WidgetTester tester) async {
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
            home: ParksPage(),
          ),
        ),
      );

      final context = tester.element(find.byType(ParksPage));
      final container = ProviderScope.containerOf(context);
      await tester.runAsync(() async {
        await container.read(parksProvider.notifier).refresh();
        await container.read(parkDetailProvider('p1').notifier).refresh();
        await container.read(waitTimesProvider('p1').notifier).refresh();
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Top horizontal tab navigation ribbon should render
      expect(find.byType(ParkNavigationRibbon), findsOneWidget);

      // Desktop/Tablet dashboard pane should render
      expect(find.byType(DesktopParkDashboard), findsOneWidget);

      // Most Urgent Wait Times header should render in 1/3 column
      expect(find.text('Most Urgent Wait Times'), findsOneWidget);
      expect(find.text('TimescaleDB Aggregate'), findsOneWidget);
    });

    testWidgets('ParksPage renders single column ParkHeroCard grid on Mobile view unchanged', (WidgetTester tester) async {
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
            home: ParksPage(),
          ),
        ),
      );

      final context = tester.element(find.byType(ParksPage));
      final container = ProviderScope.containerOf(context);
      await tester.runAsync(() async {
        await container.read(parksProvider.notifier).refresh();
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Top navigation ribbon should NOT render on mobile
      expect(find.byType(ParkNavigationRibbon), findsNothing);

      // Mobile cards should render with sparkline chart and expand toggle
      expect(find.byType(ParkHeroCard), findsWidgets);
      expect(find.byType(SparklineChart), findsWidgets);
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
