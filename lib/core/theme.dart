import 'package:flutter/material.dart';

/// App-wide design tokens and Theme Definitions for Dark and Light modes.
class AppTheme {
  // Core Backgrounds & Surfaces
  static const Color appBackground = Color(0xFF0F111A); // Deep Slate/Navy
  static const Color cardSurface = Color(0xFF1E212B); // Elevated Slate
  static const Color offlineCardSurface = Color(0xFF191A23);
  static const Color offlineStripeColor = Color(0xFF272A35);

  // Text & Typography Colors
  static const Color primaryText = Color(0xFFF8FAFC); // Off-White (High Emphasis)
  static const Color secondaryText = Color(0xFF94A3B8); // Muted Blue-Grey (Medium Emphasis)

  // Accents & Data Visualization
  static const Color primaryAccent = Color(0xFF3B82F6); // Electric Blue
  static const Color chartAmber = Color(0xFFF59E0B); // Amber

  // Semantic Status Colors
  static const Color statusOpen = Color(0xFF10B981); // Emerald Green
  static const Color statusWarning = Color(0xFFF59E0B); // Amber
  static const Color statusCritical = Color(0xFFEF4444); // Rose Red

  /// Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: appBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        surface: cardSurface,
        onSurface: primaryText,
        onSurfaceVariant: secondaryText,
      ),
      cardTheme: const CardThemeData(
        color: cardSurface,
        elevation: 4,
        margin: EdgeInsets.all(4),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: primaryText),
        headlineMedium: TextStyle(color: primaryText),
        headlineSmall: TextStyle(color: primaryText),
        titleLarge: TextStyle(color: primaryText),
        titleMedium: TextStyle(color: primaryText),
        titleSmall: TextStyle(color: primaryText),
        bodyLarge: TextStyle(color: primaryText),
        bodyMedium: TextStyle(color: primaryText),
        bodySmall: TextStyle(color: secondaryText),
      ),
    );
  }

  /// Light Theme Definition
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: primaryAccent,
      ),
    );
  }
}
