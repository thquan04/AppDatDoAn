// lib/theme/app_theme.dart
// Toàn bộ màu sắc, font, style dùng chung cho app

import 'package:flutter/material.dart';

// ──────────────────────────────────────────
// MÀU SẮC
// ──────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary      = Color(0xFFFF6B00);
  static const Color primaryLight = Color(0xFFFF8C3A);
  static const Color primaryDark  = Color(0xFFE05A00);

  static const Color background   = Color(0xFFF5F5F5);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color surface      = Color(0xFFFFFFFF);

  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF888888);
  static const Color border        = Color(0xFFEFEFEF);

  static const Color success = Color(0xFF2ECC71);
  static const Color error   = Color(0xFFFF3B3B);
  static const Color star    = Color(0xFFF4A62A);
}

// ──────────────────────────────────────────
// TEXT STYLES
// ──────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle price = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  static const TextStyle priceOld = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700,
    color: AppColors.white, letterSpacing: 0.5,
  );
}

// ──────────────────────────────────────────
// THEME DATA
// ──────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      background: AppColors.background,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto', // Thay bằng 'BeVietnamPro' nếu thêm font
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTextStyles.heading3,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: AppTextStyles.button,
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}
