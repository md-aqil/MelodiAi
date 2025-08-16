import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onRegenerate;
  final VoidCallback onAddToFavorites;
  final bool isDownloading;
  final bool isFavorite;
  final double downloadProgress;

  const ActionButtonsWidget({
    super.key,
    required this.onDownload,
    required this.onShare,
    required this.onRegenerate,
    required this.onAddToFavorites,
    this.isDownloading = false,
    this.isFavorite = false,
    this.downloadProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Primary actions row
          Row(
            children: [
              // Download button
              Expanded(
                child: _buildActionButton(
                  onTap: isDownloading ? null : onDownload,
                  icon: isDownloading ? 'downloading' : 'download',
                  label: isDownloading ? 'Downloading...' : 'Download',
                  isPrimary: true,
                  isLoading: isDownloading,
                  progress: downloadProgress,
                ),
              ),

              SizedBox(width: 3.w),

              // Share button
              Expanded(
                child: _buildActionButton(
                  onTap: onShare,
                  icon: 'share',
                  label: 'Share',
                  isPrimary: false,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Secondary actions row
          Row(
            children: [
              // Regenerate button
              Expanded(
                child: _buildActionButton(
                  onTap: onRegenerate,
                  icon: 'refresh',
                  label: 'Regenerate',
                  isPrimary: false,
                ),
              ),

              SizedBox(width: 3.w),

              // Add to favorites button
              Expanded(
                child: _buildActionButton(
                  onTap: onAddToFavorites,
                  icon: isFavorite ? 'favorite' : 'favorite_border',
                  label: isFavorite ? 'Favorited' : 'Add to Favorites',
                  isPrimary: false,
                  isActive: isFavorite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    required String icon,
    required String label,
    required bool isPrimary,
    bool isLoading = false,
    bool isActive = false,
    double progress = 0.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    AppTheme.darkTheme.colorScheme.primary,
                    AppTheme.darkTheme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPrimary
              ? null
              : isActive
                  ? AppTheme.darkTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.darkTheme.colorScheme.surface
                      .withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : isActive
                    ? AppTheme.darkTheme.colorScheme.primary
                        .withValues(alpha: 0.3)
                    : AppTheme.darkTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // Icon with loading or progress indicator
            SizedBox(
              height: 6.w,
              width: 6.w,
              child: isLoading
                  ? Stack(
                      children: [
                        Center(
                          child: CircularProgressIndicator(
                            value: progress > 0 ? progress : null,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isPrimary
                                  ? AppTheme.darkTheme.colorScheme.onPrimary
                                  : AppTheme.darkTheme.colorScheme.primary,
                            ),
                            backgroundColor: isPrimary
                                ? AppTheme.darkTheme.colorScheme.onPrimary
                                    .withValues(alpha: 0.3)
                                : AppTheme.darkTheme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        if (progress > 0)
                          Center(
                            child: Text(
                              '${(progress * 100).round()}%',
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: isPrimary
                                    ? AppTheme.darkTheme.colorScheme.onPrimary
                                    : AppTheme.darkTheme.colorScheme.primary,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    )
                  : CustomIconWidget(
                      iconName: icon,
                      color: isPrimary
                          ? AppTheme.darkTheme.colorScheme.onPrimary
                          : isActive
                              ? AppTheme.darkTheme.colorScheme.primary
                              : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                      size: 6.w,
                    ),
            ),

            SizedBox(height: 1.h),

            // Label
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: isPrimary
                    ? AppTheme.darkTheme.colorScheme.onPrimary
                    : isActive
                        ? AppTheme.darkTheme.colorScheme.primary
                        : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
