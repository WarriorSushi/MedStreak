import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.g.dart';
part 'user_profile.freezed.dart';

/// Model representing a user's profile in the app
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String username,
    required String email,
    @Default('') String photoUrl,
    @Default(0) int level,
    @Default(0) int experience,
    @Default(0) int totalScore,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int gamesPlayed,
    @Default(0) int gamesWon,
    @Default(0) int rank,
    @Default(<String>[]) List<String> badges,
    @Default(<String, int>{}) Map<String, int> highScores,
    @Default(<String, dynamic>{}) Map<String, dynamic> settings,
    DateTime? lastPlayedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  /// Create a default profile with minimal required data
  factory UserProfile.defaultProfile({
    required String id,
    required String username,
    required String email,
  }) {
    return UserProfile(
      id: id,
      username: username,
      email: email,
      createdAt: DateTime.now(),
    );
  }

  /// Create a profile from JSON data
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  /// Calculate experience needed for next level
  static int experienceForLevel(int level) {
    // Exponential growth formula for level requirements
    return 100 * level * (level + 1) ~/ 2;
  }
}

/// Extension to add helper methods to UserProfile
extension UserProfileExtension on UserProfile {
  /// Calculate experience needed for the next level
  int get experienceNeededForNextLevel {
    return UserProfile.experienceForLevel(level + 1) - UserProfile.experienceForLevel(level);
  }

  /// Calculate progress to next level (0.0 to 1.0)
  double get levelProgress {
    final currentLevelExp = UserProfile.experienceForLevel(level);
    final nextLevelExp = UserProfile.experienceForLevel(level + 1);
    final requiredExp = nextLevelExp - currentLevelExp;
    final userProgress = experience - currentLevelExp;
    
    return userProgress / requiredExp;
  }

  /// Get highest badge tier earned
  String get highestBadge {
    if (badges.contains('platinum')) return 'platinum';
    if (badges.contains('gold')) return 'gold';
    if (badges.contains('silver')) return 'silver';
    if (badges.contains('bronze')) return 'bronze';
    return 'none';
  }

  /// Add experience points and handle level-up
  UserProfile addExperience(int xp) {
    final newExperience = experience + xp;
    var newLevel = level;
    
    // Check if user leveled up
    while (newExperience >= UserProfile.experienceForLevel(newLevel + 1)) {
      newLevel++;
    }
    
    return copyWith(
      experience: newExperience,
      level: newLevel,
      updatedAt: DateTime.now(),
    );
  }

  /// Add score from a completed game
  UserProfile addGameScore(int score, int streak, bool isWin, String gameMode) {
    final newTotalScore = totalScore + score;
    final newGamesPlayed = gamesPlayed + 1;
    final newGamesWon = isWin ? gamesWon + 1 : gamesWon;
    final newCurrentStreak = isWin ? currentStreak + 1 : 0;
    final newLongestStreak = newCurrentStreak > longestStreak 
        ? newCurrentStreak 
        : longestStreak;
    
    // Update high scores map if this is a new high score
    final newHighScores = Map<String, int>.from(highScores);
    if (!newHighScores.containsKey(gameMode) || score > newHighScores[gameMode]!) {
      newHighScores[gameMode] = score;
    }
    
    return copyWith(
      totalScore: newTotalScore,
      gamesPlayed: newGamesPlayed,
      gamesWon: newGamesWon,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      highScores: newHighScores,
      lastPlayedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Add a new badge to the user's collection
  UserProfile addBadge(String badge) {
    if (badges.contains(badge)) return this;
    
    final newBadges = List<String>.from(badges)..add(badge);
    
    return copyWith(
      badges: newBadges,
      updatedAt: DateTime.now(),
    );
  }

  /// Update user settings
  UserProfile updateSettings(Map<String, dynamic> newSettings) {
    final updatedSettings = Map<String, dynamic>.from(settings);
    updatedSettings.addAll(newSettings);
    
    return copyWith(
      settings: updatedSettings,
      updatedAt: DateTime.now(),
    );
  }

  /// Update profile information
  UserProfile updateProfile({
    String? username,
    String? email,
    String? photoUrl,
  }) {
    return copyWith(
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      updatedAt: DateTime.now(),
    );
  }
}
