import 'package:flutter/material.dart';
import 'dart:math';

/// Widget displaying global crowd level as a gauge.
class CrowdIndexGauge extends StatelessWidget {
  const CrowdIndexGauge({
    required this.busynessScore, // 0-100
    super.key,
  });

  final int busynessScore;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.blue.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resort Busyness',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$busynessScore/100',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _getGaugeColor(busynessScore),
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
                primaryColor: _getGaugeColor(busynessScore),
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
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGaugeColor(int score) {
    if (score < 30) return Colors.green;
    if (score < 60) return Colors.orange;
    return Colors.red;
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
  });

  final int score;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -3.14159; // -π (left side)
    const sweepAngle = 3.14159; // π (semicircle)

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
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
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(centerX, centerY), needleEnd, needlePaint);

    // Draw center dot
    final dotPaint = Paint()
      ..color = Colors.black87
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.amber.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hyper-Local Weather',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildWeatherIcon(condition),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$tempF°F – $condition',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${precipitationChance}% chance of rain',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Wind: ${windMph} mph',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
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
                  ? Colors.orange.withOpacity(0.12)
                  : Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: precipitationChance > 50
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  precipitationChance > 50 ? Icons.warning_amber_rounded : Icons.info_outline,
                  size: 18,
                  color: precipitationChance > 50 ? Colors.orange.shade800 : Colors.blue.shade700,
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
                      color: precipitationChance > 50 ? Colors.orange.shade900 : Colors.blue.shade900,
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

  Widget _buildWeatherIcon(String condition) {
    IconData icon;
    Color color;

    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        icon = Icons.wb_sunny;
        color = Colors.amber;
      case 'cloudy':
        icon = Icons.wb_cloudy;
        color = Colors.grey;
      case 'rainy':
      case 'rain':
        icon = Icons.water_drop;
        color = Colors.blue;
      case 'stormy':
      case 'storm':
        icon = Icons.thunderstorm;
        color = Colors.indigo;
      default:
        icon = Icons.wb_sunny;
        color = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
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
