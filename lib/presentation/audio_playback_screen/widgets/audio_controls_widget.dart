import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioControlsWidget extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipBackward;
  final VoidCallback onSkipForward;
  final double volume;
  final Function(double) onVolumeChanged;
  final bool isLoading;

  const AudioControlsWidget({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSkipBackward,
    required this.onSkipForward,
    required this.volume,
    required this.onVolumeChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Main playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Skip backward button
              _buildControlButton(
                onTap: onSkipBackward,
                child: CustomIconWidget(
                  iconName: 'replay_10',
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),

              // Play/Pause button
              _buildMainPlayButton(),

              // Skip forward button
              _buildControlButton(
                onTap: onSkipForward,
                child: CustomIconWidget(
                  iconName: 'forward_10',
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Volume control
          _buildVolumeControl(),
        ],
      ),
    );
  }

  Widget _buildMainPlayButton() {
    return GestureDetector(
      onTap: isLoading ? null : onPlayPause,
      child: Container(
        width: 16.w,
        height: 16.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkTheme.colorScheme.primary,
              AppTheme.darkTheme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 6.w,
                  height: 6.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.darkTheme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              )
            : Center(
                child: CustomIconWidget(
                  iconName: isPlaying ? 'pause' : 'play_arrow',
                  color: AppTheme.darkTheme.colorScheme.onPrimary,
                  size: 8.w,
                ),
              ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: volume == 0
              ? 'volume_off'
              : volume < 0.5
                  ? 'volume_down'
                  : 'volume_up',
          color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.darkTheme.colorScheme.primary,
              inactiveTrackColor: AppTheme
                  .darkTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              thumbColor: AppTheme.darkTheme.colorScheme.primary,
              overlayColor:
                  AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.2),
              trackHeight: 0.8.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 2.w),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 4.w),
            ),
            child: Slider(
              value: volume,
              onChanged: onVolumeChanged,
              min: 0.0,
              max: 1.0,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          '${(volume * 100).round()}%',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}