import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HistoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> track;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;
  final VoidCallback? onDuplicate;

  const HistoryCardWidget({
    Key? key,
    required this.track,
    this.onTap,
    this.onPlay,
    this.onDownload,
    this.onShare,
    this.onDelete,
    this.onRename,
    this.onDuplicate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = track['status'] as String? ?? 'completed';
    final title = track['title'] as String? ?? 'Untitled Track';
    final genre = track['genre'] as String? ?? 'Unknown';
    final duration = track['duration'] as String? ?? '0:00';
    final createdAt = track['createdAt'] as String? ?? '';
    final thumbnail = track['thumbnail'] as String? ?? '';

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          borderRadius: BorderRadius.circular(12),
          child: Dismissible(
            key: Key(track['id'].toString()),
            background: _buildSwipeBackground(isLeft: true),
            secondaryBackground: _buildSwipeBackground(isLeft: false),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                onPlay?.call();
              } else if (direction == DismissDirection.endToStart) {
                _showDeleteConfirmation(context);
              }
            },
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                onPlay?.call();
                return false;
              } else if (direction == DismissDirection.endToStart) {
                return await _showDeleteConfirmation(context);
              }
              return false;
            },
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  _buildThumbnail(),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Text(
                              genre,
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.secondary,
                              ),
                            ),
                            Text(
                              ' • ',
                              style: AppTheme.darkTheme.textTheme.bodySmall,
                            ),
                            Text(
                              duration,
                              style: AppTheme.darkTheme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          createdAt,
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusIcon(status),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final thumbnail = track['thumbnail'] as String? ?? '';

    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.primary.withValues(alpha: 0.2),
      ),
      child: thumbnail.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: thumbnail,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              ),
            )
          : Center(
              child: CustomIconWidget(
                iconName: 'music_note',
                color: AppTheme.primary,
                size: 6.w,
              ),
            ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomIconWidget(
            iconName: 'play_arrow',
            color: AppTheme.success,
            size: 5.w,
          ),
        );
      case 'processing':
        return Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.warning.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 5.w,
            height: 5.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warning),
            ),
          ),
        );
      case 'failed':
        return Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomIconWidget(
            iconName: 'refresh',
            color: AppTheme.error,
            size: 5.w,
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomIconWidget(
            iconName: 'more_horiz',
            color: AppTheme.textSecondary,
            size: 5.w,
          ),
        );
    }
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft ? AppTheme.success : AppTheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'play_arrow' : 'delete',
                color: Colors.white,
                size: 6.w,
              ),
              SizedBox(height: 1.h),
              Text(
                isLeft ? 'Play' : 'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            _buildContextMenuItem(
              icon: 'play_arrow',
              title: 'Play',
              onTap: () {
                Navigator.pop(context);
                onPlay?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'download',
              title: 'Download',
              onTap: () {
                Navigator.pop(context);
                onDownload?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'share',
              title: 'Share',
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'edit',
              title: 'Rename',
              onTap: () {
                Navigator.pop(context);
                onRename?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'content_copy',
              title: 'Duplicate Settings',
              onTap: () {
                Navigator.pop(context);
                onDuplicate?.call();
              },
            ),
            _buildContextMenuItem(
              icon: 'delete',
              title: 'Delete',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
        size: 6.w,
      ),
      title: Text(
        title,
        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
          color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.darkTheme.colorScheme.surface,
            title: Text(
              'Delete Track',
              style: AppTheme.darkTheme.textTheme.titleLarge,
            ),
            content: Text(
              'Are you sure you want to delete this track? This action cannot be undone.',
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  onDelete?.call();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
