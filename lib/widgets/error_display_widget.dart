import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../core/error_handling/app_error.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRetryButton;
  final bool isCompact;

  const ErrorDisplayWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showRetryButton = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactError();
    }

    return _buildFullError();
  }

  Widget _buildCompactError() {
    return Container(
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: _getErrorIcon(),
            color: AppTheme.error,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.message,
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (error.details != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    error.details!,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (showRetryButton && error.isRetryable && onRetry != null) ...[
            SizedBox(width: 2.w),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            SizedBox(width: 1.w),
            GestureDetector(
              onTap: onDismiss,
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullError() {
    return Container(
      padding: EdgeInsets.all(5.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.error.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: _getErrorIcon(),
              color: AppTheme.error,
              size: 8.w,
            ),
          ),

          SizedBox(height: 3.h),

          // Error title
          Text(
            error.message,
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          if (error.details != null) ...[
            SizedBox(height: 2.h),
            Text(
              error.details!,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          SizedBox(height: 4.h),

          // Action buttons
          Row(
            children: [
              if (onDismiss != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.textSecondary),
                      foregroundColor: AppTheme.textSecondary,
                    ),
                    child: Text('Dismiss'),
                  ),
                ),
                if (showRetryButton && error.isRetryable && onRetry != null)
                  SizedBox(width: 3.w),
              ],
              if (showRetryButton && error.isRetryable && onRetry != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: CustomIconWidget(
                      iconName: 'refresh',
                      color: AppTheme.onPrimary,
                      size: 16,
                    ),
                    label: Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                    ),
                  ),
                ),
            ],
          ),

          // Additional help text for non-retryable errors
          if (!error.isRetryable) ...[
            SizedBox(height: 2.h),
            Text(
              _getHelpText(),
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _getErrorIcon() {
    switch (error.type) {
      case AppErrorType.networkTimeout:
      case AppErrorType.networkUnavailable:
        return 'wifi_off';
      case AppErrorType.serverUnavailable:
      case AppErrorType.apiServiceUnavailable:
        return 'cloud_off';
      case AppErrorType.apiKeyInvalid:
      case AppErrorType.apiKeyMissing:
      case AppErrorType.authenticationFailed:
      case AppErrorType.authenticationExpired:
      case AppErrorType.authenticationMissing:
        return 'key';
      case AppErrorType.apiRateLimitExceeded:
      case AppErrorType.apiQuotaExceeded:
        return 'schedule';
      case AppErrorType.invalidParameters:
      case AppErrorType.missingDescription:
      case AppErrorType.invalidGenre:
      case AppErrorType.descriptionTooShort:
      case AppErrorType.descriptionTooLong:
        return 'warning';
      case AppErrorType.generationFailed:
      case AppErrorType.generationTimeout:
        return 'error';
      case AppErrorType.generationCancelled:
        return 'cancel';
      case AppErrorType.generationQueueFull:
        return 'queue';
      case AppErrorType.storageFull:
      case AppErrorType.storagePermissionDenied:
      case AppErrorType.storageUnavailable:
        return 'storage';
      case AppErrorType.unknown:
      default:
        return 'help';
    }
  }

  String _getHelpText() {
    switch (error.type) {
      case AppErrorType.apiQuotaExceeded:
        return 'Consider upgrading your plan to continue generating music.';
      case AppErrorType.apiKeyInvalid:
      case AppErrorType.apiKeyMissing:
        return 'Please contact support for assistance with your API access.';
      case AppErrorType.storagePermissionDenied:
        return 'You can enable storage permissions in your device settings.';
      case AppErrorType.storageFull:
        return 'Free up some space on your device and try again.';
      case AppErrorType.authenticationExpired:
      case AppErrorType.authenticationMissing:
        return 'Please log in again to continue using the app.';
      default:
        return 'If this problem persists, please contact our support team.';
    }
  }
}
