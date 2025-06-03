import 'dart:math';
import 'package:flutter/material.dart';

/// Widget that creates a glitter trail effect behind dragged cards
class CardTrailEffect extends StatefulWidget {
  final Offset dragPosition;
  final bool isActive;

  const CardTrailEffect({
    super.key,
    required this.dragPosition,
    required this.isActive,
  });

  @override
  State<CardTrailEffect> createState() => _CardTrailEffectState();
}

class _CardTrailEffectState extends State<CardTrailEffect> with SingleTickerProviderStateMixin {
  final List<GlitterParticle> _particles = [];
  final Random _random = Random();
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    
    // Create animation controller for continuous updates
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();
    
    // Add listener to update particles
    _controller.addListener(_updateParticles);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _updateParticles() {
    if (!mounted) return;
    
    // Only generate particles if card is being dragged
    if (widget.isActive && widget.dragPosition != Offset.zero) {
      // Add new particles at the current drag position
      if (_random.nextDouble() < 0.5) { // Control density of particles
        _addParticle();
      }
    }
    
    // Update existing particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      final particle = _particles[i];
      
      // Update age and fade out
      particle.age += 0.05;
      
      // Remove old particles
      if (particle.age > 1.0) {
        _particles.removeAt(i);
      }
    }
    
    // Force rebuild to show updated particles
    if (mounted) setState(() {});
  }
  
  void _addParticle() {
    // Add slight randomness to position for natural effect
    final offset = Offset(
      widget.dragPosition.dx + (_random.nextDouble() * 10) - 5,
      widget.dragPosition.dy + (_random.nextDouble() * 10) - 5,
    );
    
    _particles.add(GlitterParticle(
      position: offset,
      size: 1 + _random.nextDouble() * 2,
      color: _getRandomColor(),
      age: 0.0,
    ));
  }
  
  Color _getRandomColor() {
    // Return a random glitter color
    final colors = [
      Colors.white,
      Colors.cyan.shade200,
      Colors.teal.shade200,
      Colors.blue.shade200,
      Colors.amber.shade100,
    ];
    
    return colors[_random.nextInt(colors.length)];
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: GlitterPainter(_particles),
        ),
      ),
    );
  }
}

/// Painter for the glitter particles
class GlitterPainter extends CustomPainter {
  final List<GlitterParticle> particles;
  
  GlitterPainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Skip particles outside the visible area
      if (particle.position.dx < 0 || 
          particle.position.dx > size.width ||
          particle.position.dy < 0 || 
          particle.position.dy > size.height) {
        continue;
      }
      
      // Fade out based on age
      final opacity = 1.0 - particle.age;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      // Draw tiny glitter particle
      canvas.drawCircle(particle.position, particle.size, paint);
      
      // Add sparkle effect
      if (particle.age < 0.3 && particle.size > 1.5) {
        final glowPaint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(particle.position, particle.size * 1.5, glowPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Glitter particle class
class GlitterParticle {
  Offset position;
  double size;
  Color color;
  double age; // 0.0 to 1.0, where 1.0 means the particle is no longer visible
  
  GlitterParticle({
    required this.position,
    required this.size,
    required this.color,
    required this.age,
  });
}
