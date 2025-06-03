import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

/// Model for leaderboard user data
class LeaderboardUser {
  final String id;
  final String name;
  final String avatarUrl;
  final int score;
  final int level;
  final int streak;

  const LeaderboardUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.level,
    required this.streak,
  });
}

/// Leaderboard screen that displays top users ranked by score
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Mock leaderboard data
  final List<LeaderboardUser> _dailyLeaderboard = [
    const LeaderboardUser(
      id: '1',
      name: 'Sarah Johnson',
      avatarUrl: '',
      score: 950,
      level: 12,
      streak: 8,
    ),
    const LeaderboardUser(
      id: '2',
      name: 'Mike Chen',
      avatarUrl: '',
      score: 870,
      level: 10,
      streak: 5,
    ),
    const LeaderboardUser(
      id: '3',
      name: 'Emily Wilson',
      avatarUrl: '',
      score: 820,
      level: 9,
      streak: 4,
    ),
    const LeaderboardUser(
      id: '4',
      name: 'Guest User',
      avatarUrl: '',
      score: 750,
      level: 5,
      streak: 3,
    ),
    const LeaderboardUser(
      id: '5',
      name: 'Alex Rodriguez',
      avatarUrl: '',
      score: 680,
      level: 8,
      streak: 2,
    ),
    const LeaderboardUser(
      id: '6',
      name: 'Taylor Swift',
      avatarUrl: '',
      score: 650,
      level: 7,
      streak: 1,
    ),
    const LeaderboardUser(
      id: '7',
      name: 'Jordan Lee',
      avatarUrl: '',
      score: 620,
      level: 6,
      streak: 3,
    ),
    const LeaderboardUser(
      id: '8',
      name: 'Morgan Freeman',
      avatarUrl: '',
      score: 580,
      level: 5,
      streak: 0,
    ),
    const LeaderboardUser(
      id: '9',
      name: 'Jamie Oliver',
      avatarUrl: '',
      score: 550,
      level: 5,
      streak: 2,
    ),
    const LeaderboardUser(
      id: '10',
      name: 'Chris Evans',
      avatarUrl: '',
      score: 520,
      level: 4,
      streak: 1,
    ),
  ];

  final List<LeaderboardUser> _weeklyLeaderboard = [];
  final List<LeaderboardUser> _allTimeLeaderboard = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Simulate loading data
    _loadLeaderboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load leaderboard data (simulated for now)
  Future<void> _loadLeaderboardData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        // Copy the daily leaderboard data with modified scores for other tabs
        _weeklyLeaderboard.clear();
        _allTimeLeaderboard.clear();

        for (final user in _dailyLeaderboard) {
          _weeklyLeaderboard.add(
            LeaderboardUser(
              id: user.id,
              name: user.name,
              avatarUrl: user.avatarUrl,
              score: user.score * 4 + (100 - int.parse(user.id) * 5),
              level: user.level,
              streak: user.streak + 2,
            ),
          );

          _allTimeLeaderboard.add(
            LeaderboardUser(
              id: user.id,
              name: user.name,
              avatarUrl: user.avatarUrl,
              score: user.score * 15 + (500 - int.parse(user.id) * 20),
              level: user.level + 5,
              streak: user.streak + 5,
            ),
          );
        }

        // Sort by score
        _weeklyLeaderboard.sort((a, b) => b.score.compareTo(a.score));
        _allTimeLeaderboard.sort((a, b) => b.score.compareTo(a.score));

        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(_dailyLeaderboard),
                _buildLeaderboardTab(_weeklyLeaderboard),
                _buildLeaderboardTab(_allTimeLeaderboard),
              ],
            ),
    );
  }

  /// Build a leaderboard tab with the given user list
  Widget _buildLeaderboardTab(List<LeaderboardUser> users) {
    // Find the index of the current user (Guest User)
    final currentUserIndex = users.indexWhere(
      (user) => user.name == 'Guest User',
    );

    return Column(
      children: [
        // Top 3 users podium
        if (users.length >= 3) _buildTopThreePodium(users.sublist(0, 3)),

        // List of other users
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              // Skip the top 3 users as they're shown in the podium
              if (index < 3) return const SizedBox.shrink();

              final user = users[index];
              final isCurrentUser = user.name == 'Guest User';

              return _buildLeaderboardItem(
                rank: index + 1,
                user: user,
                isCurrentUser: isCurrentUser,
              );
            },
          ),
        ),

        // Current user position (if not in top 10)
        if (currentUserIndex > 10)
          _buildCurrentUserPosition(
            currentUserIndex + 1,
            users[currentUserIndex],
          ),
      ],
    );
  }

  /// Build the podium showing the top 3 users
  Widget _buildTopThreePodium(List<LeaderboardUser> topThree) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (topThree.length > 1)
            _buildPodiumUser(
              user: topThree[1],
              rank: 2,
              height: 100,
              trophy: Icons.looks_two,
              color: Colors.grey[300]!,
            ),

          // 1st Place
          _buildPodiumUser(
            user: topThree[0],
            rank: 1,
            height: 130,
            trophy: Icons.looks_one,
            color: Colors.amber,
            showCrown: true,
          ),

          // 3rd Place
          if (topThree.length > 2)
            _buildPodiumUser(
              user: topThree[2],
              rank: 3,
              height: 80,
              trophy: Icons.looks_3,
              color: Colors.brown[300]!,
            ),
        ],
      ),
    );
  }

  /// Build a user on the podium
  Widget _buildPodiumUser({
    required LeaderboardUser user,
    required int rank,
    required double height,
    required IconData trophy,
    required Color color,
    bool showCrown = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st place
        if (showCrown)
          Lottie.asset(
            'assets/lottie/trophy animation.json',
            height: 40,
            width: 40,
          ),

        // User avatar
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 36 : 30,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: rank == 1 ? 34 : 28,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  user.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: rank == 1 ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),

            // Trophy icon
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(trophy, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // User name (truncated if too long)
        Text(
          user.name.length > 10
              ? '${user.name.substring(0, 10)}...'
              : user.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // User score
        Text(
          '${user.score} pts',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),

        // Podium platform
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  /// Build a leaderboard item for users not in the top 3
  Widget _buildLeaderboardItem({
    required int rank,
    required LeaderboardUser user,
    required bool isCurrentUser,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCurrentUser
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.grey[200],
          child: Text(
            '$rank',
            style: TextStyle(
              color: isCurrentUser
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('Level ${user.level}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.score} pts',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (user.streak > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: Colors.orange,
                      ),
                      Text(
                        ' ${user.streak}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build the current user's position if not in top 10
  Widget _buildCurrentUserPosition(int rank, LeaderboardUser user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Position',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${user.score} points'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to game screen
              // context.goNamed(AppRoute.game.name);
            },
            child: const Text('Improve'),
          ),
        ],
      ),
    );
  }
}
