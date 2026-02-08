import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      background: AppColors.background,
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1F1A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6FE3B4),
      background: Color(0xFF0F1F1A),
    ),
  );
}
