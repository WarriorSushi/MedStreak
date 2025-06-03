import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/app_router.dart';

/// Model for menu items
class MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final AppRoute route;

  const MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

/// Main menu screen that serves as the central hub of the app
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Define menu items
    final List<MenuItem> menuItems = [
      MenuItem(
        title: 'Play Game',
        subtitle: 'Challenge yourself with medical parameters',
        icon: Icons.play_circle_filled,
        color: Colors.blue,
        route: AppRoute.game,
      ),
      MenuItem(
        title: 'Practice Mode',
        subtitle: 'Learn at your own pace with hints',
        icon: Icons.school,
        color: Colors.green,
        route: AppRoute.practiceGame,
      ),
      MenuItem(
        title: 'Leaderboard',
        subtitle: 'See how you rank against others',
        icon: Icons.leaderboard,
        color: Colors.orange,
        route: AppRoute.leaderboard,
      ),
      MenuItem(
        title: 'Profile',
        subtitle: 'View your stats and achievements',
        icon: Icons.person,
        color: Colors.purple,
        route: AppRoute.profile,
      ),
      MenuItem(
        title: 'Settings',
        subtitle: 'Customize your experience',
        icon: Icons.settings,
        color: Colors.blueGrey,
        route: AppRoute.settings,
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with Lottie background and large MedStreak text
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              // No title in the app bar, as we'll overlay our own larger text
              title: null,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Lottie animation as background
                  Lottie.asset(
                    'assets/lottie/mainpage_topbanner_lottie.json',
                    fit: BoxFit.cover,
                  ),
                  // Centered large MedStreak text
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.7, // Takes up 70% of the width as requested
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Med',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 36, // Much larger text
                                letterSpacing: 1.0,
                              ),
                            ),
                            TextSpan(
                              text: 'Streak',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 36, // Much larger text
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Profile button
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  context.goNamed(AppRoute.profile.name);
                },
              ),
              // Settings button
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context.goNamed(AppRoute.settings.name);
                },
              ),
            ],
          ),

          // Current streak info
          SliverToBoxAdapter(child: _buildCurrentStreak(context)),

          // Menu items
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3, // Increased to make cards less tall
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildMenuItem(context, menuItems[index]);
              }, childCount: menuItems.length),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the highest streak display
  Widget _buildCurrentStreak(BuildContext context) {
    // TODO: Get actual streak data from provider
    const int highestStreak = 0; // For testing, set to 0 to show 'yet to be made'

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 100, // Reduced height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.deepOrange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Streak animation - smaller size
          Lottie.asset(
            'assets/lottie/streak_flame_level_1.json',
            height: 60,
            width: 60,
            repeat: true,
          ),
          const SizedBox(width: 12),

          // Streak info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Highest Streak',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  highestStreak > 0 
                    ? '$highestStreak' 
                    : 'Yet to be made',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),

          // Play button
          ElevatedButton(
            onPressed: () {
              context.goNamed(AppRoute.game.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Play Now'),
          ),
        ],
      ),
    );
  }

  /// Build a menu item card
  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Card(
      elevation: 3, // Reduced elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Smaller border radius
      child: InkWell(
        onTap: () {
          context.goNamed(item.route.name);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Minimizes the vertical space
            children: [
              // Icon - smaller size
              Icon(item.icon, size: 36, color: item.color),
              const SizedBox(height: 8), // Reduced spacing

              // Title - more compact font
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Smaller font size
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2), // Minimal spacing

              // Subtitle - more compact
              Text(
                item.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11, // Smaller font size
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
