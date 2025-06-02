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
  const MenuScreen({Key? key}) : super(key: key);

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
          // App bar with logo
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('MedStreak'),
              background: Container(
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/logo animation.json',
                    height: 120,
                    width: 120,
                  ),
                ),
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
          SliverToBoxAdapter(
            child: _buildCurrentStreak(context),
          ),
          
          // Menu items
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildMenuItem(context, menuItems[index]);
                },
                childCount: menuItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the current streak display
  Widget _buildCurrentStreak(BuildContext context) {
    // TODO: Get actual streak data from provider
    const int streak = 5;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade300,
            Colors.deepOrange.shade500,
          ],
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
          // Streak animation
          Lottie.asset(
            'assets/lottie/streak_flame_level_1.json',
            height: 80,
            width: 80,
            repeat: true,
          ),
          const SizedBox(width: 16),
          
          // Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$streak days',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          context.goNamed(item.route.name);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                item.icon,
                size: 48,
                color: item.color,
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              
              // Subtitle
              Text(
                item.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
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
