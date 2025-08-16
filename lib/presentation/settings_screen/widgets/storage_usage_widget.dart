import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StorageUsageWidget extends StatelessWidget {
  final double usedSpace;
  final double totalSpace;
  final VoidCallback onManageDownloads;
  final VoidCallback onClearCache;

  const StorageUsageWidget({
    Key? key,
    required this.usedSpace,
    required this.totalSpace,
    required this.onManageDownloads,
    required this.onClearCache,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usagePercentage = (usedSpace / totalSpace).clamp(0.0, 1.0);
    final usedSpaceText = _formatBytes(usedSpace);
    final totalSpaceText = _formatBytes(totalSpace);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'storage',
                color: AppTheme.primary,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Storage Usage',
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$usedSpaceText / \$totalSpaceText',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AppTheme.primary.withValues(alpha: 0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: usagePercentage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary,
                      usagePercentage > 0.8
                          ? AppTheme.warning
                          : AppTheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onManageDownloads,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                  child: Text(
                    'Manage Downloads',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: TextButton(
                  onPressed: onClearCache,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.warning,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                  child: Text(
                    'Clear Cache',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '\${bytes.toInt()} B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '\${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '\${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
