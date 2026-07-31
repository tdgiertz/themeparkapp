import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/features/dashboard/dashboard.dart';
import 'package:themeparkapp/features/dashboard/widgets/upcoming_shows_widget.dart';
import 'package:themeparkapp/models/favorite.dart';

void main() {
  testWidgets('UpcomingShowsWidget renders upcoming shows correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: UpcomingShowsWidget(),
          ),
        ),
      ),
    );

    expect(find.text('Upcoming Shows & Entertainment'), findsOneWidget);
    expect(find.text('Festival of Fantasy Parade'), findsOneWidget);
    expect(find.text('Luminous: The Symphony of Us'), findsOneWidget);
  });

  testWidgets('Dashboard renders park selector, compact weather, upcoming shows and favorites', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Dashboard(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('All Parks'), findsOneWidget);
    expect(find.text('Upcoming Shows & Entertainment'), findsOneWidget);
    expect(find.text('Favorites Matrix'), findsOneWidget);
  });
}
