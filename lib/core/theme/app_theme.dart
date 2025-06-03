import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme provides the theming for the MedStreak application
/// It defines color schemes, text styles, and other visual elements
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // Light theme colors - Higher contrast
  static const Color _primaryLight = Color(0xFF0040B0); // Deeper blue for better contrast
  static const Color _primaryLightVariant = Color(0xFF002D80); // Even deeper blue variant
  static const Color _secondaryLight = Color(0xFF00A86B); // Richer green
  static const Color _secondaryLightVariant = Color(0xFF007C4F); // Deeper green variant
  static const Color _backgroundLight = Color(0xFFF8F9FA); // Subtle off-white background
  static const Color _surfaceLight = Colors.white;
  static const Color _errorLight = Color(0xFFD50000); // Deeper red for better visibility
  static const Color _onPrimaryLight = Colors.white;
  static const Color _onSecondaryLight = Colors.white;
  static const Color _onBackgroundLight = Color(0xFF101010); // Near black for text
  static const Color _onSurfaceLight = Color(0xFF101010);
  static const Color _onErrorLight = Colors.white;

  // Dark theme colors - Higher contrast for better visibility
  static const Color _primaryDark = Color(0xFF2979FF); // Brighter blue that pops against dark backgrounds
  static const Color _primaryDarkVariant = Color(0xFF0B5BFF); // More vibrant blue variant
  static const Color _secondaryDark = Color(0xFF00E676); // Bright green that stands out
  static const Color _secondaryDarkVariant = Color(0xFF00C853); // Slightly darker green variant
  static const Color _backgroundDark = Color(0xFF121212); // Pure dark background
  static const Color _surfaceDark = Color(0xFF1E1E1E); // Slightly lighter for surfaces
  static const Color _errorDark = Color(0xFFFF5252); // Bright red for errors
  static const Color _onPrimaryDark = Colors.white;
  static const Color _onSecondaryDark = Colors.black; // Black on bright green for readability
  static const Color _onBackgroundDark = Colors.white;
  static const Color _onSurfaceDark = Colors.white;
  static const Color _onErrorDark = Colors.white;

  // Game-specific colors - Enhanced for better visibility and contrast
  static const Color lowValueColor = Color(0xFFE53935); // Deeper red for low values
  static const Color normalValueColor = Color(0xFF00C853); // Vibrant green for normal values
  static const Color highValueColor = Color(0xFFFF9800); // Brighter orange for high values
  
  // Gradient colors for backgrounds and cards
  static const List<Color> primaryGradient = [Color(0xFF0040B0), Color(0xFF2979FF)];
  static const List<Color> secondaryGradient = [Color(0xFF00A86B), Color(0xFF00E676)];
  static const List<Color> errorGradient = [Color(0xFFD50000), Color(0xFFFF5252)];
  static const List<Color> successGradient = [Color(0xFF007C4F), Color(0xFF00C853)];

  // Get the light theme
  static ThemeData lightTheme() {
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: _primaryLight,
      primaryContainer: _primaryLightVariant,
      secondary: _secondaryLight,
      secondaryContainer: _secondaryLightVariant,
      surface: _surfaceLight,
      error: _errorLight,
      onPrimary: _onPrimaryLight,
      onSecondary: _onSecondaryLight,
      onSurface: _onSurfaceLight,
      onError: _onErrorLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: _primaryLight,
      scaffoldBackgroundColor: _backgroundLight,
      // Enhanced AppBar with gradient effect
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryLight,
        foregroundColor: _onPrimaryLight,
        centerTitle: true,
        elevation: 4, // Add subtle elevation for depth
        shadowColor: _primaryLight.withOpacity(0.5), // Soft shadow
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      // Enhanced Card styling
      cardColor: _surfaceLight,
      // Material tap target size for better touch areas
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // Enhanced Button Themes with animations and better visual appeal
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          shadowColor: WidgetStateProperty.all<Color>(_primaryLight.withOpacity(0.5)),
          elevation: WidgetStateProperty.all<double>(4),
          animationDuration: const Duration(milliseconds: 200), // Faster animations
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
          elevation: 4, // More pronounced elevation
          shadowColor: _primaryLight.withOpacity(0.5), // Colored shadow
        ).copyWith(
          // Add animation for button press
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryLight,
          side: const BorderSide(color: _primaryLight, width: 2), // Thicker border
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ).copyWith(
          // Add animation for button press
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryLight,
          // Add subtle padding for better touch targets
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      // Enhanced text theme with better contrast and readability
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: TextStyle(color: _onBackgroundLight, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: _onBackgroundLight, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: _onBackgroundLight, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: _onBackgroundLight, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: _onBackgroundLight, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: _onBackgroundLight, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: _onBackgroundLight, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: _onBackgroundLight, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: _onBackgroundLight),
          bodyLarge: TextStyle(color: _onBackgroundLight),
          bodyMedium: TextStyle(color: _onBackgroundLight),
          bodySmall: TextStyle(color: _onBackgroundLight.withOpacity(0.8)),
          labelLarge: TextStyle(color: _onBackgroundLight, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: _onBackgroundLight),
          labelSmall: TextStyle(color: _onBackgroundLight.withOpacity(0.8)),
        ),
      ),
      // Enhanced input decoration for better user experience
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
        // Add subtle drop shadow for depth
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        // Label styling
        labelStyle: TextStyle(color: _primaryLight),
        // Hint styling
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      // Enhanced icon theme
      iconTheme: IconThemeData(
        color: _primaryLight,
        size: 24,
        opacity: 0.9,
      ),
      // Better divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 16,
      ),
      // Add snackbar theming for better visual feedback
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceLight,
        contentTextStyle: TextStyle(color: _onSurfaceLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
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
      surface: _surfaceDark,
      error: _errorDark,
      onPrimary: _onPrimaryDark,
      onSecondary: _onSecondaryDark,
      onSurface: _onSurfaceDark,
      onError: _onErrorDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: _primaryDark,
      scaffoldBackgroundColor: _backgroundDark,
      // Enhanced AppBar with gradient effect
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryDark,
        foregroundColor: _onPrimaryDark,
        centerTitle: true,
        elevation: 4, // Add subtle elevation for depth
        shadowColor: _primaryDark.withOpacity(0.5), // Soft shadow
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      // Enhanced Card styling
      cardColor: _surfaceDark,
      // Material tap target size for better touch areas
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // Enhanced Button Themes with animations and better visual appeal
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          shadowColor: WidgetStateProperty.all<Color>(_primaryDark.withOpacity(0.5)),
          elevation: WidgetStateProperty.all<double>(4),
          animationDuration: const Duration(milliseconds: 200), // Faster animations
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
          elevation: 4, // More pronounced elevation
          shadowColor: _primaryDark.withOpacity(0.5), // Colored shadow
        ).copyWith(
          // Add animation for button press
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryDark,
          side: const BorderSide(color: _primaryDark, width: 2), // Thicker border
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ).copyWith(
          // Add animation for button press
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryDark,
          // Add subtle padding for better touch targets
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      // Enhanced text theme with better contrast and readability
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: TextStyle(color: _onBackgroundDark, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: _onBackgroundDark, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: _onBackgroundDark, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: _onBackgroundDark, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: _onBackgroundDark, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: _onBackgroundDark, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: _onBackgroundDark, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: _onBackgroundDark, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: _onBackgroundDark),
          bodyLarge: TextStyle(color: _onBackgroundDark),
          bodyMedium: TextStyle(color: _onBackgroundDark),
          bodySmall: TextStyle(color: _onBackgroundDark.withOpacity(0.8)),
          labelLarge: TextStyle(color: _onBackgroundDark, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: _onBackgroundDark),
          labelSmall: TextStyle(color: _onBackgroundDark.withOpacity(0.8)),
        ),
      ),
      // Enhanced input decoration for better user experience
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A), // Slightly lighter than background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        // Add subtle drop shadow for depth
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        // Label styling
        labelStyle: const TextStyle(color: _primaryDark),
        // Hint styling
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      // Enhanced icon theme
      iconTheme: const IconThemeData(
        color: _primaryDark,
        size: 24,
        opacity: 0.9,
      ),
      // Better divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[800],
        thickness: 1,
        space: 16,
      ),
      // Add snackbar theming for better visual feedback
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2A2A2A),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
