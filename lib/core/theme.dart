import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// App-wide design tokens and Theme Definitions for Dark and Light modes.
class AppTheme {
  // Core Backgrounds & Surfaces (Keep for reference/flex config if needed, though replaced in usage)
  static const Color appBackground = Color(0xFF0F111A); // Deep Slate/Navy
  static const Color cardSurface = Color(0xFF1E212B); // Elevated Slate
  
  // Custom Semantic status colors
  static const Color offlineCardSurface = Color(0xFF191A23);
  static const Color offlineStripeColor = Color(0xFF272A35);
  static const Color chartAmber = Color(0xFFF59E0B); // Amber
  static const Color statusOpen = Color(0xFF10B981); // Emerald Green
  static const Color statusWarning = Color(0xFFF59E0B); // Amber
  static const Color statusCritical = Color(0xFFEF4444); // Rose Red
  
  // Custom accent color
  static const Color primaryAccent = Color(0xFF3B82F6); // Electric Blue

  /// Dark Theme Definition
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: primaryAccent,
        secondary: Color(0xFF60A5FA),
      ),
      scaffoldBackground: appBackground,
      surface: cardSurface,
      subThemesData: const FlexSubThemesData(
        cardElevation: 4,
        cardRadius: 12,
      ),
    );
  }

  /// Light Theme Definition
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.blue, // A clean, standard blue theme for light mode
      subThemesData: const FlexSubThemesData(
        cardElevation: 4,
        cardRadius: 12,
      ),
    );
  }
}
