import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart'; // Add physics package for spring animations
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/services/sound_service.dart';
import '../../../../core/theme/app_theme.dart';
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
  late AnimationController _animationController; // Entry animation
  late Animation<double> _animation;
  late AnimationController _flyOffController; // Correct answer animation
  late Animation<Offset> _flyOffAnimation;
  late AnimationController _shakeController; // Wrong answer animation
  late Animation<double> _shakeAnimation;
  
  // Sound service for sound effects
  late SoundService _soundService;

  // Game state variables
  final List<MedicalParameterCase> _cases = [];
  int _currentIndex = 0;
  int _streak = 0; // Only track streak (no score)
  bool _isCorrect = false;
  bool _isAnimating = false; // Flag to prevent multiple animations
  String _errorText = ''; // Text to show at bottom of card for errors

  // Dragging state
  Offset _dragPosition = Offset.zero; // Track both x and y position
  Offset _dragVelocity = Offset.zero; // Track velocity for flick gestures

  @override
  void initState() {
    super.initState();

    // Initialize sound service
    _soundService = ref.read(soundServiceProvider);
    _soundService.initialize();

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
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    // Get current case
    final MedicalParameterCase currentCase = _cases[_currentIndex];
    String correctDirection = '';

    // Get normal range for current sex context
    final sexContext = ref.read(sexContextProvider);
    final normalRange = currentCase.parameter.getNormalRangeForSex(sexContext);
    final lowThreshold = normalRange['low']!;
    final highThreshold = normalRange['high']!;

    // Determine correct answer
    if (currentCase.value < lowThreshold) {
      correctDirection = 'left'; // Low
    } else if (currentCase.value > highThreshold) {
      correctDirection = 'right'; // High
    } else {
      correctDirection = 'down'; // Normal
    }

    // Check if direction matches
    _isCorrect = direction == correctDirection;

    // Apply appropriate animation/feedback
    if (_isCorrect) {
      // Correct answer - play sound if enabled
      final soundEnabled = ref.read(soundEnabledProvider);
      if (soundEnabled) {
        _soundService.playCorrectSwipeSound(soundEnabled);
      }

      // Update streak for normal mode only
      if (widget.gameMode == GameMode.normal) {
        setState(() {
          _streak++;
        });
      }

      // Set up the fly off animation based on the direction swiped
      Offset flyOffDirection;
      switch (direction) {
        case 'left':
          flyOffDirection = const Offset(-2.0, 0); // Fly left
          break;
        case 'right':
          flyOffDirection = const Offset(2.0, 0); // Fly right
          break;
        case 'down':
          flyOffDirection = const Offset(0, 2.0); // Fly down
          break;
        default:
          flyOffDirection = const Offset(0, -2.0); // Default fly up
      }

      // Update the fly-off animation with the correct direction
      _flyOffAnimation = Tween<Offset>(
        begin: _dragPosition,
        end: flyOffDirection,
      ).animate(
        CurvedAnimation(parent: _flyOffController, curve: Curves.easeOutQuint),
      );

      // Fly off animation
      _flyOffController.reset();
      _flyOffController.forward().then((_) {
        if (mounted) {
          setState(() {
            _isAnimating = false;
            _errorText = '';
            _dragPosition = Offset.zero;
          });
          _moveToNextCard();
        }
      });
    } else {
      // Wrong answer
      final soundEnabled = ref.read(soundEnabledProvider);
      if (soundEnabled) {
        _soundService.playWrongSwipeSound(soundEnabled);
      }

      // Reset streak for normal mode
      if (widget.gameMode == GameMode.normal) {
        setState(() {
          _streak = 0;
        });
      }

      // Show error text for practice mode
      if (widget.gameMode == GameMode.practice) {
        setState(() {
          _errorText = 'This value is ${_getCorrectAnswerText(correctDirection)}';
        });
      }

      // Snap back to center with a shake
      _snapCardBackToCenter();
    }
  }

  /// Move to the next card after current card is dismissed
  void _moveToNextCard() {
    if (!mounted) return;

    setState(() {
      _currentIndex++;

      // Reset animation controllers
      _flyOffController.reset();
      _animationController.reset();
      
      // Reset drag position to center for new card
      _dragPosition = Offset.zero;

      // Generate new cases if we've gone through all of them
      if (_currentIndex >= _cases.length) {
        _generateTestCases();
      }

      // Start the next card animation
      _animationController.forward();
      _isAnimating = false; // Allow interaction again
    });
  }

  /// Calculate angle in degrees from an offset (0 degrees is right, 90 is down)
  double _getAngleFromOffset(Offset offset) {
    // Calculate the angle in radians and convert to degrees
    final double radians = atan2(offset.dy, offset.dx);
    return radians * (180 / pi); // Convert to degrees
  }
  
  /// Process a flick gesture based on velocity
  /// NOTE: This is an alternative implementation currently not in use
  /// but kept for reference in case the physics-based approach needs adjustment
  // ignore: unused_element
  void _processFlickGesture(Offset velocity) {
    // Define threshold for flick detection
    const flickThreshold = 500.0;
    final absX = velocity.dx.abs();
    final absY = velocity.dy.abs();

    if (absX > flickThreshold && absX > absY) {
      // Horizontal flick - determine direction
      if (velocity.dx > 0) {
        _checkAnswer('right'); // Right flick = HIGH
      } else {
        _checkAnswer('left'); // Left flick = LOW
      }
    } else if (absY > flickThreshold && absY > absX) {
      // Vertical flick - only care about downward for normal
      if (velocity.dy > 0) {
        _checkAnswer('down'); // Down flick = NORMAL
      }
    }
  }
  
  /// Get text description of the correct answer
  String _getCorrectAnswerText(String direction) {
    switch (direction) {
      case 'left':
        return 'LOW';
      case 'right':
        return 'HIGH';
      case 'down':
        return 'NORMAL';
      default:
        return '';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Get current settings from providers
    final unitSystem = ref.watch(unitSystemProvider);
    final sexContext = ref.watch(sexContextProvider);

    return Scaffold(
      // Dark gradient background for normal mode, regular for practice mode
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      // Semi-transparent app bar with back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.gameMode == GameMode.normal ? 'Normal Mode' : 'Practice Mode',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // Add back button to return to main menu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        // Dark gradient background for normal mode as requested
        decoration: widget.gameMode == GameMode.normal
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF222831), // Dark navy
                    Color(0xFF131B28), // Very dark blue
                    Color(0xFF003B2F), // Dark teal
                  ],
                ),
              )
            : null, // No gradient for practice mode
        child: SafeArea(
          child: Stack(
            children: [
              // Card trail effect
              CardTrailEffect(
                dragPosition: _dragPosition,
                isActive: _dragPosition != Offset.zero,
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
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: widget.gameMode == GameMode.normal
                                          ? Colors.yellow.shade300 // Neon yellow for normal mode
                                          : Theme.of(context).textTheme.headlineSmall?.color,
                                      shadows: widget.gameMode == GameMode.normal
                                          ? [
                                              Shadow(
                                                color: Colors.yellow.shade100.withAlpha(128),
                                                blurRadius: 8,
                                                offset: const Offset(0, 0),
                                              ),
                                            ]
                                          : null,
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
                        // Low indicator
                        _buildSwipeIndicator(
                          'Low', 
                          widget.gameMode == GameMode.normal
                            ? const Color(0xFF00FFFF) // Cyan neon
                            : Colors.blue,
                          Icons.arrow_back
                        ),
                        // Normal indicator
                        _buildSwipeIndicator(
                          'Normal', 
                          widget.gameMode == GameMode.normal
                            ? const Color(0xFF00FF00) // Green neon
                            : Colors.green,
                          Icons.arrow_downward
                        ),
                        // High indicator
                        _buildSwipeIndicator(
                          'High', 
                          widget.gameMode == GameMode.normal
                            ? const Color(0xFFFF2E63) // Pink neon
                            : Colors.red,
                          Icons.arrow_forward
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    final parameter = paramCase.parameter;
    final value = paramCase.value;

    // Get the normal range for the current sex context
    final normalRange = parameter.getNormalRangeForSex(sexContext);
    final lowThreshold = normalRange['low']!;
    final highThreshold = normalRange['high']!;
    
    // Get formatted value and reference values
    final valueStr = _formatValue(value);
    final lowValueStr = _formatValue(lowThreshold);
    final highValueStr = _formatValue(highThreshold);
    
    // Set text colors based on game mode
    final Color textColor = widget.gameMode == GameMode.normal 
        ? Colors.white // White text for dark background in normal mode
        : Colors.black87; // Dark text for light background in practice mode

    // We already have the normal range values defined above
    // No need for additional variables

    return GestureDetector(
      // Using Pan gesture detector to handle all directions at once
      onPanStart: (details) {
        if (_isAnimating) return;
        _dragVelocity = Offset.zero; // Reset velocity on new drag
      },
      onPanUpdate: (details) {
        if (_isAnimating) return; // Prevent interaction during animations
        setState(() {
          // Update drag position
          _dragPosition += details.delta;
          
          // Store velocity for flick gesture
          _dragVelocity = details.delta * 0.8 + _dragVelocity * 0.2; // Weighted average for smoother velocity
          
          // Limit the drag distance with a circular boundary (allows any angle)
          final double distance = _dragPosition.distance;
          if (distance > 220.0) {
            _dragPosition = _dragPosition * (220.0 / distance);
          }
        });
      },
      onPanEnd: (details) {
        if (_isAnimating) return; // Prevent interaction during animations
        
        // Get the total velocity for flick detection
        final double flickVelocity = _dragVelocity.distance;
        final double dragDistance = _dragPosition.distance;
        final double dragAngle = _getAngleFromOffset(_dragPosition);
        
        // Play swipe sound if enabled
        final soundEnabled = ref.read(soundEnabledProvider);
        if (soundEnabled && (dragDistance > 100 || flickVelocity > 15)) {
          _soundService.playSound('swipe', soundEnabled);
        }
        
        // Added check for cards stuck at border
        if (dragDistance >= 220) {
          // Card is at the edge, automatically process as a swipe in 3ms
          Future.delayed(const Duration(milliseconds: 3), () {
            if (dragAngle >= -45 && dragAngle < 45) {
              _checkAnswer('right'); // RIGHT - HIGH
              return;
            } else if (dragAngle >= 45 && dragAngle < 135) {
              _checkAnswer('down');  // DOWN - NORMAL
              return;
            } else if ((dragAngle >= 135 && dragAngle <= 180) || 
                      (dragAngle >= -180 && dragAngle < -135)) {
              _checkAnswer('left');  // LEFT - LOW
              return;
            } else {
              _snapCardBackToCenter();
            }
          });
          return;
        }
        
        // Check if card was flicked (high velocity)
        if (flickVelocity > 20) {
          // Process flick gesture based on velocity angle
          final double velocityAngle = _getAngleFromOffset(_dragVelocity);
          
          if (velocityAngle >= -45 && velocityAngle < 45) {
            _checkAnswer('right'); // RIGHT - HIGH
          } else if (velocityAngle >= 45 && velocityAngle < 135) {
            _checkAnswer('down');  // DOWN - NORMAL
          } else if ((velocityAngle >= 135 && velocityAngle <= 180) || 
                    (velocityAngle >= -180 && velocityAngle < -135)) {
            _checkAnswer('left');  // LEFT - LOW
          } else {
            _snapCardBackToCenter(); // Other directions snap back
          }
        }
        // Check based on position if not flicked
        else if (dragDistance > 100) {
          // Determine direction based on angle
          if (dragAngle >= -45 && dragAngle < 45) {
            _checkAnswer('right'); // RIGHT - HIGH
          } else if (dragAngle >= 45 && dragAngle < 135) {
            _checkAnswer('down');  // DOWN - NORMAL
          } else if ((dragAngle >= 135 && dragAngle <= 180) || 
                    (dragAngle >= -180 && dragAngle < -135)) {
            _checkAnswer('left');  // LEFT - LOW
          } else {
            _snapCardBackToCenter(); // Other directions snap back
          }
        } else {
          // Not dragged far enough, snap back
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

          // Normal display during standard interaction with rotation
          return Transform.translate(
            offset: _dragPosition,
            child: Transform.rotate(
              // Add slight rotation based on horizontal position for a more natural feel
              angle: _dragPosition.dx * 0.002, // Convert to radians for subtle rotation
              child: Transform.scale(
                scale: _animation.value,
                child: Opacity(opacity: _animation.value, child: child),
              ),
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
                            style: TextStyle(
                              color: textColor,
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
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
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
                          color: Colors.black.withAlpha(13),
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
                          color: Colors.black.withAlpha(13),
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
    if (!mounted) return;
    
    // Set flag to prevent new drags during animation
    setState(() {
      _isAnimating = true;
    });
    
    // Create a stronger spring simulation for snappier feel
    const springDescription = SpringDescription(
      mass: 1.0,
      stiffness: 800.0, // Increased stiffness for stronger snap
      damping: 15.0, // Reduced damping for more bounce
    );
    
    // Use AnimationController for smooth spring animation
    AnimationController springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Faster snap
    );
    
    // Track initial positions for smooth animation
    final Offset startPosition = _dragPosition;
    
    // Create spring animation for both axes
    final Animation<Offset> springAnimation = springController.drive(
      Tween<Offset>(
        begin: startPosition,
        end: Offset.zero,
      ),
    );
    
    // Play snap sound effect if enabled
    final soundEnabled = ref.read(soundEnabledProvider);
    if (soundEnabled) {
      _soundService.playSnapSound(soundEnabled);
    }
    
    springController.addListener(() {
      if (mounted) {
        setState(() {
          _dragPosition = springAnimation.value;
        });
      }
    });
    
    // Reset animating flag when complete
    springController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
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
