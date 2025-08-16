import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class GenerationHistoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> generation;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;

  const GenerationHistoryCardWidget({
    Key? key,
    required this.generation,
    this.onTap,
    this.onPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = (generation['title'] as String?) ?? 'Untitled';
    final String genre = (generation['genre'] as String?) ?? 'Unknown';
    final String status = (generation['status'] as String?) ?? 'pending';
    final DateTime? createdAt = generation['createdAt'] as DateTime?;
    final String? audioUrl = generation['audioUrl'] as String?;

    return Container(
      width: 70.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.divider.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style:
                            AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    _buildStatusIndicator(status),
                  ],
                ),

                SizedBox(height: 1.h),

                // Genre
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'music_note',
                      color: AppTheme.textSecondary,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      genre,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Play button and timestamp
                Row(
                  children: [
                    if (status == 'completed' && audioUrl != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onPlay,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CustomIconWidget(
                              iconName: 'play_arrow',
                              color: AppTheme.primary,
                              size: 16,
                            ),
                          ),
                        ),
                      )
                    else if (status == 'generating')
                      Container(
                        padding: EdgeInsets.all(2.w),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomIconWidget(
                          iconName: 'hourglass_empty',
                          color: AppTheme.textSecondary,
                          size: 16,
                        ),
                      ),
                    Spacer(),
                    if (createdAt != null)
                      Text(
                        _formatTimestamp(createdAt),
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary.withValues(alpha: 0.7),
                          fontSize: 10.sp,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = AppTheme.success;
        statusText = 'Ready';
        statusIcon = Icons.check_circle;
        break;
      case 'generating':
        statusColor = AppTheme.warning;
        statusText = 'Generating';
        statusIcon = Icons.autorenew;
        break;
      case 'failed':
        statusColor = AppTheme.error;
        statusText = 'Failed';
        statusIcon = Icons.error;
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusText = 'Pending';
        statusIcon = Icons.schedule;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 12,
            color: statusColor,
          ),
          SizedBox(width: 1.w),
          Text(
            statusText,
            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
