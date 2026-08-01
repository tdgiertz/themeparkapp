import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/core/theme.dart';
import 'package:themeparkapp/features/park/widgets/area_chart.dart';

void main() {
  group('AreaChartWidget Golden & Unit Tests', () {
    Widget buildTestWidget(Widget child, {ThemeData? theme}) {
      return MaterialApp(
        theme: theme ?? AppTheme.lightTheme(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Container(
              color: (theme ?? AppTheme.lightTheme()).colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('AreaChartWidget renders empty state message when data is empty', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AreaChartWidget(
            data: [],
            lineColor: Colors.blue,
          ),
        ),
      );

      expect(find.text('No historical data available'), findsOneWidget);
    });

    testWidgets('AreaChartWidget Golden Test - Light Theme with wait time trend data', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 320,
            height: 160,
            child: AreaChartWidget(
              data: [15, 25, 45, 30, 60, 50, 40],
              lineColor: Colors.orange,
            ),
          ),
          theme: AppTheme.lightTheme(),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AreaChartWidget),
        matchesGoldenFile('goldens/area_chart_light.png'),
      );
    });

    testWidgets('AreaChartWidget Golden Test - Dark Theme with low wait time data', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 320,
            height: 160,
            child: AreaChartWidget(
              data: [5, 10, 15, 10, 5, 20, 15],
              lineColor: Colors.green,
            ),
          ),
          theme: AppTheme.darkTheme(),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(AreaChartWidget),
        matchesGoldenFile('goldens/area_chart_dark.png'),
      );
    });
  });
}
