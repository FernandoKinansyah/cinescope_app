import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const cardBg     = Color(0xFF1A1A1A);
  static const navbarBg   = Color(0xFF111111);
  static const accent     = Color(0xFFE50914);
  static const accentDark = Color(0xFFB8070F);
  static const textGray   = Color(0xFF999999);
  static const textLight  = Color(0xFFCCCCCC);
  static const star       = Color(0xFFFFC107);
  static const likeRed    = Color(0xFFFF4D6D);
  static const commentBlue= Color(0xFF99AADD);
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.cardBg,
      ),
    );
  }
}