import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary synthwave colors
  static const Color darkBackground = Color(0xFF0B0B1A);
  static const Color surfaceColor = Color(0xFF1A1A2E);
  static const Color neonPink = Color(0xFFFF2E97);
  static const Color neonBlue = Color(0xFF2DE2E6);
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color retroOrange = Color(0xFFFF9E64);
  static const Color synthYellow = Color(0xFFFFD93D);
  static const Color lightBackground = Color(0xFF2A2A3E);

  // Additional semantic colors
  static const Color error = Color(0xFFFF2E97);
  static const Color success = Color(0xFF2DE2E6);
  static const Color warning = Color(0xFFFFD93D);
}

/// App theme configuration
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  static final ThemeData lightTheme = _createTheme(true);
  static final ThemeData darkTheme = _createTheme(false);

  static ThemeData _createTheme(bool isLight) {
    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      colorScheme: ColorScheme(
        brightness: isLight ? Brightness.light : Brightness.dark,
        primary: AppColors.neonPink,
        secondary: AppColors.neonBlue,
        tertiary: AppColors.neonPurple,
        surface: AppColors.surfaceColor,
        background: AppColors.darkBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.neonPink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.neonPink,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.neonBlue.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: AppColors.neonPink,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 18,
          letterSpacing: 1,
        ),
        bodyLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
        bodyMedium: TextStyle(color: Colors.white.withOpacity(0.8)),
      ),
      iconTheme: IconThemeData(
        color: AppColors.neonBlue,
        size: 28,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceColor.withOpacity(0.3),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.neonPink),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.neonBlue.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.neonPink, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: AppColors.neonPink.withOpacity(0.5),
        ),
      ),
    );
  }
}
