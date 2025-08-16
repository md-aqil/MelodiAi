import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final double progress;
  final bool isActive;

  const ProgressIndicatorWidget({
    Key? key,
    required this.progress,
    required this.isActive,
  }) : super(key: key);

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use circular progress for iOS, linear for Android
    final bool useCircular = Platform.isIOS;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _scaleAnimation.value : 1.0,
          child:
              useCircular ? _buildCircularProgress() : _buildLinearProgress(),
        );
      },
    );
  }

  Widget _buildCircularProgress() {
    return Container(
      width: 25.w,
      height: 25.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          // Progress circle
          SizedBox(
            width: 22.w,
            height: 22.w,
            child: CircularProgressIndicator(
              value: widget.progress,
              strokeWidth: 1.w,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isActive ? AppTheme.primary : AppTheme.secondary,
              ),
            ),
          ),
          // Progress text
          Text(
            '${(widget.progress * 100).toInt()}%',
            style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinearProgress() {
    return Container(
      width: 70.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Progress bar
          Container(
            height: 1.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0.5.h),
              color: AppTheme.primary.withValues(alpha: 0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.5.h),
              child: LinearProgressIndicator(
                value: widget.progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isActive ? AppTheme.primary : AppTheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
