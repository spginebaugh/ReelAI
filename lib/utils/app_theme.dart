import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  static const Color darkBackground = Color(0xFF222831);
  static const Color surfaceColor = Color(0xFF393E46);
  static const Color primary = Color(0xFF00ADB5);
  static const Color lightBackground = Color(0xFFEEEEEE);

  // Additional semantic colors
  static const Color error = Colors.redAccent;
  static const Color success = Colors.greenAccent;
  static const Color warning = Colors.orangeAccent;
}

/// App theme configuration
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surfaceColor,
      background: AppColors.lightBackground,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.lightBackground,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceColor,
      elevation: 2,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: AppColors.darkBackground),
      titleMedium: TextStyle(color: AppColors.darkBackground),
      bodyLarge: TextStyle(color: AppColors.darkBackground),
      bodyMedium: TextStyle(color: AppColors.darkBackground),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceColor.withOpacity(0.1),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.surfaceColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  /// Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surfaceColor,
      background: AppColors.darkBackground,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceColor,
      foregroundColor: AppColors.lightBackground,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceColor,
      elevation: 2,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: AppColors.lightBackground),
      titleMedium: TextStyle(color: AppColors.lightBackground),
      bodyLarge: TextStyle(color: AppColors.lightBackground),
      bodyMedium: TextStyle(color: AppColors.lightBackground),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceColor.withOpacity(0.1),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.surfaceColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
