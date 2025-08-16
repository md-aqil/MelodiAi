import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BackgroundAnimationWidget extends StatefulWidget {
  final bool isActive;

  const BackgroundAnimationWidget({
    Key? key,
    required this.isActive,
  }) : super(key: key);

  @override
  State<BackgroundAnimationWidget> createState() =>
      _BackgroundAnimationWidgetState();
}

class _BackgroundAnimationWidgetState extends State<BackgroundAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    if (widget.isActive) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _gradientController.repeat();
    _particleController.repeat();
  }

  void _stopAnimations() {
    _gradientController.stop();
    _particleController.stop();
  }

  @override
  void didUpdateWidget(BackgroundAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_gradientAnimation, _particleAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: BackgroundPainter(
              gradientPhase: _gradientAnimation.value,
              particlePhase: _particleAnimation.value,
              isActive: widget.isActive,
            ),
            size: Size(100.w, 100.h),
          );
        },
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double gradientPhase;
  final double particlePhase;
  final bool isActive;

  BackgroundPainter({
    required this.gradientPhase,
    required this.particlePhase,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Animated gradient background
    final gradientPaint = Paint()
      ..shader = _createAnimatedGradient(size).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );

    if (isActive) {
      // Draw floating music note particles
      _drawMusicNotes(canvas, size);
    }
  }

  LinearGradient _createAnimatedGradient(Size size) {
    final baseColors = [
      AppTheme.background,
      AppTheme.surface.withValues(alpha: 0.3),
      AppTheme.primary.withValues(alpha: 0.1),
      AppTheme.background,
    ];

    // Animate gradient stops
    final animatedStops = [
      0.0,
      0.3 + 0.2 * sin(gradientPhase * 2 * pi),
      0.7 + 0.2 * cos(gradientPhase * 2 * pi),
      1.0,
    ];

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: baseColors,
      stops: animatedStops,
    );
  }

  void _drawMusicNotes(Canvas canvas, Size size) {
    final notePaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw multiple floating music notes
    for (int i = 0; i < 8; i++) {
      final noteX = (size.width * 0.1) + (i * size.width * 0.12);
      final baseY = size.height * 0.3 + (i % 2) * size.height * 0.4;

      // Animate vertical position
      final animatedY = baseY +
          sin((particlePhase * 2 * pi) + (i * pi / 4)) * size.height * 0.05;

      // Animate opacity
      final opacity = 0.3 + 0.4 * sin((particlePhase * 2 * pi) + (i * pi / 3));

      notePaint.color = AppTheme.primary.withValues(alpha: opacity * 0.2);

      // Draw simple music note shape
      _drawMusicNote(
          canvas, Offset(noteX, animatedY), size.width * 0.02, notePaint);
    }
  }

  void _drawMusicNote(Canvas canvas, Offset center, double size, Paint paint) {
    // Draw note head (circle)
    canvas.drawCircle(center, size, paint);

    // Draw note stem (line)
    final stemStart = Offset(center.dx + size * 0.8, center.dy);
    final stemEnd = Offset(center.dx + size * 0.8, center.dy - size * 3);

    canvas.drawLine(
      stemStart,
      stemEnd,
      paint
        ..strokeWidth = size * 0.2
        ..style = PaintingStyle.stroke,
    );

    // Reset paint style
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}