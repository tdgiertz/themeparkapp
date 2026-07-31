import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:themeparkapp/core/theme.dart';
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
    final isPiratesCard = widget.favorite.rideId.toLowerCase().contains('pirates') ||
        widget.favorite.name.toLowerCase().contains('pirates');

    return GestureDetector(
      onHorizontalDragStart: (details) {
        // Store starting position for future gesture enhancements
      },
      onHorizontalDragEnd: (details) {
        final dx = details.velocity.pixelsPerSecond.dx;
        final dragThreshold = 500.0;

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
        color: isClosed ? Theme.of(context).colorScheme.surfaceContainerLow : Theme.of(context).colorScheme.surfaceContainer,
        child: Container(
          decoration: BoxDecoration(
            color: isClosed ? Theme.of(context).colorScheme.surfaceContainerLow : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Diagonal striping pattern for closed/offline rides
              if (isClosed)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiagonalStripensPainter(
                      stripeColor: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktopOrTablet = getValueForScreenType<bool>(
                      context: context,
                      mobile: false,
                      tablet: true,
                      desktop: true,
                    );

                    final isDining = widget.favorite.rideId.toLowerCase().contains('restaurant') ||
                        widget.favorite.rideId.toLowerCase().contains('dining') ||
                        widget.favorite.name.toLowerCase().contains('cafe') ||
                        widget.favorite.name.toLowerCase().contains('grill');

                    final swipeRightAction = isDining ? 'View Menu' : 'Join Queue';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          widget.favorite.parkName,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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

                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (isClosed
                                        ? Theme.of(context).colorScheme.errorContainer
                                        : Theme.of(context).colorScheme.primaryContainer),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isClosed
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: Text(
                                isClosed ? 'OFFLINE' : status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: isClosed
                                      ? Theme.of(context).colorScheme.onErrorContainer
                                      : Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Wait time display or Offline announcement
                        if (!isClosed) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$waitMinutes',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'min wait',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Flexible(
                                child: Text(
                                  'Avg: ${(waitMinutes * 1.15).round()} min',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Sparkline chart showing historical area comparison
                          if (constraints.maxHeight.isFinite)
                            Expanded(
                              child: LayoutBuilder(
                                builder: (ctx, innerConstraints) {
                                  final height = innerConstraints.maxHeight.isFinite && innerConstraints.maxHeight > 0
                                      ? innerConstraints.maxHeight
                                      : 48.0;
                                  return SizedBox(
                                    height: height,
                                    width: double.infinity,
                                    child: _buildSparkline(ctx, isPiratesCard),
                                  );
                                },
                              ),
                            )
                          else
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: _buildSparkline(context, isPiratesCard),
                            ),
                        ] else ...[
                          // Closed state: container with #0F111A at 60% opacity for high readability against stripes
                          if (constraints.maxHeight.isFinite)
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.60),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pause_circle_outline,
                                      color: Theme.of(context).colorScheme.tertiary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Temporarily closed for maintenance. Check back soon.',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.60),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.statusWarning.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.pause_circle_outline,
                                    color: AppTheme.statusWarning,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Temporarily closed for maintenance. Check back soon.',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],

                        // Footer actions: Swipe hints on Mobile, clean action buttons on Desktop/Tablet
                        const SizedBox(height: 6),
                        if (!isDesktopOrTablet)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 10,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        'Swipe Right: $swipeRightAction',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Swipe Left: Map',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                    Icons.arrow_back_ios,
                                    size: 10,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: widget.onSwipeRight,
                                  icon: Icon(
                                    isDining ? Icons.restaurant_menu : Icons.queue,
                                    size: 13,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  label: Text(
                                    swipeRightAction,
                                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    side: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton.icon(
                                  onPressed: widget.onSwipeLeft,
                                  icon: Icon(Icons.directions_walk, size: 13, color: Theme.of(context).colorScheme.onPrimary),
                                  label: Text(
                                    'Map',
                                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildSparkline(BuildContext context, bool isPiratesCard) {
    // Mock historical data showing wait times over time
    final mockData = [5, 12, 15, 18, 22, 25, 28, 26, 24, 22, 20, 18];
    final currentWait = widget.favorite.currentWait?['waitMinutes'] as int? ?? 0;

    return CustomPaint(
      painter: _SparklinePainter(
        data: mockData,
        currentValue: currentWait,
        lineColor: isPiratesCard ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
        isPiratesGradient: isPiratesCard,
      ),
      size: Size.infinite,
    );
  }
}

/// Custom painter for diagonal stripes pattern on offline cards.
class _DiagonalStripensPainter extends CustomPainter {
  _DiagonalStripensPainter({this.stripeColor});

  final Color? stripeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor ?? const Color(0xFF272A35)
      ..strokeWidth = 3;

    final spacing = 12.0;
    for (var i = -size.height; i < size.width; i += spacing) {
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
    this.isPiratesGradient = false,
  });

  final List<int> data;
  final int currentValue;
  final Color lineColor;
  final bool isPiratesGradient;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = (data.reduce((a, b) => a > b ? a : b) * 1.2).toInt();
    if (maxValue == 0) return;

    final pointSpacing = size.width / (data.length - 1);
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final y = size.height - (data[i] / maxValue) * size.height;
      points.add(Offset(x, y));
    }

    // Path for line and fill
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(linePath);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(points.first.dx, size.height);
    fillPath.close();

    // Draw filled area gradient
    final fillShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.3),
        lineColor.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPaint = Paint()
      ..shader = fillShader
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw solid line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);

    // Draw current value marker
    final currentPoint = points.last;
    final markerPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentPoint, 4, markerPaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.currentValue != currentValue ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.isPiratesGradient != isPiratesGradient;
}

