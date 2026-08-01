import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Custom ThemeExtension for status and accent colors that adapt to themes.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.offlineCardSurface,
    required this.offlineStripeColor,
    required this.chartAmber,
    required this.statusOpen,
    required this.statusWarning,
    required this.statusCritical,
    required this.primaryAccent,
  });

  final Color offlineCardSurface;
  final Color offlineStripeColor;
  final Color chartAmber;
  final Color statusOpen;
  final Color statusWarning;
  final Color statusCritical;
  final Color primaryAccent;

  static const dark = StatusColors(
    offlineCardSurface: Color(0xFF191A23),
    offlineStripeColor: Color(0xFF272A35),
    chartAmber: Color(0xFFF59E0B),
    statusOpen: Color(0xFF10B981),
    statusWarning: Color(0xFFF59E0B),
    statusCritical: Color(0xFFEF4444),
    primaryAccent: Color(0xFF3B82F6),
  );

  static const light = StatusColors(
    offlineCardSurface: Color(0xFFF0F2F5),
    offlineStripeColor: Color(0xFFE2E8F0),
    chartAmber: Color(0xFFD97706),
    statusOpen: Color(0xFF059669),
    statusWarning: Color(0xFFD97706),
    statusCritical: Color(0xFFDC2626),
    primaryAccent: Color(0xFF2563EB),
  );

  @override
  StatusColors copyWith({
    Color? offlineCardSurface,
    Color? offlineStripeColor,
    Color? chartAmber,
    Color? statusOpen,
    Color? statusWarning,
    Color? statusCritical,
    Color? primaryAccent,
  }) {
    return StatusColors(
      offlineCardSurface: offlineCardSurface ?? this.offlineCardSurface,
      offlineStripeColor: offlineStripeColor ?? this.offlineStripeColor,
      chartAmber: chartAmber ?? this.chartAmber,
      statusOpen: statusOpen ?? this.statusOpen,
      statusWarning: statusWarning ?? this.statusWarning,
      statusCritical: statusCritical ?? this.statusCritical,
      primaryAccent: primaryAccent ?? this.primaryAccent,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) {
      return this;
    }
    return StatusColors(
      offlineCardSurface: Color.lerp(offlineCardSurface, other.offlineCardSurface, t)!,
      offlineStripeColor: Color.lerp(offlineStripeColor, other.offlineStripeColor, t)!,
      chartAmber: Color.lerp(chartAmber, other.chartAmber, t)!,
      statusOpen: Color.lerp(statusOpen, other.statusOpen, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusCritical: Color.lerp(statusCritical, other.statusCritical, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
    );
  }
}

/// App-wide design tokens and Theme Definitions for Dark and Light modes.
class AppTheme {
  // Backwards compatibility static constants
  static const Color offlineCardSurface = Color(0xFF191A23);
  static const Color offlineStripeColor = Color(0xFF272A35);
  static const Color chartAmber = Color(0xFFF59E0B);
  static const Color statusOpen = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusCritical = Color(0xFFEF4444);
  static const Color primaryAccent = Color(0xFF3B82F6);

  /// Dark Theme Definition
  static ThemeData darkTheme([Color? seedColor]) {
    return FlexThemeData.dark(
      colors: FlexSchemeColor.from(primary: seedColor ?? primaryAccent),
      keyColors: const FlexKeyColors(),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      subThemesData: const FlexSubThemesData(cardElevation: 4, cardRadius: 12),
    ).copyWith(
      extensions: <ThemeExtension<dynamic>>[
        StatusColors.dark,
      ],
    );
  }

  /// Light Theme Definition
  static ThemeData lightTheme([Color? seedColor]) {
    return FlexThemeData.light(
      colors: FlexSchemeColor.from(primary: seedColor ?? primaryAccent),
      keyColors: const FlexKeyColors(),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      subThemesData: const FlexSubThemesData(cardElevation: 4, cardRadius: 12),
    ).copyWith(
      extensions: <ThemeExtension<dynamic>>[
        StatusColors.light,
      ],
    );
  }
}
