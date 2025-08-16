import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WaveformVisualizerWidget extends StatefulWidget {
  final double progress;
  final bool isPlaying;
  final Function(double) onSeek;
  final Duration duration;
  final Duration currentPosition;

  const WaveformVisualizerWidget({
    super.key,
    required this.progress,
    required this.isPlaying,
    required this.onSeek,
    required this.duration,
    required this.currentPosition,
  });

  @override
  State<WaveformVisualizerWidget> createState() =>
      _WaveformVisualizerWidgetState();
}

class _WaveformVisualizerWidgetState extends State<WaveformVisualizerWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<double> _waveformData = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _generateWaveformData();

    if (widget.isPlaying) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveformVisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateWaveformData() {
    final random = math.Random();
    _waveformData = List.generate(100, (index) {
      return 0.2 + random.nextDouble() * 0.8;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(widget.currentPosition),
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatDuration(widget.duration),
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Waveform visualization
          GestureDetector(
            onTapDown: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final progress =
                  (localPosition.dx / box.size.width).clamp(0.0, 1.0);
              widget.onSeek(progress);
            },
            onPanUpdate: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final progress =
                  (localPosition.dx / box.size.width).clamp(0.0, 1.0);
              widget.onSeek(progress);
            },
            child: Container(
              height: 15.h,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WaveformPainter(
                      waveformData: _waveformData,
                      progress: widget.progress,
                      isPlaying: widget.isPlaying,
                      animationValue: _animation.value,
                      primaryColor: AppTheme.darkTheme.colorScheme.primary,
                      secondaryColor: AppTheme
                          .darkTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Progress indicator
          Container(
            height: 0.5.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  final bool isPlaying;
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  WaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.isPlaying,
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth;
      final normalizedProgress = progress * waveformData.length;
      final isActive = i <= normalizedProgress;

      // Calculate bar height with animation
      double barHeight = waveformData[i] * size.height * 0.8;
      if (isPlaying && isActive) {
        barHeight *=
            (0.8 + 0.2 * math.sin(animationValue * 2 * math.pi + i * 0.1));
      }

      paint.color = isActive ? primaryColor : secondaryColor;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width: barWidth * 0.7,
          height: barHeight,
        ),
        Radius.circular(barWidth * 0.35),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
