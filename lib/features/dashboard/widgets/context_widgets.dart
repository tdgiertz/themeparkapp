import 'dart:math';

import 'package:flutter/material.dart';

/// Widget displaying global crowd level as a gauge.
class CrowdIndexGauge extends StatelessWidget {
  const CrowdIndexGauge({
    required this.busynessScore, // 0-100
    super.key,
  });

  final int busynessScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resort Busyness',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '$busynessScore/100',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _getGaugeColor(context, busynessScore),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Gauge visualization using CustomPaint
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: _GaugePainter(
                score: busynessScore,
                primaryColor: _getGaugeColor(context, busynessScore),
                needleColor: Theme.of(context).colorScheme.onSurface,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          // Status label
          Center(
            child: Text(
              _getStatusLabel(busynessScore),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGaugeColor(BuildContext context, int score) {
    final cs = Theme.of(context).colorScheme;
    if (score < 30) return cs.primary;
    if (score < 60) return cs.tertiary;
    return cs.error;
  }

  String _getStatusLabel(int score) {
    if (score < 30) return 'Low crowding – Great day to visit!';
    if (score < 60) return 'Moderate crowding – Expected traffic';
    return 'High crowding – Plan for long waits';
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.score,
    required this.primaryColor,
    required this.needleColor,
  });

  final int score;
  final Color primaryColor;
  final Color needleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final startAngle = -3.14159; // -π (left side)
    final sweepAngle = 3.14159; // π (semicircle)

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = needleColor.withValues(alpha: 0.2)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.7,
    );

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);

    // Draw filled arc
    final fillPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillSweep = sweepAngle * (score / 100);
    canvas.drawArc(rect, startAngle, fillSweep, false, fillPaint);

    // Draw needle
    final needleAngle = startAngle + (sweepAngle * (score / 100));
    final centerX = size.width / 2;
    final centerY = size.height * 0.8;
    final needleLength = size.height * 0.3;

    final needleEnd = Offset(
      centerX + needleLength * cos(needleAngle),
      centerY + needleLength * sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(centerX, centerY), needleEnd, needlePaint);

    // Draw center dot
    final dotPaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), 4, dotPaint);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.primaryColor != primaryColor;
}

/// Widget displaying weather forecast relevant to park operations.
class WeatherWidget extends StatelessWidget {
  const WeatherWidget({
    required this.tempF,
    required this.condition, // 'Clear', 'Rainy', 'Cloudy', 'Stormy'
    required this.precipitationChance, // 0-100
    required this.windMph,
    super.key,
  });

  final int tempF;
  final String condition;
  final int precipitationChance;
  final int windMph;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hyper-Local Weather',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildWeatherIcon(context, condition),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$tempF°F – $condition',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$precipitationChance% chance of rain',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Wind: $windMph mph',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Weather impact warning
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: precipitationChance > 50
                  ? Theme.of(context).colorScheme.tertiaryContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  precipitationChance > 50 ? Icons.warning_amber_rounded : Icons.info_outline,
                  size: 18,
                  color: precipitationChance > 50
                      ? Theme.of(context).colorScheme.onTertiaryContainer
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    precipitationChance > 50
                        ? 'Clear skies until 3 PM, 80% chance of storms. Outdoor rides may close.'
                        : 'Favorable conditions across all parks today.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: precipitationChance > 50
                          ? Theme.of(context).colorScheme.onTertiaryContainer
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(BuildContext context, String condition) {
    IconData icon;
    Color color;
    final cs = Theme.of(context).colorScheme;

    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        icon = Icons.wb_sunny;
        color = cs.tertiary;
      case 'cloudy':
        icon = Icons.wb_cloudy;
        color = cs.onSurfaceVariant;
      case 'rainy':
      case 'rain':
        icon = Icons.water_drop;
        color = cs.primary;
      case 'stormy':
      case 'storm':
        icon = Icons.thunderstorm;
        color = cs.secondary;
      default:
        icon = Icons.wb_sunny;
        color = cs.tertiary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

/// Dynamic background gradient based on time of day and weather.
class DynamicBackgroundGradient extends StatelessWidget {
  const DynamicBackgroundGradient({
    required this.child,
    this.condition = 'Clear',
    super.key,
  });

  final Widget child;
  final String condition;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final gradient = _getGradientForTimeAndWeather(hour, condition);

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }

  LinearGradient _getGradientForTimeAndWeather(int hour, String condition) {
    if (condition.toLowerCase() == 'stormy' || condition.toLowerCase() == 'storm') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
      );
    }

    if (hour < 6) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
      ); // Deep night
    } else if (hour < 9) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF6b6b), Color(0xFFfeca57)],
      ); // Sunrise
    } else if (hour < 12) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF87CEEB), Color(0xFFE0F6FF)],
      ); // Morning
    } else if (hour < 17) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4a90e2), Color(0xFF87CEEB)],
      ); // Afternoon
    } else if (hour < 21) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF8c42), Color(0xFFB8232f)],
      ); // Sunset/Evening
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2c3e50), Color(0xFF1a1a2e)],
      ); // Night
    }
  }
}
