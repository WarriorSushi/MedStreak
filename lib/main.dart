import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/providers/settings_provider.dart';

/// Entry point for the MedStreak application
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
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
  const MedStreakApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router from the provider
    final router = ref.watch(routerProvider);
    
    // Get the current theme mode from settings
    final isDarkMode = ref.watch(settingsProvider).darkMode;
    
    return MaterialApp.router(
      title: 'MedStreak',
      debugShowCheckedModeBanner: false,
      
      // Use GoRouter for navigation
      routerConfig: router,
      
      // Set the theme based on user preference
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}




