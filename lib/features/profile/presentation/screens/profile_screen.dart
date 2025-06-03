import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

/// Profile screen that displays user information, stats and achievements
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'), 
        centerTitle: true,
        // Add back button to return to main menu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with avatar and name
            _buildProfileHeader(context),

            // Stats section
            _buildStatsSection(context),

            // Achievement section
            _buildAchievementsSection(context),

            // History section
            _buildHistorySection(context),
          ],
        ),
      ),
    );
  }

  /// Build the profile header with user info
  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              // Avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 80, color: AppColors.primary),
              ),

              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User name
          const Text(
            'Dr. Smith', // TODO: Replace with actual user data
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // User level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: AppColors.gold, size: 18),
                SizedBox(width: 4),
                Text('Level 5 - Intern', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the stats section
  Widget _buildStatsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Stats cards in a grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                context,
                'Total Score',
                '1,250',
                Icons.score,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'Best Streak',
                '7 days',
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                'Games Played',
                '32',
                Icons.games,
                Colors.purple,
              ),
              _buildStatCard(
                context,
                'Accuracy',
                '84%',
                Icons.check_circle,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a stat card
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build the achievements section
  Widget _buildAchievementsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Achievement list
          _buildAchievementItem(
            context,
            'First Blood',
            'Complete your first game',
            true,
          ),
          _buildAchievementItem(
            context,
            'On Fire',
            'Maintain a 5-day streak',
            true,
          ),
          _buildAchievementItem(
            context,
            'Electrolyte Master',
            'Correctly identify 20 electrolyte abnormalities',
            false,
          ),
          _buildAchievementItem(
            context,
            'Perfect Game',
            'Get 100% accuracy in a game',
            false,
          ),
        ],
      ),
    );
  }

  /// Build an achievement item
  Widget _buildAchievementItem(
    BuildContext context,
    String title,
    String description,
    bool isUnlocked,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.amber[100] : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          isUnlocked ? Icons.emoji_events : Icons.lock,
          color: isUnlocked ? AppColors.gold : Colors.grey,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isUnlocked ? null : Colors.grey,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: isUnlocked ? Colors.grey[600] : Colors.grey),
      ),
      trailing: isUnlocked
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
    );
  }

  /// Build the game history section
  Widget _buildHistorySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Games',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Game history list
          _buildGameHistoryItem(context, 'Today', 'Score: 85', 'Accuracy: 80%'),
          _buildGameHistoryItem(
            context,
            'Yesterday',
            'Score: 120',
            'Accuracy: 90%',
          ),
          _buildGameHistoryItem(
            context,
            '2 days ago',
            'Score: 75',
            'Accuracy: 70%',
          ),
        ],
      ),
    );
  }

  /// Build a game history item
  Widget _buildGameHistoryItem(
    BuildContext context,
    String date,
    String score,
    String accuracy,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Date circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
              ),
              child: Center(
                child: Icon(Icons.calendar_today, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),

            // Game details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(score),
                  Text(accuracy),
                ],
              ),
            ),

            // Details button
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                // TODO: Navigate to detailed game history
              },
            ),
          ],
        ),
      ),
    );
  }
}
