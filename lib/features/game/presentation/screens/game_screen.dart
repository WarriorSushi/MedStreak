import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart'; // Add physics package for spring animations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/game/domain/models/medical_parameter.dart';
import '../../../../features/settings/application/providers/settings_provider.dart';

/// Enum representing the different game modes
enum GameMode {
  normal, // Regular gameplay with points and streaks
  practice, // Practice mode with unlimited tries and hints
}

/// Game screen where the user swipes medical parameter cards
/// to classify values as low, normal, or high
class GameScreen extends ConsumerStatefulWidget {
  final GameMode gameMode;

  const GameScreen({super.key, required this.gameMode});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  // Card animation controllers
  late AnimationController _animationController; // Entry animation
  late Animation<double> _animation;
  late AnimationController _flyOffController; // Correct answer animation
  late Animation<Offset> _flyOffAnimation;
  late AnimationController _shakeController; // Wrong answer animation
  late Animation<double> _shakeAnimation;

  // Game state variables
  final List<MedicalParameterCase> _cases = [];
  int _currentIndex = 0;
  int _streak = 0; // Only track streak (no score)
  bool _isCorrect = false;
  bool _isAnimating = false; // Flag to prevent multiple animations
  String _errorText = ''; // Text to show at bottom of card for errors

  // Dragging state
  double _dragPosition = 0;
  double _dragVerticalPosition = 0; // Track vertical dragging for swipe down

  @override
  void initState() {
    super.initState();

    // Initialize entry animation controller (cards fly in from top)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Initialize fly-off animation controller (for correct answers)
    _flyOffController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flyOffAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -2.0), // Fly off to top of screen
        ).animate(
          CurvedAnimation(parent: _flyOffController, curve: Curves.easeInQuart),
        );

    // Initialize shake animation controller (for wrong answers)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Create a shake animation that will oscillate side to side
    _shakeAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    // Generate test cases
    _generateTestCases();

    // Start the first card animation (fly in from top)
    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    _animationController.dispose();
    _flyOffController.dispose();
    _shakeController.dispose();
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

      // For normal mode, randomize sex context per card
      // For practice mode, use the selected sex context from settings
      SexContext cardSexContext;
      if (widget.gameMode == GameMode.normal) {
        // Randomly choose male, female, or neutral for each card
        final sexOptions = [
          SexContext.male,
          SexContext.female,
          SexContext.neutral,
        ];
        cardSexContext = sexOptions[random.nextInt(sexOptions.length)];
      } else {
        // Use user-selected sex context for practice mode
        cardSexContext = ref.read(settingsProvider).sexContext;
      }

      final normalRange = parameter.getNormalRangeForSex(cardSexContext);

      double value;

      // Generate a value based on the value type
      switch (valueType) {
        case 0: // Low value
          value =
              normalRange['low']! *
              (0.5 + random.nextDouble() * 0.3); // 50-80% of lower limit
          break;
        case 1: // Normal value
          final rangeMidpoint =
              (normalRange['low']! + normalRange['high']!) / 2;
          final rangeWidth = normalRange['high']! - normalRange['low']!;
          value =
              rangeMidpoint +
              (random.nextDouble() * 0.8 - 0.4) *
                  rangeWidth; // Within ±40% of midpoint
          break;
        case 2: // High value
          value =
              normalRange['high']! *
              (1.2 + random.nextDouble() * 0.6); // 120-180% of upper limit
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
          sexContext: cardSexContext, // Use the card-specific sex context
          difficulty: parameter.difficulty,
        ),
      );
    }

    // Reset the current index
    _currentIndex = 0;
  }

  /// Check if the swipe direction is correct for the current case
  void _checkAnswer(String direction) {
    if (_currentIndex >= _cases.length || _isAnimating) return;

    // Set animating flag to prevent multiple swipes
    _isAnimating = true;

    final currentCase = _cases[_currentIndex];
    final classification = currentCase.getValueClassification();

    bool isCorrect = false;

    // Check if the classification matches the swipe direction
    // Note: Changed 'up' to 'down' for NORMAL values
    if (classification == 'LOW' && direction == 'left') {
      isCorrect = true;
    } else if (classification == 'NORMAL' && direction == 'down') {
      // Changed to 'down'
      isCorrect = true;
    } else if (classification == 'HIGH' && direction == 'right') {
      isCorrect = true;
    }

    // Update streak (no score)
    if (isCorrect) {
      _streak++;
      _errorText = '';

      // Fly off animation for correct answer
      _flyOffController.forward().then((_) {
        if (mounted) {
          _moveToNextCard();
        }
      });
    } else {
      // Reset streak on wrong answer
      _streak = 0;
      _errorText = 'Incorrect! The value is $classification';

      // Shake animation for wrong answer
      _shakeController.forward().then((_) {
        if (mounted) {
          _shakeController.reset();
          _isAnimating = false; // Allow interaction again
        }
      });
    }

    setState(() {
      _isCorrect = isCorrect;
    });
  }

  /// Move to the next card after current card is dismissed
  void _moveToNextCard() {
    if (!mounted) return;

    setState(() {
      _currentIndex++;

      // Reset animation controllers
      _flyOffController.reset();
      _animationController.reset();

      // Generate new cases if we've gone through all of them
      if (_currentIndex >= _cases.length) {
        _generateTestCases();
      }

      // Start the next card animation
      _animationController.forward();
      _isAnimating = false; // Allow interaction again
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current unit system from settings
    final unitSystem = ref.watch(unitSystemProvider);

    // Get the current sex context from settings
    final sexContext = ref.watch(sexContextProvider);

    return Scaffold(
      // Add gradient background
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      // Add exit button to AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.gameMode == GameMode.normal ? 'MedStreak' : 'Practice Mode',
        ),
        actions: [
          // Unit system toggle button
          IconButton(
            icon: Icon(
              unitSystem == UnitSystem.si ? Icons.science : Icons.biotech,
            ),
            tooltip:
                'Toggle ${unitSystem == UnitSystem.si ? "Conventional" : "SI"} Units',
            onPressed: () {
              ref.read(settingsProvider.notifier).toggleUnitSystem();
            },
          ),

          // Sex context selector dropdown - Only show in practice mode
          if (widget.gameMode == GameMode.practice)
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
      body: Container(
        // Gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.purple.shade50],
          ),
        ),
        child: Column(
          children: [
            // Only show streak in top-right during gameplay
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 90, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
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

            // Game instructions - updated for swipe down for normal
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Swipe LEFT for LOW, DOWN for NORMAL, RIGHT for HIGH',
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
                  _buildSwipeIndicator(
                    'NORMAL',
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                  _buildSwipeIndicator(
                    'HIGH',
                    Colors.orange,
                    Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ],
        ),
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
        if (_isAnimating) return; // Prevent interaction during animations
        setState(() {
          _dragPosition += details.delta.dx;
          // Limit the drag distance
          _dragPosition = _dragPosition.clamp(-200.0, 200.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_isAnimating) return; // Prevent interaction during animations
        
        // Add smooth spring animation when returning to center
        if (_dragPosition < -100) {
          // Swiped left - LOW
          _checkAnswer('left');
        } else if (_dragPosition > 100) {
          // Swiped right - HIGH
          _checkAnswer('right');
        } else {
          // Animate back to center with spring physics
          _snapCardBackToCenter();
        }
      },
      onVerticalDragUpdate: (details) {
        if (_isAnimating) return; // Prevent interaction during animations
        setState(() {
          _dragVerticalPosition += details.delta.dy;
          // Limit the drag distance
          _dragVerticalPosition = _dragVerticalPosition.clamp(-200.0, 200.0);
        });
      },
      onVerticalDragEnd: (details) {
        if (_isAnimating) return; // Prevent interaction during animations
        
        if (_dragVerticalPosition > 100) {
          // Swiped DOWN for NORMAL
          _checkAnswer('down');
        } else {
          // Animate back to center with spring physics
          _snapCardBackToCenter();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _animation,
          _flyOffController,
          _shakeController,
        ]),
        builder: (context, child) {
          // Fly-off animation for correct answers
          if (_isCorrect && _flyOffController.isAnimating) {
            return Transform.translate(
              offset: _flyOffAnimation.value,
              child: Opacity(
                opacity: 1.0 - _flyOffController.value,
                child: Transform.scale(scale: _animation.value, child: child),
              ),
            );
          }

          // Shake animation for wrong answers
          if (!_isCorrect && _shakeController.isAnimating) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Transform.scale(scale: _animation.value, child: child),
            );
          }

          // Normal display during standard interaction
          return Transform.translate(
            offset: Offset(_dragPosition, _dragVerticalPosition),
            child: Transform.scale(
              scale: _animation.value,
              child: Opacity(opacity: _animation.value, child: child),
            ),
          );
        },
        child: Card(
          elevation: 8,
          // Add shadows for enhanced visual appeal
          shadowColor: Colors.black54,
          // Add subtle red tint for incorrect answers
          color: _errorText.isNotEmpty ? Colors.red.shade50 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            // Add red border for incorrect answers
            side: _errorText.isNotEmpty
                ? BorderSide(color: Colors.red.shade300, width: 2)
                : BorderSide.none,
          ),
          child: Container(
            // Reduce card size to occupy less space
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parameter name and category with enhanced styling
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parameter.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  // Apply slight color gradient to text
                                  foreground: Paint()
                                    ..shader =
                                        LinearGradient(
                                          colors: [
                                            Colors.blue.shade700,
                                            Colors.indigo.shade900,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 200, 70),
                                        ),
                                ),
                          ),
                          Text(
                            parameter.category,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    // Unit system indicator with enhanced styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: unitSystem == UnitSystem.si
                              ? [Colors.blue.shade100, Colors.blue.shade200]
                              : [
                                  Colors.purple.shade100,
                                  Colors.purple.shade200,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
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
                const SizedBox(height: 20),

                // Parameter value with enhanced styling
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          valueStr,
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          parameter.getUnitString(unitSystem),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Parameter description
                Text(
                  parameter.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),

                // Normal range display - Only show in practice mode
                if (widget.gameMode == GameMode.practice)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Normal Range ',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.normalValueColor),
                        ),
                      ],
                    ),
                  ),

                // Display error text at bottom of card if present
                if (_errorText.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    width: double.infinity,
                    child: Text(
                      _errorText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildFeedbackOverlay method has been removed since we're now using animations and card styling for feedback

  /// Animates the card back to center position with spring physics for natural feel
  void _snapCardBackToCenter() {
    // Set flag to prevent new drags during animation
    setState(() {
      _isAnimating = true;
    });
    
    // Create a spring simulation for natural motion
    const springDescription = SpringDescription(
      mass: 1.0,
      stiffness: 500.0,
      damping: 20.0,
    );
    
    // Use AnimationController for smooth spring animation
    AnimationController springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Track initial positions for smooth animation
    final startDragX = _dragPosition;
    final startDragY = _dragVerticalPosition;
    
    // Create spring animations for both axes
    final springAnimationX = springController.drive(
      Tween<double>(begin: startDragX, end: 0.0)
    );
    
    final springAnimationY = springController.drive(
      Tween<double>(begin: startDragY, end: 0.0)
    );
    
    // Update card position during animation
    springController.addListener(() {
      setState(() {
        _dragPosition = springAnimationX.value;
        _dragVerticalPosition = springAnimationY.value;
      });
    });
    
    // Reset animating flag when complete
    springController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });
        springController.dispose();
      }
    });
    
    // Start the animation with spring curve
    springController.animateWith(
      SpringSimulation(
        springDescription,
        0.0,
        1.0,
        0.0, // No initial velocity
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
