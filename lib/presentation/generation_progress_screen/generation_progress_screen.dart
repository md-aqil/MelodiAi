import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/error_handling/app_error.dart';
import '../../core/error_handling/error_handler_service.dart';
import '../../widgets/error_display_widget.dart';
import './widgets/animated_waveform_widget.dart';
import './widgets/background_animation_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/status_message_widget.dart';

class GenerationProgressScreen extends StatefulWidget {
  const GenerationProgressScreen({Key? key}) : super(key: key);

  @override
  State<GenerationProgressScreen> createState() =>
      _GenerationProgressScreenState();
}

class _GenerationProgressScreenState extends State<GenerationProgressScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _successController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _successAnimation;

  // Progress tracking
  double _progress = 0.0;
  bool _isGenerating = true;
  bool _isSuccess = false;
  int _retryCount = 0;

  // Status tracking
  String _currentStatus = 'Initializing generation...';
  String? _taskId;
  Duration? _estimatedTime;
  int? _queuePosition;
  int? _totalQueue;

  // Error handling
  AppError? _currentError;
  final ErrorHandlerService _errorHandler = ErrorHandlerService();

  // Timers
  Timer? _progressTimer;
  Timer? _statusTimer;
  Timer? _pollingTimer;

  // Mock data for demonstration
  final List<String> _statusMessages = [
    'Initializing generation...',
    'Processing audio parameters...',
    'Analyzing style preferences...',
    'Generating musical structure...',
    'Creating audio layers...',
    'Processing vocals...',
    'Applying audio effects...',
    'Finalizing track...',
    'Almost ready...',
  ];

  final List<Map<String, dynamic>> _mockGenerationData = [
    {
      "taskId": "gen_7f8a9b2c1d3e4f5g",
      "estimatedTime": Duration(minutes: 2, seconds: 30),
      "queuePosition": 1,
      "totalQueue": 3,
    },
    {
      "taskId": "gen_9k2m4n6p8q1r3s5t",
      "estimatedTime": Duration(minutes: 1, seconds: 45),
      "queuePosition": null,
      "totalQueue": null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGeneration();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _successController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
  }

  void _initializeGeneration() {
    // Set initial mock data
    final mockData =
        _mockGenerationData[Random().nextInt(_mockGenerationData.length)];
    _taskId = mockData['taskId'] as String;
    _estimatedTime = mockData['estimatedTime'] as Duration?;
    _queuePosition = mockData['queuePosition'] as int?;
    _totalQueue = mockData['totalQueue'] as int?;

    _startProgressSimulation();
    _startStatusUpdates();
    _startPolling();
  }

  void _startProgressSimulation() {
    _progressTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!_isGenerating || _currentError != null) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress += 0.005 + (Random().nextDouble() * 0.01);
        if (_progress >= 1.0) {
          _progress = 1.0;
          _completeGeneration();
        }
      });
    });
  }

  void _startStatusUpdates() {
    int statusIndex = 0;
    _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_isGenerating ||
          statusIndex >= _statusMessages.length - 1 ||
          _currentError != null) {
        timer.cancel();
        return;
      }

      setState(() {
        statusIndex++;
        _currentStatus = _statusMessages[statusIndex];

        // Update estimated time
        if (_estimatedTime != null && _estimatedTime!.inSeconds > 5) {
          _estimatedTime = Duration(seconds: _estimatedTime!.inSeconds - 5);
        }

        // Update queue position
        if (_queuePosition != null && _queuePosition! > 1) {
          _queuePosition = _queuePosition! - 1;
        }
      });
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_isGenerating || _currentError != null) {
        timer.cancel();
        return;
      }

      // Simulate API polling
      _simulateApiCall();
    });
  }

  Future<void> _simulateApiCall() async {
    try {
      // Simulate API call with error handling
      final apiError = await _errorHandler.simulateApiCall(taskId: _taskId);

      if (apiError != null) {
        await _handleError(apiError);
        return;
      }

      // Continue normal progress
      if (_progress >= 0.95) {
        _completeGeneration();
      }
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace: stackTrace);
      await _handleError(error);
    }
  }

  Future<void> _handleError(AppError error) async {
    setState(() {
      _isGenerating = false;
      _currentError = error;
      _currentStatus = error.message;
    });

    // Stop all timers
    _progressTimer?.cancel();
    _statusTimer?.cancel();
    _pollingTimer?.cancel();

    // Auto-retry for certain error types after delay
    if (error.isRetryable && _retryCount < 3) {
      final retryDelay = Duration(seconds: 3 * pow(2, _retryCount).toInt());

      Timer(retryDelay, () {
        if (mounted && _currentError?.isRetryable == true) {
          _retryGeneration();
        }
      });
    }
  }

  void _clearError() {
    setState(() {
      _currentError = null;
    });
  }

  void _completeGeneration() {
    setState(() {
      _isGenerating = false;
      _isSuccess = true;
      _progress = 1.0;
      _currentStatus = 'Generation complete!';
    });

    _successController.forward();

    // Provide haptic feedback
    HapticFeedback.heavyImpact();

    // Navigate to audio playback after success animation
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/audio-playback-screen');
      }
    });
  }

  void _cancelGeneration() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            'Cancel Generation',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel the music generation? This action cannot be undone.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performCancellation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: Text(
                'Cancel Generation',
                style: TextStyle(color: AppTheme.onError),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performCancellation() {
    setState(() {
      _isGenerating = false;
      _currentError = AppError.generationCancelled();
    });

    _progressTimer?.cancel();
    _statusTimer?.cancel();
    _pollingTimer?.cancel();

    // Navigate back after short delay
    Timer(Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/music-generation-screen');
      }
    });
  }

  void _retryGeneration() {
    _clearError();
    setState(() {
      _isGenerating = true;
      _progress = 0.0;
      _retryCount++;
      _currentStatus = 'Retrying generation...';
    });

    _startProgressSimulation();
    _startStatusUpdates();
    _startPolling();
  }

  void _goBack() {
    if (_isGenerating) {
      _cancelGeneration();
    } else {
      Navigator.pushReplacementNamed(context, '/music-generation-screen');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _successController.dispose();
    _progressTimer?.cancel();
    _statusTimer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Animated background
          BackgroundAnimationWidget(
              isActive: _isGenerating && _currentError == null),

          // Main content
          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header with cancel button
                  _buildHeader(),

                  // Error display
                  if (_currentError != null && !_isSuccess)
                    ErrorDisplayWidget(
                      error: _currentError!,
                      isCompact: false,
                      onRetry:
                          _currentError!.isRetryable ? _retryGeneration : null,
                      onDismiss: _goBack,
                    ),

                  // Main content area
                  Expanded(
                    child: _isSuccess
                        ? _buildSuccessContent()
                        : _currentError == null
                            ? _buildProgressContent()
                            : SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cancel/Back button
          GestureDetector(
            onTap: _goBack,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: _isGenerating
                      ? AppTheme.error.withValues(alpha: 0.3)
                      : AppTheme.divider,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: _isGenerating ? 'close' : 'arrow_back',
                    color:
                        _isGenerating ? AppTheme.error : AppTheme.textSecondary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _isGenerating ? 'Cancel' : 'Back',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: _isGenerating
                          ? AppTheme.error
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Title
          Text(
            _isSuccess
                ? 'Generation Complete'
                : _currentError != null
                    ? 'Generation Error'
                    : 'Generating Music',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Placeholder for symmetry
          SizedBox(width: 20.w),
        ],
      ),
    );
  }

  Widget _buildProgressContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated waveform
          AnimatedWaveformWidget(
            progress: _progress,
            isActive: _isGenerating,
          ),

          SizedBox(height: 6.h),

          // Progress indicator
          ProgressIndicatorWidget(
            progress: _progress,
            isActive: _isGenerating,
          ),

          SizedBox(height: 4.h),

          // Status message
          StatusMessageWidget(
            message: _currentStatus,
            taskId: _taskId,
            estimatedTime: _estimatedTime,
            queuePosition: _queuePosition,
            totalQueue: _totalQueue,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success animation
          ScaleTransition(
            scale: _successAnimation,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.success,
                    AppTheme.success.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.success.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CustomIconWidget(
                iconName: 'check',
                color: AppTheme.onSuccess,
                size: 15.w,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Success message
          Text(
            'Music Generated Successfully!',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          Text(
            'Your AI-generated track is ready to play. Redirecting to audio player...',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
