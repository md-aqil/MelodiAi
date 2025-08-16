import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SkeletonLoadingWidget extends StatefulWidget {
  final int itemCount;

  const SkeletonLoadingWidget({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  State<SkeletonLoadingWidget> createState() => _SkeletonLoadingWidgetState();
}

class _SkeletonLoadingWidgetState extends State<SkeletonLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemCount,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            _buildSkeletonThumbnail(),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonLine(width: 60.w),
                  SizedBox(height: 1.h),
                  _buildSkeletonLine(width: 40.w),
                  SizedBox(height: 0.5.h),
                  _buildSkeletonLine(width: 30.w),
                ],
              ),
            ),
            _buildSkeletonCircle(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonThumbnail() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color:
              AppTheme.textSecondary.withValues(alpha: _animation.value * 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSkeletonLine({required double width}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: width,
        height: 2.h,
        decoration: BoxDecoration(
          color:
              AppTheme.textSecondary.withValues(alpha: _animation.value * 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildSkeletonCircle() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color:
              AppTheme.textSecondary.withValues(alpha: _animation.value * 0.3),
          borderRadius: BorderRadius.circular(5.w),
        ),
      ),
    );
  }
}
