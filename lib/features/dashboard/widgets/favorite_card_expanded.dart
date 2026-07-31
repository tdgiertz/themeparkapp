import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/models/favorite.dart';

/// Enhanced favorite card with sparkline chart and swipe actions.
class ExpandedFavoriteCard extends StatefulWidget {
  const ExpandedFavoriteCard({
    required this.favorite,
    this.onSwipeLeft,
    this.onSwipeRight,
    super.key,
  });

  final FavoriteRide favorite;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  @override
  State<ExpandedFavoriteCard> createState() => _ExpandedFavoriteCardState();
}

class _ExpandedFavoriteCardState extends State<ExpandedFavoriteCard> {
  @override
  Widget build(BuildContext context) {
    final waitMinutes = widget.favorite.currentWait?['waitMinutes'] as int? ?? 0;
    final status = widget.favorite.currentWait?['status'] as String? ?? 'Unknown';
    final isClosed = status != 'Open';

    return GestureDetector(
      onHorizontalDragStart: (details) {
        // Store starting position for future gesture enhancements
      },
      onHorizontalDragEnd: (details) {
        final dx = details.velocity.pixelsPerSecond.dx;
        const dragThreshold = 500.0;

        if (dx < -dragThreshold && widget.onSwipeLeft != null) {
          widget.onSwipeLeft!();
        } else if (dx > dragThreshold && widget.onSwipeRight != null) {
          widget.onSwipeRight!();
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isClosed
                  ? [Colors.grey.shade400, Colors.grey.shade600]
                  : _getGradientColors(waitMinutes),
            ),
          ),
          child: Stack(
            children: [
              // Diagonal striping pattern for closed/offline rides
              if (isClosed)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: CustomPaint(
                      painter: _DiagonalStripensPainter(),
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showSwipeText = getValueForScreenType<bool>(
                      context: context,
                      mobile: true,
                      tablet: false,
                      desktop: false,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Header: Name + Park side-by-side comparison tag
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.favorite.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 13,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          widget.favorite.parkName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isClosed
                                    ? Colors.black38
                                    : Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                isClosed ? 'OFFLINE' : status.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Wait time display
                        if (!isClosed) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$waitMinutes',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'min wait',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Avg: ${(waitMinutes * 1.15).round()} min',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Sparkline chart showing historical area comparison
                          // Use Expanded so the chart respects the parent constraints
                          Expanded(
                            child: LayoutBuilder(
                              builder: (ctx, innerConstraints) {
                                final height = innerConstraints.maxHeight.isFinite && innerConstraints.maxHeight > 0
                                    ? innerConstraints.maxHeight
                                    : 54.0;
                                return SizedBox(
                                  height: height,
                                  width: double.infinity,
                                  child: _buildSparkline(ctx),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          // Closed state: stronger semi-transparent background for readability
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.pause_circle_outline, color: Colors.white70, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Temporarily closed for maintenance. Check back soon.',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Swipe action hints
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (showSwipeText)
                              Row(
                                children: [
                                  Icon(Icons.queue, size: 12, color: Colors.white.withOpacity(0.7)),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Swipe Right: Join Queue',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              )
                            else
                              const SizedBox.shrink(),

                            Row(
                              children: [
                                Text(
                                  'Swipe Left: Map',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.75),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(Icons.directions_walk, size: 12, color: Colors.white.withOpacity(0.7)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSparkline(BuildContext context) {
    // Mock historical data showing wait times over time
    final mockData = [5, 12, 15, 18, 22, 25, 28, 26, 24, 22, 20, 18];
    final currentWait = widget.favorite.currentWait?['waitMinutes'] as int? ?? 0;

    return CustomPaint(
      painter: _SparklinePainter(
        data: mockData,
        currentValue: currentWait,
        lineColor: Colors.white.withOpacity(0.8),
        fillColor: Colors.white.withOpacity(0.2),
      ),
      size: Size.infinite,
    );
  }

  List<Color> _getGradientColors(int waitMinutes) {
    if (waitMinutes <= 20) {
      return [Colors.green.shade600, Colors.green.shade400];
    } else if (waitMinutes <= 45) {
      return [Colors.orange.shade600, Colors.orange.shade400];
    } else {
      return [Colors.red.shade600, Colors.red.shade400];
    }
  }
}

/// Custom painter for diagonal stripes pattern.
class _DiagonalStripensPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    const spacing = 10.0;
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DiagonalStripensPainter oldDelegate) => false;
}

/// Custom painter for inline sparkline chart.
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.currentValue,
    required this.lineColor,
    required this.fillColor,
  });

  final List<int> data;
  final int currentValue;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = (data.reduce((a, b) => a > b ? a : b) * 1.2).toInt();
    if (maxValue == 0) return;

    final pointSpacing = size.width / (data.length - 1);
    final List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final y = size.height - (data[i] / maxValue) * size.height;
      points.add(Offset(x, y));
    }

    // Draw filled area
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(points.first.dx, size.height);
    for (final point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw current value marker
    final currentPoint = points.last;
    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentPoint, 4, markerPaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.currentValue != currentValue;
}
