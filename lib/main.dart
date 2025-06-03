import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/providers/settings_provider.dart';

/// Entry point for the MedStreak application
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    // Use debug provider for development
    // Replace with webRecaptchaV3Provider or appAttestProvider for production
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  
  // Initialize Firebase Analytics
  // We'll use this in the app for tracking
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences for settings storage
  final sharedPreferences = await SharedPreferences.getInstance();

  // Run the app with a ProviderScope for Riverpod state management
  runApp(
    ProviderScope(
      overrides: [
        // Override the sharedPreferencesProvider with the instance
        sharedPreferencesProvider.overrideWith((ref) {
          return Future.value(sharedPreferences);
        }),
      ],
      child: const MedStreakApp(),
    ),
  );
}

/// Main application widget that sets up theme and routing
class MedStreakApp extends ConsumerWidget {
  const MedStreakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router from the provider
    // Pass FirebaseAnalytics.instance to the router for event tracking
    final router = ref.watch(routerProvider);

    // Get the current theme mode from settings
    final isDarkMode = ref.watch(settingsProvider).darkMode;

    return MaterialApp.router(
      title: 'MedStreak',
      debugShowCheckedModeBanner: false,

      // Use GoRouter for navigation
      routerConfig: router,
      
      // Add Firebase Analytics observer for navigation tracking
      // Note: MaterialApp.router doesn't support navigatorObservers directly
      // We'll track navigation events using GoRouter observers instead

      // Set the theme based on user preference
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
