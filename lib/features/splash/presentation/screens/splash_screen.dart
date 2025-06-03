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
      // Gradient background as requested (#ffc439 to #fc4b91)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFC439), Color(0xFFFC4B91)],
          ),
        ),
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stack to show both logo and confetti animations
            Stack(
              alignment: Alignment.center,
              children: [
                // Confetti animation in background
                Lottie.asset(
                  'assets/lottie/confetti lottie.json',
                  height: 300,
                  width: 300,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
                // Logo animation on top
                Lottie.asset(
                  'assets/lottie/logoanimation.json',
                  controller: _animationController,
                  height: 240,
                  width: 240,
                  fit: BoxFit.contain,
                  repeat: false,
                  animate: true,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // App name with two-color styling using Nunito font
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Med',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 42,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  TextSpan(
                    text: 'Streak',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 42,
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tagline with adjusted color for better visibility on gradient
            Text(
              'Master Medical Parameters with Confidence',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
      ),
    );
  }
}
