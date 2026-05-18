import 'package:flutter/material.dart';

class AppColors {
  static const background   = Color(0xFF0A0E1A);
  static const surface      = Color(0xFF111827);
  static const surfaceLight = Color(0xFF1C2539);
  static const teal         = Color(0xFF00C9A7);
  static const tealDark     = Color(0xFF00957B);
  static const tealGlow     = Color(0x2200C9A7);
  static const pink         = Color(0xFFFF6B9D);
  static const textPrimary  = Color(0xFFEDF2FF);
  static const textSecondary= Color(0xFF8892AA);
  static const textMuted    = Color(0xFF3D4A63);
  static const divider      = Color(0xFF1E2A40);
  static const error        = Color(0xFFFF5370);
  static const success      = Color(0xFF00C9A7);
  static const warning      = Color(0xFFFFB347);
  static const cardShadow   = Color(0x55000000);

  static const priorityHigh   = Color(0xFFFF5370);
  static const priorityMedium = Color(0xFFFFB347);
  static const priorityLow    = Color(0xFF00C9A7);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.teal,
    fontFamily: 'Nunito',
    colorScheme: const ColorScheme.dark(
      background: AppColors.background,
      surface: AppColors.surface,
      primary: AppColors.teal,
      secondary: AppColors.pink,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) =>
        states.contains(MaterialState.selected) ? AppColors.teal : Colors.transparent),
      side: const BorderSide(color: AppColors.textMuted, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
  );
}
