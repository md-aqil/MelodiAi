import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _screenFadeAnimation;

  String _statusMessage = 'Initializing MelodyAI...';
  bool _hasError = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Screen fade animation controller
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Screen fade animation for transition
    _screenFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _startSplashSequence() async {
    try {
      // Step 1: Check network connectivity
      setState(() {
        _statusMessage = 'Checking network connection...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _handleNetworkError();
        return;
      }

      // Step 2: Initialize Suno AI connection
      setState(() {
        _statusMessage = 'Connecting to Suno AI...';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      final apiInitialized = await _initializeSunoAPI();
      if (!apiInitialized) {
        _handleAPIError();
        return;
      }

      // Step 3: Load user preferences
      setState(() {
        _statusMessage = 'Loading preferences...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      await _loadUserPreferences();

      // Step 4: Prepare generation history
      setState(() {
        _statusMessage = 'Preparing workspace...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      await _loadGenerationHistory();

      // Step 5: Complete initialization
      setState(() {
        _statusMessage = 'Ready to create music!';
      });
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate to main screen
      await _navigateToMainScreen();
    } catch (e) {
      _handleGeneralError();
    }
  }

  Future<bool> _initializeSunoAPI() async {
    try {
      // Simulate API connection check
      // In real implementation, this would validate the Bearer token
      // and check Suno AI service availability
      await Future.delayed(const Duration(milliseconds: 1200));

      // Mock API validation - in production, replace with actual API call
      final prefs = await SharedPreferences.getInstance();
      final hasValidToken = prefs.getString('suno_api_token') != null;

      // For demo purposes, assume API is available
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load default preferences if not set
      if (!prefs.containsKey('default_style')) {
        await prefs.setString('default_style', 'Pop');
        await prefs.setBool('custom_mode', false);
        await prefs.setBool('instrumental_mode', false);
        await prefs.setString('vocal_gender', 'male');
        await prefs.setDouble('style_weight', 0.5);
        await prefs.setDouble('weirdness', 0.3);
        await prefs.setDouble('audio_weight', 0.7);
      }
    } catch (e) {
      // Continue with default settings if preferences fail to load
    }
  }

  Future<void> _loadGenerationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Initialize empty history if not exists
      if (!prefs.containsKey('generation_history')) {
        await prefs.setStringList('generation_history', []);
      }

      // Load cached audio files list
      if (!prefs.containsKey('cached_audio_files')) {
        await prefs.setStringList('cached_audio_files', []);
      }
    } catch (e) {
      // Continue without history if loading fails
    }
  }

  Future<void> _navigateToMainScreen() async {
    // Start fade out animation
    await _fadeAnimationController.forward();

    // Navigate to music generation screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/music-generation-screen');
    }
  }

  void _handleNetworkError() {
    setState(() {
      _statusMessage = 'No internet connection';
      _hasError = true;
    });
  }

  void _handleAPIError() {
    setState(() {
      _statusMessage = 'Unable to connect to Suno AI';
      _hasError = true;
    });
  }

  void _handleGeneralError() {
    setState(() {
      _statusMessage = 'Initialization failed';
      _hasError = true;
    });
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _hasError = false;
      _isRetrying = true;
      _statusMessage = 'Retrying...';
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isRetrying = false;
    });

    _startSplashSequence();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _screenFadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _screenFadeAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo Section
                    AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: _buildLogo(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 8.h),

                    // Status Section
                    _buildStatusSection(),

                    const Spacer(flex: 3),

                    // Footer
                    _buildFooter(),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'music_note',
            color: AppTheme.textPrimary,
            size: 12.w,
          ),
          SizedBox(height: 1.h),
          Text(
            'MelodyAI',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      children: [
        // Status Message
        Container(
          constraints: BoxConstraints(maxWidth: 80.w),
          child: Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary.withValues(alpha: 0.9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Loading Indicator or Error Actions
        _hasError ? _buildErrorActions() : _buildLoadingIndicator(),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 8.w,
      height: 8.w,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppTheme.textPrimary.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildErrorActions() {
    return Column(
      children: [
        CustomIconWidget(
          iconName: 'error_outline',
          color: AppTheme.warning,
          size: 8.w,
        ),

        SizedBox(height: 3.h),

        // Retry Button
        ElevatedButton(
          onPressed: _isRetrying ? null : _retryInitialization,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.textPrimary,
            foregroundColor: AppTheme.primary,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isRetrying
              ? SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                )
              : Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Powered by Suno AI',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'security',
              color: AppTheme.textPrimary.withValues(alpha: 0.5),
              size: 3.w,
            ),
            SizedBox(width: 1.w),
            Text(
              'Secure Connection',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary.withValues(alpha: 0.5),
                fontSize: 9.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
