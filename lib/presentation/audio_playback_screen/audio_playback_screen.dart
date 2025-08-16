import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/audio_controls_widget.dart';
import './widgets/track_info_widget.dart';
import './widgets/waveform_visualizer_widget.dart';

class AudioPlaybackScreen extends StatefulWidget {
  const AudioPlaybackScreen({super.key});

  @override
  State<AudioPlaybackScreen> createState() => _AudioPlaybackScreenState();
}

class _AudioPlaybackScreenState extends State<AudioPlaybackScreen>
    with TickerProviderStateMixin {
  // Audio playback state
  bool _isPlaying = false;
  bool _isLoading = false;
  double _currentProgress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration(minutes: 3, seconds: 42);
  double _volume = 0.8;
  Timer? _progressTimer;

  // Download state
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isFavorite = false;

  // Animation controllers
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  // Mock track data
  final Map<String, dynamic> _trackData = {
    "id": "track_001",
    "title": "Ethereal Dreams",
    "genre": "Ambient",
    "description":
        "A soothing ambient track with ethereal soundscapes and gentle melodies that transport you to a peaceful dreamlike state.",
    "generatedAt": DateTime.now().subtract(Duration(minutes: 15)),
    "audioUrl": "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
    "duration": Duration(minutes: 3, seconds: 42),
    "parameters": {
      "style": "Ambient",
      "styleWeight": 0.8,
      "weirdness": 0.3,
      "audioWeight": 0.7,
      "isInstrumental": true,
      "negativePrompt": "harsh, aggressive, loud"
    }
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _simulateAudioLoading();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _backgroundAnimationController, curve: Curves.linear),
    );
    _backgroundAnimationController.repeat();
  }

  void _simulateAudioLoading() {
    setState(() => _isLoading = true);
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _togglePlayPause() {
    if (_isLoading) return;

    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      _startProgressTimer();
      HapticFeedback.lightImpact();
    } else {
      _stopProgressTimer();
    }
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_currentProgress >= 1.0) {
        _stopProgressTimer();
        setState(() {
          _isPlaying = false;
          _currentProgress = 0.0;
          _currentPosition = Duration.zero;
        });
        return;
      }

      setState(() {
        _currentProgress += 0.1 / _totalDuration.inSeconds;
        _currentPosition = Duration(
          milliseconds:
              (_currentProgress * _totalDuration.inMilliseconds).round(),
        );
      });
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
  }

  void _seekToPosition(double progress) {
    setState(() {
      _currentProgress = progress.clamp(0.0, 1.0);
      _currentPosition = Duration(
        milliseconds:
            (_currentProgress * _totalDuration.inMilliseconds).round(),
      );
    });
    HapticFeedback.selectionClick();
  }

  void _skipBackward() {
    final newPosition = _currentPosition - Duration(seconds: 10);
    final newProgress =
        newPosition.inMilliseconds / _totalDuration.inMilliseconds;
    _seekToPosition(math.max(0.0, newProgress));
  }

  void _skipForward() {
    final newPosition = _currentPosition + Duration(seconds: 10);
    final newProgress =
        newPosition.inMilliseconds / _totalDuration.inMilliseconds;
    _seekToPosition(math.min(1.0, newProgress));
  }

  void _changeVolume(double volume) {
    setState(() => _volume = volume);
  }

  void _downloadTrack() {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() => _downloadProgress += 0.02);

      if (_downloadProgress >= 1.0) {
        timer.cancel();
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Track downloaded successfully!'),
            backgroundColor: AppTheme.darkTheme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _shareTrack() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality would open native share sheet'),
        backgroundColor: AppTheme.darkTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _regenerateTrack() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/music-generation-screen');
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isFavorite ? 'Added to favorites!' : 'Removed from favorites'),
        backgroundColor: _isFavorite
            ? AppTheme.darkTheme.colorScheme.primary
            : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTrackDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTrackDetailsModal(),
    );
  }

  Widget _buildTrackDetailsModal() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Details',
                    style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildDetailRow('Title', _trackData['title']),
                  _buildDetailRow('Genre', _trackData['genre']),
                  _buildDetailRow('Duration',
                      '${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}'),
                  _buildDetailRow(
                      'Generated', _formatTimestamp(_trackData['generatedAt'])),
                  SizedBox(height: 3.h),
                  Text(
                    'Generation Parameters',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildDetailRow('Style Weight',
                      '${(_trackData['parameters']['styleWeight'] * 100).round()}%'),
                  _buildDetailRow('Weirdness',
                      '${(_trackData['parameters']['weirdness'] * 100).round()}%'),
                  _buildDetailRow('Audio Weight',
                      '${(_trackData['parameters']['audioWeight'] * 100).round()}%'),
                  _buildDetailRow(
                      'Type',
                      _trackData['parameters']['isInstrumental']
                          ? 'Instrumental'
                          : 'Vocal'),
                  if (_trackData['parameters']['negativePrompt']
                      .isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Negative Prompt',
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _trackData['parameters']['negativePrompt'],
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.darkTheme.colorScheme.onSurface,
              ),
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
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkTheme.scaffoldBackgroundColor,
              AppTheme.darkTheme.colorScheme.surface.withValues(alpha: 0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),

                      // Track info
                      TrackInfoWidget(
                        title: _trackData['title'],
                        genre: _trackData['genre'],
                        generatedAt: _trackData['generatedAt'],
                        onShowDetails: _showTrackDetails,
                      ),

                      SizedBox(height: 4.h),

                      // Waveform visualizer
                      WaveformVisualizerWidget(
                        progress: _currentProgress,
                        isPlaying: _isPlaying,
                        onSeek: _seekToPosition,
                        duration: _totalDuration,
                        currentPosition: _currentPosition,
                      ),

                      SizedBox(height: 4.h),

                      // Audio controls
                      AudioControlsWidget(
                        isPlaying: _isPlaying,
                        onPlayPause: _togglePlayPause,
                        onSkipBackward: _skipBackward,
                        onSkipForward: _skipForward,
                        volume: _volume,
                        onVolumeChanged: _changeVolume,
                        isLoading: _isLoading,
                      ),

                      SizedBox(height: 4.h),

                      // Action buttons
                      ActionButtonsWidget(
                        onDownload: _downloadTrack,
                        onShare: _shareTrack,
                        onRegenerate: _regenerateTrack,
                        onAddToFavorites: _toggleFavorite,
                        isDownloading: _isDownloading,
                        isFavorite: _isFavorite,
                        downloadProgress: _downloadProgress,
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.surface
                    .withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.darkTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Now Playing',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Menu button
          GestureDetector(
            onTap: () {
              // Show options menu
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.darkTheme.colorScheme.surface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: CustomIconWidget(
                          iconName: 'history',
                          color: AppTheme.darkTheme.colorScheme.onSurface,
                          size: 6.w,
                        ),
                        title: Text('Generation History'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, '/generation-history-screen');
                        },
                      ),
                      ListTile(
                        leading: CustomIconWidget(
                          iconName: 'settings',
                          color: AppTheme.darkTheme.colorScheme.onSurface,
                          size: 6.w,
                        ),
                        title: Text('Settings'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/settings-screen');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.colorScheme.surface
                    .withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: CustomIconWidget(
                iconName: 'more_vert',
                color: AppTheme.darkTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
