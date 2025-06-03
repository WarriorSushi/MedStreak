import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../application/providers/game_provider.dart';

/// Screen shown after completing a game session to display results
class GameResultsScreen extends ConsumerWidget {
  final GameMode gameMode;
  final int score;
  final int bestStreak;
  final List<bool> results;

  const GameResultsScreen({
    super.key,
    required this.gameMode,
    required this.score,
    required this.bestStreak,
    required this.results,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correctAnswers = results.where((result) => result).length;
    final totalAnswers = results.length;
    final accuracy = totalAnswers > 0
        ? (correctAnswers / totalAnswers) * 100
        : 0.0;

    // Determine performance rating
    final String rating = _getRating(accuracy.toDouble());
    final bool isHighScore = _isHighScore(score);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.goNamed(AppRoute.menu.name),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Game completion header
                    Text(
                      gameMode == GameMode.normal
                          ? 'Game Completed!'
                          : 'Practice Session Completed!',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Score animation
                    if (isHighScore)
                      SizedBox(
                        height: 120,
                        child: Lottie.asset(
                          'assets/lottie/trophy animation.json',
                          repeat: true,
                        ),
                      ),

                    // Performance rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _getRatingColor(rating),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        rating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Results grid
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Score row
                          _buildResultRow(
                            context: context,
                            label: 'Score',
                            value: score.toString(),
                            icon: Icons.score,
                            isHighlight: true,
                          ),
                          const Divider(height: 32),

                          // Accuracy row
                          _buildResultRow(
                            context: context,
                            label: 'Accuracy',
                            value: '${accuracy.toStringAsFixed(1)}%',
                            icon: Icons.check_circle_outline,
                          ),
                          const SizedBox(height: 16),

                          // Best streak row
                          _buildResultRow(
                            context: context,
                            label: 'Best Streak',
                            value: bestStreak.toString(),
                            icon: Icons.local_fire_department,
                            valueColor: Colors.orange,
                          ),
                          const SizedBox(height: 16),

                          // Correct answers row
                          _buildResultRow(
                            context: context,
                            label: 'Correct Answers',
                            value: '$correctAnswers/$totalAnswers',
                            icon: Icons.done_all,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    AppButton(
                      text: 'Play Again',
                      icon: Icons.replay,
                      onPressed: () {
                        // Reset game and navigate back to game screen
                        final gameNotifier = ref.read(
                          gameProvider(gameMode).notifier,
                        );
                        gameNotifier.restartGame();
                        context.goNamed(
                          gameMode == GameMode.normal
                              ? AppRoute.game.name
                              : AppRoute
                                    .game
                                    .name, // Use game route for both modes for now
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    AppOutlinedButton(
                      text: 'Back to Menu',
                      icon: Icons.home,
                      onPressed: () => context.goNamed(AppRoute.menu.name),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a result row with label and value
  Widget _buildResultRow({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    bool isHighlight = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isHighlight
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isHighlight
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 24 : 18,
            fontWeight: FontWeight.bold,
            color:
                valueColor ??
                (isHighlight
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  /// Determine performance rating based on accuracy
  String _getRating(double accuracy) {
    if (accuracy >= 95) return 'Excellent';
    if (accuracy >= 85) return 'Great';
    if (accuracy >= 70) return 'Good';
    if (accuracy >= 50) return 'Average';
    return 'Needs Practice';
  }

  /// Get color for performance rating
  Color _getRatingColor(String rating) {
    switch (rating) {
      case 'Excellent':
        return AppColors.gold;
      case 'Great':
        return AppColors.secondary;
      case 'Good':
        return AppColors.primary;
      case 'Average':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  /// Check if score is a high score (would need to be connected to a database)
  bool _isHighScore(int score) {
    // Placeholder logic - in a real app, would compare to stored high scores
    return score > 500;
  }
}
