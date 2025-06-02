import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/medical_parameter.dart';
// Use the ParameterDifficulty enum from medical_parameter.dart instead of defining a new enum
// This ensures consistency across the application

/// Classification of a medical value
enum ValueClassification {
  low,
  normal,
  high,
}

/// Game modes available in the app
enum GameMode {
  normal,   // Regular timed game with stakes
  practice,  // Practice mode with no time pressure
}

/// Model to represent the game state
class GameState {
  final List<MedicalParameterCase> cases;  // All available cases for this session
  final int currentCaseIndex;              // Current case being shown
  final int score;                         // Current score
  final int streak;                        // Current streak of correct answers
  final int bestStreak;                    // Best streak in this session
  final int lives;                         // Lives remaining (only for normal mode)
  final int timeRemaining;                 // Time remaining in seconds (only for normal mode)
  final bool isGameOver;                   // Whether the game is over
  final GameMode gameMode;                 // Current game mode
  final List<bool> results;                // History of correct/incorrect answers
  final bool isLoading;                    // Whether data is being loaded

  const GameState({
    required this.cases,
    required this.currentCaseIndex,
    required this.score,
    required this.streak,
    required this.bestStreak,
    required this.lives,
    required this.timeRemaining,
    required this.isGameOver,
    required this.gameMode,
    required this.results,
    required this.isLoading,
  });

  /// Get the current case being shown
  MedicalParameterCase? get currentCase =>
      cases.isNotEmpty && currentCaseIndex < cases.length
          ? cases[currentCaseIndex]
          : null;

  /// Factory to create an initial game state
  factory GameState.initial({required GameMode mode}) {
    return GameState(
      cases: [],
      currentCaseIndex: 0,
      score: 0,
      streak: 0,
      bestStreak: 0,
      lives: mode == GameMode.normal ? 3 : 999, // Unlimited lives in practice mode
      timeRemaining: mode == GameMode.normal ? 60 : 999, // No time pressure in practice mode
      isGameOver: false,
      gameMode: mode,
      results: [],
      isLoading: true,
    );
  }

  /// Create a copy of this state with specified fields updated
  GameState copyWith({
    List<MedicalParameterCase>? cases,
    int? currentCaseIndex,
    int? score,
    int? streak,
    int? bestStreak,
    int? lives,
    int? timeRemaining,
    bool? isGameOver,
    GameMode? gameMode,
    List<bool>? results,
    bool? isLoading,
  }) {
    return GameState(
      cases: cases ?? this.cases,
      currentCaseIndex: currentCaseIndex ?? this.currentCaseIndex,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      lives: lives ?? this.lives,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isGameOver: isGameOver ?? this.isGameOver,
      gameMode: gameMode ?? this.gameMode,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider to manage the game state
class GameNotifier extends StateNotifier<GameState> {
  final Random _random = Random();

  GameNotifier({required GameMode mode})
      : super(GameState.initial(mode: mode)) {
    // Initialize the game when created
    _initializeGame();
  }

  /// Initialize the game with random cases
  Future<void> _initializeGame() async {
    // Generate random cases from the repository
    final parameters = MedicalParameterRepository.getAllParameters();
    final randomCases = <MedicalParameterCase>[];

    // Create a mix of difficulties
    int beginnerCount = 8;
    int intermediateCount = 8;
    int advancedCount = 4;

    // Generate cases with different difficulties
    for (int i = 0; i < beginnerCount && parameters.isNotEmpty; i++) {
      final param = parameters[_random.nextInt(parameters.length)];
      randomCases.add(_generateCase(param, ParameterDifficulty.beginner));
    }

    for (int i = 0; i < intermediateCount && parameters.isNotEmpty; i++) {
      final param = parameters[_random.nextInt(parameters.length)];
      randomCases.add(_generateCase(param, ParameterDifficulty.intermediate));
    }

    for (int i = 0; i < advancedCount && parameters.isNotEmpty; i++) {
      final param = parameters[_random.nextInt(parameters.length)];
      randomCases.add(_generateCase(param, ParameterDifficulty.advanced));
    }

    // Update state with the new cases
    state = state.copyWith(
      cases: randomCases,
      isLoading: false,
    );
  }

  /// Generate a test case for a medical parameter
  MedicalParameterCase _generateCase(
    MedicalParameter parameter,
    ParameterDifficulty difficulty,
  ) {
    // Use neutral range for now (could be enhanced to use sex-specific ranges)
    final normalRange = parameter.getNormalRangeForSex(SexContext.neutral);
    final normalMin = normalRange['low']!;
    final normalMax = normalRange['high']!;
    
    // Determine which range to use based on difficulty
    final bool isAbnormal = _random.nextDouble() > 0.4; // 60% chance of abnormal value
    final bool isHigh = _random.nextBool(); // 50% chance of high vs low for abnormal

    // Get value (either normal or abnormal)
    double value;

    if (!isAbnormal) {
      // Generate a normal value
      value = normalMin + _random.nextDouble() * (normalMax - normalMin);
    } else if (isHigh) {
      // Generate a high value
      final deviation = (normalMax - normalMin) * _getDifficultyFactor(difficulty);
      value = normalMax + _random.nextDouble() * deviation;
    } else {
      // Generate a low value
      final deviation = (normalMax - normalMin) * _getDifficultyFactor(difficulty);
      value = normalMin - _random.nextDouble() * deviation;
      // Ensure the value is not negative for most parameters
      if (value < 0) {
        value = 0;
      }
    }

    // Round to reasonable precision (2 decimal places for most lab values)
    value = double.parse(value.toStringAsFixed(2));

    // Create the test case with proper ID
    final caseId = '${parameter.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    return MedicalParameterCase(
      parameter: parameter,
      value: value,
      difficulty: difficulty,
      sexContext: SexContext.neutral,
      id: caseId,
    );
  }

  /// Get a factor to determine the deviation from normal range based on difficulty
  double _getDifficultyFactor(ParameterDifficulty difficulty) {
    switch (difficulty) {
      case ParameterDifficulty.beginner:
        return 0.5; // Small deviation from normal
      case ParameterDifficulty.intermediate:
        return 1.5; // Moderate deviation
      case ParameterDifficulty.advanced:
        return 3.0; // Large deviation
    }
  }

  /// Process a user's swipe classification
  void classifyValue(ValueClassification classification) {
    final currentCase = state.currentCase;
    if (currentCase == null || state.isGameOver) return;

    // Determine if the classification is correct
    final isCorrect = _isClassificationCorrect(classification, currentCase);

    // Calculate new score and streak
    final scoreIncrement = isCorrect ? _calculateScoreForCase(currentCase, classification) : 0.0;
    final newScore = state.score + scoreIncrement.toInt();
    final newStreak = isCorrect ? state.streak + 1 : 0;
    final newBestStreak = max(newStreak, state.bestStreak);

    // Update lives if incorrect (normal mode only)
    final newLives = state.gameMode == GameMode.normal && !isCorrect
        ? state.lives - 1
        : state.lives;

    // Check if game is over
    final isGameOver = newLives <= 0 ||
        state.currentCaseIndex >= state.cases.length - 1;

    // Add result to history
    final newResults = List<bool>.from(state.results)..add(isCorrect);

    // Update state
    state = state.copyWith(
      currentCaseIndex: state.currentCaseIndex + 1,
      score: newScore,
      streak: newStreak,
      bestStreak: newBestStreak,
      lives: newLives,
      isGameOver: isGameOver,
      results: newResults,
    );
  }

  /// Determine if classification is correct
  bool _isClassificationCorrect(ValueClassification classification, MedicalParameterCase case_) {
    final value = case_.value;
    final normalRange = case_.parameter.getNormalRangeForSex(case_.sexContext);
    final normalMin = normalRange['low']!;
    final normalMax = normalRange['high']!;

    return switch (classification) {
      ValueClassification.low => value < normalMin,
      ValueClassification.normal => value >= normalMin && value <= normalMax,
      ValueClassification.high => value > normalMax,
    };
  }

  /// Calculate the score for a single answer
  double _calculateScoreForCase(MedicalParameterCase case_, ValueClassification userClass) {
    if (_isClassificationCorrect(userClass, case_)) {
      // Correct classification
      final difficultyMultiplier = _getDifficultyMultiplier(case_.difficulty);
      return case_.parameter.pointValue * difficultyMultiplier;
    } else {
      // Incorrect classification
      return 0.0;
    }
  }

  /// Get a multiplier for scoring based on difficulty
  double _getDifficultyMultiplier(ParameterDifficulty difficulty) {
    switch (difficulty) {
      case ParameterDifficulty.beginner:
        return 1.0;
      case ParameterDifficulty.intermediate:
        return 2.0;
      case ParameterDifficulty.advanced:
        return 3.0;
    }
  }

  /// Reduce remaining time by one second
  void decrementTimer() {
    if (state.timeRemaining <= 0 || state.isGameOver) return;

    final newTimeRemaining = state.timeRemaining - 1;
    final isGameOver = newTimeRemaining <= 0;

    state = state.copyWith(
      timeRemaining: newTimeRemaining,
      isGameOver: isGameOver,
    );
  }

  /// Restart the game
  void restartGame() {
    state = GameState.initial(mode: state.gameMode);
    _initializeGame();
  }
}

/// Provider for the game state
final gameProvider = StateNotifierProvider.family<GameNotifier, GameState, GameMode>(
  (ref, mode) => GameNotifier(mode: mode),
);

/// Provider for accessing the current case
final currentCaseProvider = Provider.family<MedicalParameterCase?, GameMode>(
  (ref, mode) => ref.watch(gameProvider(mode)).currentCase,
);

/// Provider for tracking if the game is over
final isGameOverProvider = Provider.family<bool, GameMode>(
  (ref, mode) => ref.watch(gameProvider(mode)).isGameOver,
);

/// Provider for tracking the current score
final scoreProvider = Provider.family<int, GameMode>(
  (ref, mode) => ref.watch(gameProvider(mode)).score,
);

/// Provider for tracking the current streak
final streakProvider = Provider.family<int, GameMode>(
  (ref, mode) => ref.watch(gameProvider(mode)).streak,
);

/// Provider for tracking remaining lives
final livesProvider = Provider.family<int, GameMode>(
  (ref, mode) => ref.watch(gameProvider(mode)).lives,
);

/// Provider for tracking remaining time
final timeRemainingProvider = Provider.family<int, GameMode>(
  (ref, mode) => ref.watch(gameProvider(mode)).timeRemaining,
);
