import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette - Industrial Dark
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceVariant = Color(0xFF0F3460);

  // Brand Colors
  static const Color primary = Color(0xFFF0A500);
  static const Color primaryLight = Color(0xFFFFBF00);
  static const Color primaryDark = Color(0xFFCC8800);

  // Semantic Colors
  static const Color success = Color(0xFF00C853);
  static const Color successDark = Color(0xFF009624);
  static const Color error = Color(0xFFFF3D00);
  static const Color errorDark = Color(0xFFDD2C00);
  static const Color warning = Color(0xFFFFAB00);
  static const Color info = Color(0xFF2979FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint = Color(0xFF607D8B);
  static const Color textDisabled = Color(0xFF455A64);

  // Scanner UI
  static const Color scannerOverlay = Color(0x99000000);
  static const Color scannerBorder = Color(0xFFF0A500);
  static const Color scannerBorderSuccess = Color(0xFF00C853);
  static const Color scannerBorderError = Color(0xFFFF3D00);

  // Status Chip Colors
  static const Color chipPending = Color(0xFFFFAB00);
  static const Color chipSynced = Color(0xFF00C853);
  static const Color chipFailed = Color(0xFFFF3D00);

  // Divider
  static const Color divider = Color(0xFF263238);

  // Card Gradient
  static const List<Color> cardGradient = [
    Color(0xFF16213E),
    Color(0xFF0F3460),
  ];
}
