import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/providers.dart';
import 'package:themeparkapp/features/dashboard/dashboard.dart';
import 'package:themeparkapp/features/dashboard/widgets/context_widgets.dart';
import 'package:themeparkapp/l10n/app_localizations.dart';

class ErrorParksNotifier extends ParksNotifier {
  ErrorParksNotifier(super.ref) {
    state = const AsyncValue.error('Failed to load parks', StackTrace.empty);
  }
}

void main() {
  testWidgets('Dashboard tablet/desktop layout handles error states cleanly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          parksProvider.overrideWith(ErrorParksNotifier.new),
          favoritesProvider.overrideWith(
            (ref) => Future.error('Failed to load favorites', StackTrace.empty),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Dashboard()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Dashboard), findsOneWidget);
    expect(find.byType(WeatherWidget), findsOneWidget);
  });
}
