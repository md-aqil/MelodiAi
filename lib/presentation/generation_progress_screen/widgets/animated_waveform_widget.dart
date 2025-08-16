import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AnimatedWaveformWidget extends StatefulWidget {
  final double progress;
  final bool isActive;

  const AnimatedWaveformWidget({
    Key? key,
    required this.progress,
    required this.isActive,
  }) : super(key: key);

  @override
  State<AnimatedWaveformWidget> createState() => _AnimatedWaveformWidgetState();
}

class _AnimatedWaveformWidgetState extends State<AnimatedWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _waveController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _waveController.stop();
    _pulseController.stop();
  }

  @override
  void didUpdateWidget(AnimatedWaveformWidget oldWidget) {
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
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 25.h,
      child: AnimatedBuilder(
        animation: Listenable.merge([_waveAnimation, _pulseAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: WaveformPainter(
              progress: widget.progress,
              wavePhase: _waveAnimation.value,
              pulseScale: widget.isActive ? _pulseAnimation.value : 1.0,
              isActive: widget.isActive,
            ),
            size: Size(80.w, 25.h),
          );
        },
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final double pulseScale;
  final bool isActive;

  WaveformPainter({
    required this.progress,
    required this.wavePhase,
    required this.pulseScale,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          AppTheme.primary.withValues(alpha: 0.8),
          AppTheme.secondary.withValues(alpha: 0.6),
          AppTheme.accent.withValues(alpha: 0.4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final centerY = size.height / 2;
    final barWidth = size.width / 20;
    final spacing = barWidth * 0.5;

    for (int i = 0; i < 20; i++) {
      final x = i * (barWidth + spacing);
      final normalizedI = i / 19.0;

      // Create wave effect
      final waveOffset = sin((normalizedI * 4 * pi) + (wavePhase * 2 * pi));

      // Calculate bar height based on progress and wave
      double baseHeight = size.height * 0.1;
      double maxHeight = size.height * 0.8;

      double barHeight = baseHeight;
      if (isActive) {
        barHeight = baseHeight +
            (maxHeight - baseHeight) *
                (0.3 + 0.7 * (0.5 + 0.5 * waveOffset)) *
                pulseScale;
      } else {
        barHeight = baseHeight + (maxHeight - baseHeight) * progress * 0.5;
      }

      // Draw bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width: barWidth,
          height: barHeight,
        ),
        Radius.circular(barWidth / 4),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}