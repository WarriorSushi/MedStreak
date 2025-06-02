import 'package:flutter/material.dart';

/// Application color palette used throughout the app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation
  
  // Primary colors
  static const Color primary = Color(0xFF0A6CFF);
  static const Color primaryVariant = Color(0xFF0054CC);
  
  // Secondary colors
  static const Color secondary = Color(0xFF3DD598);
  static const Color secondaryVariant = Color(0xFF2BBB7F);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Surface colors
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Error colors
  static const Color error = Color(0xFFFF4C4C);
  static const Color errorDark = Color(0xFFCF6679);
  
  // Text colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Colors.white;
  
  // Medical value classification colors
  static const Color lowValue = Color(0xFFFF4C4C);     // Red for low values
  static const Color normalValue = Color(0xFF3DD598);  // Green for normal values
  static const Color highValue = Color(0xFFFFB74D);    // Orange for high values
  
  // Achievement colors
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF0A6CFF),
    Color(0xFF0054CC),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF3DD598),
    Color(0xFF2BBB7F),
  ];
  
  static const List<Color> streakGradient = [
    Color(0xFFFF9800),
    Color(0xFFFF5722),
  ];
}
