import 'dart:math';
import 'package:flutter/material.dart';

/// Widget that creates a particle effect background with floating stars and fireflies
class ParticleBackgroundEffect extends StatefulWidget {
  const ParticleBackgroundEffect({super.key});

  @override
  State<ParticleBackgroundEffect> createState() => _ParticleBackgroundEffectState();
}

class _ParticleBackgroundEffectState extends State<ParticleBackgroundEffect> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    
    // Create animation controller for continuous updates
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    // Add listener to update particles
    _controller.addListener(_updateParticles);
    
    // Create initial particles
    _createParticles();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _createParticles() {
    // Create firefly particles
    for (int i = 0; i < 40; i++) {
      _particles.add(Particle(
        type: ParticleType.firefly,
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 800,
        ),
        speed: Offset(
          (_random.nextDouble() - 0.5) * 0.8,
          (_random.nextDouble() - 0.5) * 0.8,
        ),
        size: 2 + _random.nextDouble() * 3,
        opacity: 0.1 + _random.nextDouble() * 0.6,
        glowRadius: 4 + _random.nextDouble() * 4,
      ));
    }
    
    // Create star particles
    for (int i = 0; i < 60; i++) {
      _particles.add(Particle(
        type: ParticleType.star,
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 800,
        ),
        speed: Offset.zero, // Stars don't move
        size: 1 + _random.nextDouble() * 2,
        opacity: 0.3 + _random.nextDouble() * 0.7,
        glowRadius: 1 + _random.nextDouble() * 2,
      ));
    }
  }
  
  void _updateParticles() {
    if (!mounted) return;
    
    for (final particle in _particles) {
      if (particle.type == ParticleType.firefly) {
        // Update position
        particle.position += particle.speed;
        
        // Bounce off edges with a small buffer zone
        final size = MediaQuery.of(context).size;
        if (particle.position.dx < 0 || particle.position.dx > size.width) {
          particle.speed = Offset(-particle.speed.dx, particle.speed.dy);
        }
        if (particle.position.dy < 0 || particle.position.dy > size.height) {
          particle.speed = Offset(particle.speed.dx, -particle.speed.dy);
        }
        
        // Randomly change opacity to create twinkling effect
        if (_random.nextDouble() < 0.02) {
          particle.opacity = 0.1 + _random.nextDouble() * 0.9;
        }
      } else if (particle.type == ParticleType.star) {
        // Stars twinkle but don't move
        if (_random.nextDouble() < 0.01) {
          particle.opacity = 0.3 + _random.nextDouble() * 0.7;
        }
      }
    }
    
    // Force rebuild to show updated particles
    if (mounted) setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: ParticlePainter(_particles),
      ),
    );
  }
}

/// Particle painter that renders all particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  
  ParticlePainter(this.particles);
  
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
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity);
      
      if (particle.type == ParticleType.firefly) {
        // Draw firefly with glow effect
        if (particle.glowRadius > 0) {
          final glowPaint = Paint()
            ..color = Colors.white.withOpacity(particle.opacity * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
          canvas.drawCircle(particle.position, particle.glowRadius, glowPaint);
        }
        canvas.drawCircle(particle.position, particle.size, paint);
      } else if (particle.type == ParticleType.star) {
        // Draw star as a simple point
        canvas.drawCircle(particle.position, particle.size, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Particle types
enum ParticleType {
  firefly,
  star,
}

/// Particle class to store properties of each particle
class Particle {
  ParticleType type;
  Offset position;
  Offset speed;
  double size;
  double opacity;
  double glowRadius;
  
  Particle({
    required this.type,
    required this.position,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.glowRadius,
  });
}
