import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/app_router.dart';

/// Model class for onboarding page data
class OnboardingPage {
  final String title;
  final String description;
  final String animationAsset;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.animationAsset,
  });
}

/// Onboarding screen shown to new users
/// Showcases key features of the MedStreak app
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define the onboarding pages
  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'Welcome to MedStreak',
      description:
          'Learn medical parameters and lab values in a fun, game-based environment.',
      animationAsset: 'assets/lottie/doctor waving hand lottie.json',
    ),
    OnboardingPage(
      title: 'Master Medical Parameters',
      description:
          'Swipe to classify values as low, normal, or high. Build your skills over time.',
      animationAsset: 'assets/lottie/doctor reading lap report lottie.json',
    ),
    OnboardingPage(
      title: 'SI & Conventional Units',
      description:
          'Toggle between SI and conventional units to learn both measurement systems.',
      animationAsset:
          'assets/lottie/square changin gshape circle trinangel lgo lottie.json',
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      description:
          'Build streaks, earn achievements, and compete on the leaderboard.',
      animationAsset: 'assets/lottie/trophy sling in lottie.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _goToLogin(),
                child: const Text('Skip'),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator and navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),

                  // Next/Done button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _goToLogin();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build an individual onboarding page
  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation
          Lottie.asset(page.animationAsset, height: 280, repeat: true),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build a page indicator dot
  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[300],
      ),
    );
  }

  /// Navigate to the login screen
  void _goToLogin() {
    try {
      // Use go method instead of goNamed for more reliable navigation
      context.go(AppRoute.login.path);
    } catch (e) {
      // Log any navigation errors
      print('Navigation error: $e');
      // Attempt to navigate again with a different method
      try {
        context.pushNamed(AppRoute.login.name);
      } catch (e2) {
        // As a last resort, use Navigator directly
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    }
  }
}
