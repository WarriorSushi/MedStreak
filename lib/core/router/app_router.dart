import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../features/game/presentation/screens/game_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';

/// Enum defining all route names in the app
/// Used for type-safe navigation
enum AppRoute {
  splash,
  onboarding,
  login,
  menu,
  game,
  practiceGame,
  profile,
  settings,
  leaderboard,
}

/// Extension to get the path string for each route
extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.splash:
        return '/';
      case AppRoute.onboarding:
        return '/onboarding';
      case AppRoute.login:
        return '/login';
      case AppRoute.menu:
        return '/menu';
      case AppRoute.game:
        return '/game';
      case AppRoute.practiceGame:
        return '/game/practice';
      case AppRoute.profile:
        return '/profile';
      case AppRoute.settings:
        return '/settings';
      case AppRoute.leaderboard:
        return '/leaderboard';
    }
  }
}

/// Provider for the app router
final routerProvider = Provider<GoRouter>((ref) {
  // Create Firebase Analytics instance for tracking
  final analytics = FirebaseAnalytics.instance;
  
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,
    
    // Add observers for Firebase Analytics tracking
    observers: [
      FirebaseAnalyticsObserver(analytics: analytics),
    ],
    // Add redirect to handle navigation issues
    redirect: (context, state) {
      // Prevent navigation to non-existent routes by redirecting to menu
      if (state.fullPath == null || state.fullPath!.isEmpty) {
        return AppRoute.menu.path;
      }
      return null;
    },
    routes: [
      // Splash screen (initial route)
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding screen
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Login/Auth screen
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Main menu screen
      GoRoute(
        path: AppRoute.menu.path,
        name: AppRoute.menu.name,
        builder: (context, state) => const MenuScreen(),
      ),
      
      // Game screen
      GoRoute(
        path: AppRoute.game.path,
        name: AppRoute.game.name,
        builder: (context, state) => const GameScreen(gameMode: GameMode.normal),
      ),
      
      // Practice game screen
      GoRoute(
        path: AppRoute.practiceGame.path,
        name: AppRoute.practiceGame.name,
        builder: (context, state) => const GameScreen(gameMode: GameMode.practice),
      ),
      
      // Profile screen
      GoRoute(
        path: AppRoute.profile.path,
        name: AppRoute.profile.name,
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Settings screen
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Leaderboard screen
      GoRoute(
        path: AppRoute.leaderboard.path,
        name: AppRoute.leaderboard.name,
        builder: (context, state) => const LeaderboardScreen(),
      ),
    ],
    // Handle errors (404 not found, etc.)
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Error: ${state.error?.toString()}'),
      ),
    ),
  );
});

/// Navigate to a route using its name
void navigateTo(BuildContext context, AppRoute route, {Object? extra}) {
  context.goNamed(route.name, extra: extra);
}
