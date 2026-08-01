import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:themeparkapp/features/park/widgets/sparkline_chart.dart';

void main() {
  testWidgets('SparklineChart renders and paints', (WidgetTester tester) async {
    final data = [10, 20, 15, 30, 25];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SparklineChart(data: data, lineColor: Colors.red),
        ),
      ),
    );

    // Verify it finds the CustomPaint widget descendant inside SparklineChart
    expect(
      find.descendant(
        of: find.byType(SparklineChart),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('SparklineChart renders empty box when data is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SparklineChart(data: [])),
      ),
    );

    // Should find a SizedBox instead of CustomPaint descendant
    expect(
      find.descendant(
        of: find.byType(SparklineChart),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
  });
}
