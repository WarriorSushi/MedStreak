import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme provides the theming for the MedStreak application
/// It defines color schemes, text styles, and other visual elements
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // Light theme colors
  static const Color _primaryLight = Color(0xFF0A6CFF);
  static const Color _primaryLightVariant = Color(0xFF0054CC);
  static const Color _secondaryLight = Color(0xFF3DD598);
  static const Color _secondaryLightVariant = Color(0xFF2BBB7F);
  static const Color _backgroundLight = Color(0xFFF5F7FA);
  static const Color _surfaceLight = Colors.white;
  static const Color _errorLight = Color(0xFFFF4C4C);
  static const Color _onPrimaryLight = Colors.white;
  static const Color _onSecondaryLight = Colors.white;
  static const Color _onBackgroundLight = Color(0xFF1A1A1A);
  static const Color _onSurfaceLight = Color(0xFF1A1A1A);
  static const Color _onErrorLight = Colors.white;

  // Dark theme colors
  static const Color _primaryDark = Color(0xFF2196F3);
  static const Color _primaryDarkVariant = Color(0xFF0D47A1);
  static const Color _secondaryDark = Color(0xFF4CAF50);
  static const Color _secondaryDarkVariant = Color(0xFF388E3C);
  static const Color _backgroundDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _errorDark = Color(0xFFCF6679);
  static const Color _onPrimaryDark = Colors.white;
  static const Color _onSecondaryDark = Colors.white;
  static const Color _onBackgroundDark = Colors.white;
  static const Color _onSurfaceDark = Colors.white;
  static const Color _onErrorDark = Colors.black;

  // Game-specific colors
  static const Color lowValueColor = Color(0xFFFF4C4C);  // Red for low values
  static const Color normalValueColor = Color(0xFF3DD598); // Green for normal values
  static const Color highValueColor = Color(0xFFFFB74D);  // Orange for high values

  // Get the light theme
  static ThemeData lightTheme() {
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: _primaryLight,
      primaryContainer: _primaryLightVariant,
      secondary: _secondaryLight,
      secondaryContainer: _secondaryLightVariant,
      background: _backgroundLight,
      surface: _surfaceLight,
      error: _errorLight,
      onPrimary: _onPrimaryLight,
      onSecondary: _onSecondaryLight,
      onBackground: _onBackgroundLight,
      onSurface: _onSurfaceLight,
      onError: _onErrorLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: _primaryLight,
      scaffoldBackgroundColor: _backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryLight,
        foregroundColor: _onPrimaryLight,
        centerTitle: true,
        elevation: 0,
      ),
      // Card styling - using Material 3 compatible properties
      cardColor: _surfaceLight,
      // Using filledButtonTheme to style cards via their containers
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: _onPrimaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryLight,
          side: const BorderSide(color: _primaryLight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryLight,
        ),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.light().textTheme,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryLight),
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primaryLight,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 0.5,
      ),
    );
  }

  // Get the dark theme
  static ThemeData darkTheme() {
    final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
      primary: _primaryDark,
      primaryContainer: _primaryDarkVariant,
      secondary: _secondaryDark,
      secondaryContainer: _secondaryDarkVariant,
      background: _backgroundDark,
      surface: _surfaceDark,
      error: _errorDark,
      onPrimary: _onPrimaryDark,
      onSecondary: _onSecondaryDark,
      onBackground: _onBackgroundDark,
      onSurface: _onSurfaceDark,
      onError: _onErrorDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: _primaryDark,
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryDark,
        foregroundColor: _onPrimaryDark,
        centerTitle: true,
        elevation: 0,
      ),
      // Card styling - using Material 3 compatible properties
      cardColor: _surfaceDark,
      // Using filledButtonTheme to style cards via their containers
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: _onPrimaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryDark,
          side: const BorderSide(color: _primaryDark),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryDark,
        ),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryDark),
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primaryDark,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 0.5,
      ),
    );
  }
}
