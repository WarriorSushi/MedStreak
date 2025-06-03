import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/app_router.dart';

/// Splash screen shown when the app first launches
/// Displays app logo animation and handles initial loading
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animationController.forward();

    // Simulate loading and navigate to next screen
    _initializeAppAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize app resources and navigate to appropriate screen
  Future<void> _initializeAppAndNavigate() async {
    // Delay for splash animation to play (minimum 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Add initialization logic here (check auth state, load preferences, etc.)
    // For now, we'll just navigate to the onboarding screen

    if (mounted) {
      context.goNamed(AppRoute.onboarding.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation with improved animation file
            Lottie.asset(
              'assets/lottie/logoanimation.json', // Using the cleaner logo animation
              controller: _animationController,
              height: 240, // Slightly larger for better visibility
              width: 240,
              fit: BoxFit.contain, // Ensure animation fits properly
              repeat: false, // Play once
              animate: true,
            ),
            const SizedBox(height: 32),

            // App name
            Text(
              'MedStreak',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            Text(
              'Master Medical Parameters with Confidence',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
