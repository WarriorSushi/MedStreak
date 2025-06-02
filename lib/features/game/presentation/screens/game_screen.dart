import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/game/domain/models/medical_parameter.dart';
import '../../../../features/settings/application/providers/settings_provider.dart';

/// Enum representing the different game modes
enum GameMode {
  normal,   // Regular gameplay with points and streaks
  practice, // Practice mode with unlimited tries and hints
}

/// Game screen where the user swipes medical parameter cards
/// to classify values as low, normal, or high
class GameScreen extends ConsumerStatefulWidget {
  final GameMode gameMode;

  const GameScreen({
    Key? key,
    required this.gameMode,
  }) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with SingleTickerProviderStateMixin {
  // Card animation controller
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Game state variables
  final List<MedicalParameterCase> _cases = [];
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  bool _showFeedback = false;
  String _feedbackMessage = '';
  bool _isCorrect = false;
  
  // Dragging state
  double _dragPosition = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Generate test cases
    _generateTestCases();
    
    // Start the first card animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Generate random test cases using the medical parameter repository
  void _generateTestCases() {
    final random = Random();
    final parameters = MedicalParameterRepository.getAllParameters();
    
    // Clear existing cases
    _cases.clear();
    
    // Generate 10 random cases
    for (int i = 0; i < 10; i++) {
      final parameter = parameters[random.nextInt(parameters.length)];
      
      // Determine if we'll create a low, normal, or high value
      final valueType = random.nextInt(3); // 0: low, 1: normal, 2: high
      
      // Get normal range for male or female based on the current setting
      final sexContext = ref.read(settingsProvider).sexContext;
      final normalRange = parameter.getNormalRangeForSex(sexContext);
      
      double value;
      
      // Generate a value based on the value type
      switch (valueType) {
        case 0: // Low value
          value = normalRange['low']! * (0.5 + random.nextDouble() * 0.3); // 50-80% of lower limit
          break;
        case 1: // Normal value
          final rangeMidpoint = (normalRange['low']! + normalRange['high']!) / 2;
          final rangeWidth = normalRange['high']! - normalRange['low']!;
          value = rangeMidpoint + (random.nextDouble() * 0.8 - 0.4) * rangeWidth; // Within ±40% of midpoint
          break;
        case 2: // High value
          value = normalRange['high']! * (1.2 + random.nextDouble() * 0.6); // 120-180% of upper limit
          break;
        default:
          value = normalRange['low']!;
      }
      
      // Create the case
      _cases.add(
        MedicalParameterCase(
          id: 'case_$i',
          parameter: parameter,
          value: value,
          sexContext: sexContext,
          difficulty: parameter.difficulty,
        ),
      );
    }
    
    // Reset the current index
    _currentIndex = 0;
  }
  
  /// Check if the swipe direction is correct for the current case
  void _checkAnswer(String direction) {
    if (_currentIndex >= _cases.length) return;
    
    final currentCase = _cases[_currentIndex];
    final classification = currentCase.getValueClassification();
    
    bool isCorrect = false;
    
    // Check if the classification matches the swipe direction
    if (classification == 'LOW' && direction == 'left') {
      isCorrect = true;
    } else if (classification == 'NORMAL' && direction == 'up') {
      isCorrect = true;
    } else if (classification == 'HIGH' && direction == 'right') {
      isCorrect = true;
    }
    
    // Update score and streak
    if (isCorrect) {
      _score += currentCase.parameter.pointValue;
      _streak++;
      _feedbackMessage = 'Correct! +${currentCase.parameter.pointValue} points';
    } else {
      _streak = 0;
      _feedbackMessage = 'Incorrect! The value is $classification';
    }
    
    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
    });
    
    // Move to the next card after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
          _currentIndex++;
          
          // Reset the animation for the next card
          _animationController.reset();
          _animationController.forward();
          
          // Generate new cases if we've gone through all of them
          if (_currentIndex >= _cases.length) {
            _generateTestCases();
          }
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Get the current unit system from settings
    final unitSystem = ref.watch(unitSystemProvider);
    
    // Get the current sex context from settings
    final sexContext = ref.watch(sexContextProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameMode == GameMode.normal ? 'MedStreak' : 'Practice Mode'),
        actions: [
          // Unit system toggle button
          IconButton(
            icon: Icon(unitSystem == UnitSystem.si ? Icons.science : Icons.biotech),
            tooltip: 'Toggle ${unitSystem == UnitSystem.si ? "Conventional" : "SI"} Units',
            onPressed: () {
              ref.read(settingsProvider.notifier).toggleUnitSystem();
            },
          ),
          
          // Sex context selector dropdown
          PopupMenuButton<SexContext>(
            icon: Icon(_getSexContextIcon(sexContext)),
            tooltip: 'Change Reference Ranges',
            onSelected: (SexContext value) {
              ref.read(settingsProvider.notifier).setSexContext(value);
              // Regenerate cases with new sex context
              _generateTestCases();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SexContext.male,
                child: Row(
                  children: [
                    Icon(Icons.male),
                    SizedBox(width: 8),
                    Text('Male Ranges'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SexContext.female,
                child: Row(
                  children: [
                    Icon(Icons.female),
                    SizedBox(width: 8),
                    Text('Female Ranges'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SexContext.neutral,
                child: Row(
                  children: [
                    Icon(Icons.people),
                    SizedBox(width: 8),
                    Text('Neutral Ranges'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Score and streak display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _score.toString(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                
                // Streak display with animation
                if (_streak > 0)
                  Row(
                    children: [
                      Lottie.asset(
                        'assets/lottie/streak_flame_level_1.json',
                        height: 40,
                        repeat: true,
                      ),
                      const SizedBox(width: 4),
                      Column(
                        children: [
                          Text(
                            'Streak',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            _streak.toString(),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.normalValueColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Game instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Swipe LEFT for LOW, UP for NORMAL, RIGHT for HIGH',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          
          // Card area
          Expanded(
            child: _cases.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      // Card
                      if (_currentIndex < _cases.length)
                        _buildParameterCard(
                          _cases[_currentIndex],
                          unitSystem,
                          sexContext,
                        ),
                      
                      // Feedback overlay
                      if (_showFeedback)
                        _buildFeedbackOverlay(),
                    ],
                  ),
          ),
          
          // Swipe direction indicators
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSwipeIndicator('LOW', Colors.red, Icons.arrow_back),
                _buildSwipeIndicator('NORMAL', Colors.green, Icons.arrow_upward),
                _buildSwipeIndicator('HIGH', Colors.orange, Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build the parameter card with draggable functionality
  Widget _buildParameterCard(
    MedicalParameterCase paramCase,
    UnitSystem unitSystem,
    SexContext sexContext,
  ) {
    // Get the parameter and value in the current unit system
    final parameter = paramCase.parameter;
    final value = paramCase.getValueInUnitSystem(unitSystem);
    
    // Format the value with appropriate precision
    final valueStr = _formatValue(value);
    
    // Normal range in the current unit system
    final normalRange = parameter.getNormalRangeForSex(sexContext);
    final lowValue = unitSystem == UnitSystem.si
        ? normalRange['low']!
        : parameter.convertSItoConventional(normalRange['low']!);
    final highValue = unitSystem == UnitSystem.si
        ? normalRange['high']!
        : parameter.convertSItoConventional(normalRange['high']!);
    
    // Format normal range values
    final lowValueStr = _formatValue(lowValue);
    final highValueStr = _formatValue(highValue);
    
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragPosition += details.delta.dx;
          // Limit the drag distance
          _dragPosition = _dragPosition.clamp(-200.0, 200.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragPosition < -100) {
          // Swiped left - LOW
          _checkAnswer('left');
        } else if (_dragPosition > 100) {
          // Swiped right - HIGH
          _checkAnswer('right');
        } else {
          // Return to center
          setState(() {
            _dragPosition = 0;
          });
        }
      },
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -10) {
          // Swiped up - NORMAL
          _checkAnswer('up');
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_dragPosition, 0),
            child: Transform.scale(
              scale: _animation.value,
              child: Opacity(
                opacity: _animation.value,
                child: child,
              ),
            ),
          );
        },
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parameter name and category
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parameter.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            parameter.category,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Unit system indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: unitSystem == UnitSystem.si
                            ? Colors.blue[100]
                            : Colors.purple[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        unitSystem == UnitSystem.si ? 'SI' : 'Conv',
                        style: TextStyle(
                          color: unitSystem == UnitSystem.si
                              ? Colors.blue[800]
                              : Colors.purple[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Parameter value (large display)
                Center(
                  child: Column(
                    children: [
                      Text(
                        valueStr,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        parameter.getUnitString(unitSystem),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Parameter description
                Text(
                  parameter.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                
                // Normal range display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Normal Range ',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Icon(_getSexContextIcon(sexContext), size: 16),
                          Text(
                            ' ${sexContext.name.toUpperCase()}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$lowValueStr - $highValueStr ${parameter.getUnitString(unitSystem)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.normalValueColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build the feedback overlay shown after a swipe
  Widget _buildFeedbackOverlay() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Feedback icon/animation
          _isCorrect
              ? Lottie.asset(
                  'assets/lottie/confetti lottie.json',
                  height: 100,
                  repeat: true,
                )
              : const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 80,
                ),
          const SizedBox(height: 16),
          
          // Feedback message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _feedbackMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a swipe direction indicator
  Widget _buildSwipeIndicator(String label, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  /// Get the icon for the current sex context
  IconData _getSexContextIcon(SexContext context) {
    switch (context) {
      case SexContext.male:
        return Icons.male;
      case SexContext.female:
        return Icons.female;
      case SexContext.neutral:
        return Icons.people;
    }
  }
  
  /// Format a numeric value with appropriate precision
  String _formatValue(double value) {
    if (value < 0.01) {
      return value.toStringAsExponential(2);
    } else if (value < 1) {
      return value.toStringAsFixed(3);
    } else if (value < 10) {
      return value.toStringAsFixed(2);
    } else if (value < 100) {
      return value.toStringAsFixed(1);
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
