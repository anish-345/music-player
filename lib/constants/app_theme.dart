import 'package:flutter/material.dart';

class AppTheme {
  // App Gradient Colors - Matching Icon
  static const Color darkNavy = Color(0xFF1C1E2E);
  static const Color slateBlue = Color(0xFF2D3142);
  static const Color deepSlate = Color(0xFF3A3D52);
  static const Color darkPurple = Color(0xFF2E2440);
  static const Color richPurple = Color(0xFF3D2E4F);

  // Main App Gradient (matching the icon background)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkNavy,
      slateBlue,
      deepSlate,
      darkPurple,
      richPurple,
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // Icon Gradient (for smaller elements)
  static const LinearGradient iconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      slateBlue,
      deepSlate,
      darkPurple,
    ],
  );

  // Background Colors
  static const Color backgroundColor = Color(0xFF0D0E14);
  static const Color surfaceColor = Color(0xFF1A1C28);

  // Text Colors
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFB0B0B0);

  // 3D Shadow Effects
  static List<BoxShadow> get card3DShadow => [
        BoxShadow(
          color: richPurple.withValues(alpha: 0.3),
          blurRadius: 15,
          spreadRadius: 1,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: darkNavy.withValues(alpha: 0.5),
          blurRadius: 8,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevated3DShadow => [
        BoxShadow(
          color: richPurple.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.6),
          blurRadius: 10,
          spreadRadius: -3,
          offset: const Offset(0, 5),
        ),
      ];

  static List<BoxShadow> get button3DShadow => [
        BoxShadow(
          color: deepSlate.withValues(alpha: 0.5),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 6,
          spreadRadius: -2,
          offset: const Offset(0, 3),
        ),
      ];

  static BoxShadow primaryShadow = BoxShadow(
    color: darkNavy.withValues(alpha: 0.4),
    blurRadius: 12,
    spreadRadius: 2,
    offset: const Offset(0, 4),
  );

  // Border Radius
  static const double cardRadius = 12.0;
  static const double iconRadius = 8.0;

  // 3D Highlight overlay
  static BoxDecoration get card3DDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: card3DShadow,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      );

  static BoxDecoration get popup3DDecoration => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            slateBlue,
            darkNavy,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: elevated3DShadow,
        border: Border.all(
          color: deepSlate.withValues(alpha: 0.3),
          width: 1.5,
        ),
      );
}
