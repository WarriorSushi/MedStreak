import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart'; // Add physics package for spring animations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/services/sound_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/med_streak_app_bar.dart';
import '../../../../features/game/domain/models/medical_parameter.dart';
import '../../../../features/game/presentation/widgets/card_trail_effect.dart';
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
  late AnimationController _entryController; // Card entry from top
  late Animation<Offset> _entryAnimation;
  late AnimationController _flyOffController; // Correct answer fly-off
  late Animation<Offset> _flyOffAnimation;
  late AnimationController _snapBackController; // Wrong answer snap-back
  late Animation<Offset> _snapBackAnimation;
  
  // Sound service for sound effects
  late SoundService _soundService;

  // Game state variables
  final List<MedicalParameterCase> _cases = [];
  int _currentIndex = 0;
  int _streak = 0; // Only track streak (no score)
  bool _isAnimating = false; // Flag to prevent multiple animations
  String _errorText = ''; // Text to show at bottom of card for errors
  bool _showCorrectOverlay = false; // Show green tint for correct answers

  // Dragging state
  Offset _dragPosition = Offset.zero; // Track both x and y position
  Offset _lastVelocity = Offset.zero; // Track velocity for flick gestures

  // Swipe detection constants
  static const double _swipeThreshold = 140.0; // Pixels to trigger answer
  static const double _maxDragDistance = 200.0; // Maximum drag before auto-trigger
  static const double _flickVelocityThreshold = 800.0; // Velocity threshold for flicks

  @override
  void initState() {
    super.initState();

    // Initialize sound service
    _soundService = ref.read(soundServiceProvider);
    _soundService.initialize();

    // Initialize entry animation controller (cards slide down from top)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _entryAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2), // Start above screen
      end: Offset.zero, // End at center
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    // Initialize fly-off animation controller (for correct answers)
    _flyOffController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // This will be set dynamically based on swipe direction
    _flyOffAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0), // Default to right
    ).animate(
      CurvedAnimation(parent: _flyOffController, curve: Curves.easeInQuart),
    );

    // Initialize snap-back animation controller (for wrong answers)
    _snapBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _snapBackAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _snapBackController, curve: Curves.elasticOut),
    );

    // Generate test cases
    _generateTestCases();

    // Start the first card animation
    _entryController.forward();
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    _entryController.dispose();
    _flyOffController.dispose();
    _snapBackController.dispose();
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

  /// Get swipe direction from position or velocity
  String? _getSwipeDirection(Offset position, Offset velocity) {
    // Use velocity if it's strong enough, otherwise use position
    final bool useVelocity = velocity.distance > _flickVelocityThreshold;
    final Offset reference = useVelocity ? velocity : position;
    
    if (reference.distance < (useVelocity ? _flickVelocityThreshold : _swipeThreshold)) {
      return null; // Not enough movement
    }

    final double angle = atan2(reference.dy, reference.dx) * 180 / pi;
    
    // Determine direction based on angle
    if (angle >= -45 && angle < 45) {
      return 'right'; // HIGH
    } else if (angle >= 45 && angle < 135) {
      return 'down'; // NORMAL
    } else if ((angle >= 135 && angle <= 180) || (angle >= -180 && angle < -135)) {
      return 'left'; // LOW
    }
    
    return null; // Invalid direction (up)
  }

  /// Get fly-off direction offset for correct answers
  Offset _getFlyOffDirection(String direction) {
    switch (direction) {
      case 'left':
        return const Offset(-2.5, 0); // Fly left
      case 'right':
        return const Offset(2.5, 0); // Fly right
      case 'down':
        return const Offset(0, 1.5); // Fly down (less distance)
      default:
        return const Offset(2.0, 0); // Default right
    }
  }

  /// Check if the swipe direction is correct for the current case
  void _checkAnswer(String direction) {
    if (_currentIndex >= _cases.length || _isAnimating) return;

    // Set animating flag to prevent multiple interactions
    _isAnimating = true;

    final currentCase = _cases[_currentIndex];
    final classification = currentCase.getValueClassification();

    bool isCorrect = false;

    // Check if the classification matches the swipe direction
    if (classification == 'LOW' && direction == 'left') {
      isCorrect = true;
    } else if (classification == 'NORMAL' && direction == 'down') {
      isCorrect = true;
    } else if (classification == 'HIGH' && direction == 'right') {
      isCorrect = true;
    }

    // Play sound based on answer correctness
    final soundEnabled = ref.read(soundEnabledProvider);
    if (soundEnabled) {
      if (isCorrect) {
        _soundService.playCorrectSwipeSound(soundEnabled);
      } else {
        _soundService.playWrongSwipeSound(soundEnabled);
      }
    }

    if (isCorrect) {
      // Correct answer handling
      _streak++;
      _errorText = '';
      
      // Show green overlay
      setState(() {
        _showCorrectOverlay = true;
      });

      // Set up fly-off animation in the correct direction
      _flyOffAnimation = Tween<Offset>(
        begin: _dragPosition,
        end: _dragPosition + _getFlyOffDirection(direction),
      ).animate(
        CurvedAnimation(parent: _flyOffController, curve: Curves.easeInQuart),
      );

      // Start fly-off animation
      _flyOffController.forward().then((_) {
        if (mounted) {
          _moveToNextCard();
        }
      });
    } else {
      // Wrong answer handling
      _streak = 0;
      _errorText = 'Incorrect! The value is $classification';
      
      // Set up snap-back animation from current position to center
      _snapBackAnimation = Tween<Offset>(
        begin: _dragPosition,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _snapBackController, curve: Curves.elasticOut),
      );

      // Start snap-back animation
      _snapBackController.forward().then((_) {
        if (mounted) {
          _snapBackController.reset();
          setState(() {
            _dragPosition = Offset.zero;
            _isAnimating = false; // Allow interaction again
          });
        }
      });
    }
  }

  /// Move to the next card after current card is dismissed
  void _moveToNextCard() {
    if (!mounted) return;

    setState(() {
      _currentIndex++;
      _showCorrectOverlay = false;

      // Reset animation controllers and positions
      _flyOffController.reset();
      _entryController.reset();
      _snapBackController.reset();
      _dragPosition = Offset.zero;

      // Generate new cases if we've gone through all of them
      if (_currentIndex >= _cases.length) {
        _generateTestCases();
      }

      // Start the next card entry animation
      _entryController.forward();
      _isAnimating = false; // Allow interaction again
    });
  }

  /// Snap card back to center with spring animation
  void _snapCardBackToCenter() {
    if (!mounted || _isAnimating) return;
    
    _isAnimating = true;
    
    // Play snap sound effect if enabled
    final soundEnabled = ref.read(soundEnabledProvider);
    if (soundEnabled) {
      _soundService.playSnapSound(soundEnabled);
    }
    
    // Set up snap-back animation from current position to center
    _snapBackAnimation = Tween<Offset>(
      begin: _dragPosition,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _snapBackController, curve: Curves.elasticOut),
    );

    // Start snap-back animation
    _snapBackController.forward().then((_) {
      if (mounted) {
        _snapBackController.reset();
        setState(() {
          _dragPosition = Offset.zero;
          _isAnimating = false;
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
      // Add gradient background
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      // Add custom app bar with back button and unit system toggle
      appBar: MedStreakAppBar(
        title: widget.gameMode == GameMode.normal ? 'MedStreak' : 'Practice Mode',
        showBackButton: widget.gameMode != GameMode.normal, // Don't show back button on main game screen
        enableSound: ref.read(soundEnabledProvider),
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
        // Lighter gradient background for all modes
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.gameMode == GameMode.normal 
                ? [Colors.blue.shade50, Colors.cyan.shade100, Colors.teal.shade50] // Lighter gradient for normal mode
                : [Colors.blue.shade100, Colors.purple.shade50], // Keep lighter colors for practice mode
          ),
        ),
        child: Stack(
          children: [
            // Card trail effect
            CardTrailEffect(
              dragPosition: _dragPosition,
              isActive: _dragPosition != Offset.zero && !_isAnimating,
            ),
              
            // Main content
            Column(
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
      onPanStart: (details) {
        if (_isAnimating) return;
        _lastVelocity = Offset.zero;
      },
      onPanUpdate: (details) {
        if (_isAnimating) return;
        
        setState(() {
          // Update drag position
          _dragPosition += details.delta;
          _lastVelocity = details.delta;
          
          // Apply soft boundary - allow going beyond but with resistance
          final distance = _dragPosition.distance;
          if (distance > _maxDragDistance) {
            // Apply resistance when beyond max distance
            _dragPosition = _dragPosition * (_maxDragDistance / distance);
            
            // Auto-trigger if at maximum boundary
            final direction = _getSwipeDirection(_dragPosition, Offset.zero);
            if (direction != null) {
              // Small delay to prevent multiple triggers
              Future.delayed(const Duration(milliseconds: 50), () {
                if (!_isAnimating) {
                  _checkAnswer(direction);
                }
              });
            }
          }
        });
      },
      onPanEnd: (details) {
        if (_isAnimating) return;
        
        // Play swipe sound if enabled and sufficient movement
        final soundEnabled = ref.read(soundEnabledProvider);
        if (soundEnabled && _dragPosition.distance > 50) {
          _soundService.playSound('swipe', soundEnabled);
        }
        
        // Check for strong flick gesture first
        final flickDirection = _getSwipeDirection(Offset.zero, details.velocity.pixelsPerSecond);
        if (flickDirection != null) {
          _checkAnswer(flickDirection);
          return;
        }
        
        // Check based on position
        final positionDirection = _getSwipeDirection(_dragPosition, Offset.zero);
        if (positionDirection != null) {
          _checkAnswer(positionDirection);
        } else {
          // Not enough movement, snap back to center
          _snapCardBackToCenter();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _entryController,
          _flyOffController,
          _snapBackController,
        ]),
        builder: (context, child) {
          Offset currentOffset = _dragPosition;
          double opacity = 1.0;
          
          // Entry animation (slide down from top)
          if (_entryController.isAnimating) {
            currentOffset = _entryAnimation.value * MediaQuery.of(context).size.height;
            opacity = _entryController.value;
          }
          
          // Fly-off animation for correct answers
          else if (_flyOffController.isAnimating) {
            currentOffset = _flyOffAnimation.value * MediaQuery.of(context).size.width;
            opacity = 1.0 - _flyOffController.value * 0.3; // Slight fade
          }
          
          // Snap-back animation for wrong answers
          else if (_snapBackController.isAnimating) {
            currentOffset = _snapBackAnimation.value;
          }

          return Transform.translate(
            offset: currentOffset,
            child: Transform.rotate(
              // Add slight rotation based on horizontal position
              angle: currentOffset.dx * 0.001,
              child: Opacity(
                opacity: opacity,
                child: Stack(
                  children: [
                    // Main card
                    child!,
                    
                    // Green overlay for correct answers
                    if (_showCorrectOverlay)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 80,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        child: Card(
          elevation: 8,
          shadowColor: Colors.black54,
          color: _errorText.isNotEmpty ? Colors.red.shade50 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: _errorText.isNotEmpty
                ? BorderSide(color: Colors.red.shade300, width: 2)
                : BorderSide.none,
          ),
          child: Container(
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