import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that draws a beautiful detailed area chart of wait times over the last 3 hours.
class AreaChartWidget extends StatelessWidget {
  const AreaChartWidget({
    required this.data,
    required this.lineColor,
    this.height = 150.0,
    super.key,
  });

  final List<int> data;
  final Color lineColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No historical data available',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(28, 8, 12, 20), // Leave room for axes labels
      child: CustomPaint(
        painter: _AreaChartPainter(
          data: data,
          lineColor: lineColor,
          theme: Theme.of(context),
        ),
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({
    required this.data,
    required this.lineColor,
    required this.theme,
  });

  final List<int> data;
  final Color lineColor;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface.withOpacity(isDark ? 0.7 : 0.7);
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    // Determine the Y scale
    final dataMax = data.reduce(math.max);
    final maxVal = math.max(60.0, (((dataMax + 19) ~/ 20) * 20).toDouble());

    // Draw horizontal grid lines and Y-axis labels
    final gridPaint = Paint()
      ..color = theme.colorScheme.onSurface.withOpacity(isDark ? 0.08 : 0.06)
      ..strokeWidth = 1.0;

    const gridLinesCount = 3;
    for (var i = 0; i <= gridLinesCount; i++) {
      final yVal = (maxVal / gridLinesCount) * i;
      final y = size.height - (yVal / maxVal) * size.height;
      
      // Draw line
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(text: '${yVal.toInt()}m', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(-28, y - textPainter.height / 2));
    }

    if (data.length < 2) return;

    final widthStep = size.width / (data.length - 1);
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final x = i * widthStep;
      final ratio = data[i] / maxVal;
      final y = size.height - (ratio * size.height);
      points.add(Offset(x, y));
    }

    // Paint the filled gradient area under the line
    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      final pPrev = points[i - 1];
      final pCurr = points[i];
      final cp1 = Offset(pPrev.dx + widthStep / 2, pPrev.dy);
      final cp2 = Offset(pCurr.dx - widthStep / 2, pCurr.dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pCurr.dx, pCurr.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.3),
          lineColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Paint the stroke line
    final strokePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final pPrev = points[i - 1];
      final pCurr = points[i];
      final cp1 = Offset(pPrev.dx + widthStep / 2, pPrev.dy);
      final cp2 = Offset(pCurr.dx - widthStep / 2, pCurr.dy);
      strokePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pCurr.dx, pCurr.dy);
    }

    final strokePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(strokePath, strokePaint);

    // Paint data points and labels on the X-axis
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    final dotBorderPaint = Paint()
      ..color = isDark ? const Color(0xFF1E281F) : Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 4.0, dotPaint);
      canvas.drawCircle(points[i], 4.0, dotBorderPaint);

      // X-axis labels
      if (i == 0 || i == (points.length - 1) ~/ 2 || i == points.length - 1) {
        String label = '';
        if (i == 0) {
          label = '3h ago';
        } else if (i == points.length - 1) {
          label = 'Now';
        } else {
          label = '1.5h';
        }

        final xTextPainter = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        
        double xOffset = points[i].dx - xTextPainter.width / 2;
        if (i == 0) xOffset = 0;
        if (i == points.length - 1) xOffset = size.width - xTextPainter.width;

        xTextPainter.paint(canvas, Offset(xOffset, size.height + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.theme != theme;
  }
}
