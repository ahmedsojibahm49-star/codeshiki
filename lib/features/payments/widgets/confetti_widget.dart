import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../../theme/app_colors.dart';

/// Lightweight confetti: ~24 small colored rectangles falling with
/// rotation, driven by a single [AnimationController] for ~2.5s, then
/// stopping. No package — pure [CustomPaint].
class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({super.key});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.size,
    required this.delay,
    required this.drift,
    required this.spin,
    required this.colorIndex,
  });

  final double x; // 0.0–1.0 across the width
  final double startY; // 0.0–1.0 down the height
  final double size;
  final double delay; // 0.0–0.4 of the animation
  final double drift; // horizontal sway in logical pixels
  final double spin; // total rotation in radians
  final int colorIndex;
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();
    final random = Random(42);
    _particles = List.generate(24, (_) {
      return _ConfettiParticle(
        x: random.nextDouble(),
        startY: random.nextDouble() * 0.3,
        size: 6 + random.nextDouble() * 7,
        delay: random.nextDouble() * 0.35,
        drift: 12 + random.nextDouble() * 28,
        spin: (random.nextDouble() * 4 - 2) * pi,
        colorIndex: random.nextInt(6),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final colors = <Color>[
      cs.primary,
      cs.teal,
      cs.success,
      cs.warning,
      cs.info,
      cs.accent,
    ];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            progress: _controller.value,
            particles: _particles,
            colors: colors,
          ),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.progress,
    required this.particles,
    required this.colors,
  });

  final double progress;
  final List<_ConfettiParticle> particles;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final local = ((progress - particle.delay) / (1 - particle.delay))
          .clamp(0.0, 1.0);
      if (local <= 0) continue;
      final x = particle.x * size.width +
          sin(local * pi * 2 + particle.x * 6) * particle.drift;
      final y = particle.startY * size.height + local * size.height * 0.9;
      final fade = local > 0.85 ? (1 - local) / 0.15 : 1.0;
      final paint = Paint()
        ..color = colors[particle.colorIndex % colors.length]
            .withValues(alpha: fade.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.spin * local);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
