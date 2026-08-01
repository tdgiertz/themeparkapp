import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _buildWeatherIcon(context, condition),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      '$tempF°F – $condition',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '• $precipitationChance% Rain',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  precipitationChance > 50
                      ? 'Storm warning: Outdoor rides may pause'
                      : 'Favorable park weather today',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: precipitationChance > 50
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
