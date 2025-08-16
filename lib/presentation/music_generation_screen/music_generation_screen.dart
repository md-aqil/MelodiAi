import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/error_handling/app_error.dart';
import '../../core/error_handling/error_handler_service.dart';
import '../../widgets/error_display_widget.dart';
import './widgets/advanced_parameters_widget.dart';
import './widgets/generation_history_card_widget.dart';
import './widgets/genre_selection_widget.dart';

class MusicGenerationScreen extends StatefulWidget {
  const MusicGenerationScreen({Key? key}) : super(key: key);

  @override
  State<MusicGenerationScreen> createState() => _MusicGenerationScreenState();
}

class _MusicGenerationScreenState extends State<MusicGenerationScreen>
    with TickerProviderStateMixin {
  // Form controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _negativeTagsController = TextEditingController();

  // Form state
  String _selectedGenre = '';
  bool _isCustomMode = false;
  bool _isInstrumental = false;
  String _selectedGender = 'male';
  double _styleWeight = 0.5;
  double _weirdness = 0.3;
  double _audioWeight = 0.7;

  // UI state
  bool _isGenerating = false;
  bool _showAdvancedParams = false;
  AppError? _currentError;

  // Error handling service
  final ErrorHandlerService _errorHandler = ErrorHandlerService();

  // Animation controllers
  late AnimationController _advancedParamsAnimationController;
  late Animation<double> _advancedParamsAnimation;

  // Mock generation history data
  final List<Map<String, dynamic>> _generationHistory = [
    {
      "id": "gen_001",
      "title": "Sunset Dreams",
      "description": "A peaceful ambient track with soft piano melodies",
      "genre": "Ambient",
      "status": "completed",
      "audioUrl": "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
      "createdAt": DateTime.now().subtract(Duration(hours: 2)),
      "taskId": "task_001",
    },
    {
      "id": "gen_002",
      "title": "Urban Beats",
      "description": "High-energy hip-hop track with heavy bass",
      "genre": "Hip-Hop",
      "status": "generating",
      "audioUrl": null,
      "createdAt": DateTime.now().subtract(Duration(minutes: 15)),
      "taskId": "task_002",
    },
    {
      "id": "gen_003",
      "title": "Classical Morning",
      "description": "Orchestral piece inspired by Bach",
      "genre": "Classical",
      "status": "completed",
      "audioUrl": "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav",
      "createdAt": DateTime.now().subtract(Duration(days: 1)),
      "taskId": "task_003",
    },
    {
      "id": "gen_004",
      "title": "Electronic Fusion",
      "description": "Experimental electronic with jazz influences",
      "genre": "Electronic",
      "status": "failed",
      "audioUrl": null,
      "createdAt": DateTime.now().subtract(Duration(hours: 6)),
      "taskId": "task_004",
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _advancedParamsAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _advancedParamsAnimation = CurvedAnimation(
      parent: _advancedParamsAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _negativeTagsController.dispose();
    _advancedParamsAnimationController.dispose();
    super.dispose();
  }

  void _toggleAdvancedParams() {
    setState(() {
      _showAdvancedParams = !_showAdvancedParams;
    });

    if (_showAdvancedParams) {
      _advancedParamsAnimationController.forward();
    } else {
      _advancedParamsAnimationController.reverse();
    }
  }

  void _clearError() {
    setState(() {
      _currentError = null;
    });
  }

  void _showError(AppError error) {
    setState(() {
      _currentError = error;
    });
  }

  Future<void> _generateMusic() async {
    // Clear any previous errors
    _clearError();

    setState(() {
      _isGenerating = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Validate parameters first
      final validationError = _errorHandler.validateMusicGenerationParams(
        description: _descriptionController.text,
        genre: _selectedGenre,
        title: _titleController.text,
        negativeTags: _negativeTagsController.text,
        styleWeight: _styleWeight,
        weirdness: _weirdness,
        audioWeight: _audioWeight,
      );

      if (validationError != null) {
        _showError(validationError);
        return;
      }

      // Simulate API call with error handling
      final apiError = await _errorHandler.simulateApiCall();
      if (apiError != null) {
        _showError(apiError);
        return;
      }

      // Add new generation to history
      final newGeneration = {
        "id": "gen_${DateTime.now().millisecondsSinceEpoch}",
        "title": _titleController.text.trim().isEmpty
            ? "Untitled Track"
            : _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "genre": _selectedGenre,
        "status": "generating",
        "audioUrl": null,
        "createdAt": DateTime.now(),
        "taskId": "task_${DateTime.now().millisecondsSinceEpoch}",
        "isInstrumental": _isInstrumental,
        "gender": _isInstrumental ? null : _selectedGender,
        "styleWeight": _styleWeight,
        "weirdness": _weirdness,
        "audioWeight": _audioWeight,
        "negativeTags": _negativeTagsController.text.trim(),
      };

      setState(() {
        _generationHistory.insert(0, newGeneration);
      });

      // Navigate to progress screen
      Navigator.pushNamed(context, '/generation-progress-screen');
    } catch (e, stackTrace) {
      final error = await _errorHandler.handleError(e, stackTrace: stackTrace);
      _showError(error);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _retryGeneration() {
    _clearError();
    _generateMusic();
  }

  void _onHistoryCardTap(Map<String, dynamic> generation) {
    final String status = (generation['status'] as String?) ?? 'pending';

    if (status == 'completed') {
      Navigator.pushNamed(context, '/audio-playback-screen');
    } else if (status == 'generating') {
      Navigator.pushNamed(context, '/generation-progress-screen');
    }
  }

  void _onHistoryCardPlay(Map<String, dynamic> generation) {
    Navigator.pushNamed(context, '/audio-playback-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withValues(alpha: 0.1),
              AppTheme.background,
              AppTheme.background,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Error display
              if (_currentError != null)
                ErrorDisplayWidget(
                  error: _currentError!,
                  isCompact: true,
                  onRetry: _currentError!.isRetryable ? _retryGeneration : null,
                  onDismiss: _clearError,
                ),

              // Main content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(Duration(seconds: 1));
                    setState(() {});
                  },
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),

                        // Description input
                        _buildDescriptionInput(),

                        SizedBox(height: 3.h),

                        // Title input
                        _buildTitleInput(),

                        SizedBox(height: 3.h),

                        // Genre selection
                        GenreSelectionWidget(
                          selectedGenre: _selectedGenre,
                          onGenreSelected: (genre) {
                            setState(() {
                              _selectedGenre = genre;
                            });
                            _clearError(); // Clear error when user changes selection
                          },
                        ),

                        SizedBox(height: 3.h),

                        // Custom mode toggle
                        _buildCustomModeToggle(),

                        SizedBox(height: 2.h),

                        // Advanced parameters (collapsible)
                        if (_isCustomMode)
                          SizeTransition(
                            sizeFactor: _advancedParamsAnimation,
                            child: Column(
                              children: [
                                AdvancedParametersWidget(
                                  isInstrumental: _isInstrumental,
                                  selectedGender: _selectedGender,
                                  styleWeight: _styleWeight,
                                  weirdness: _weirdness,
                                  audioWeight: _audioWeight,
                                  onInstrumentalChanged: (value) {
                                    setState(() {
                                      _isInstrumental = value;
                                    });
                                  },
                                  onGenderChanged: (gender) {
                                    setState(() {
                                      _selectedGender = gender;
                                    });
                                  },
                                  onStyleWeightChanged: (value) {
                                    setState(() {
                                      _styleWeight = value;
                                    });
                                  },
                                  onWeirdnessChanged: (value) {
                                    setState(() {
                                      _weirdness = value;
                                    });
                                  },
                                  onAudioWeightChanged: (value) {
                                    setState(() {
                                      _audioWeight = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 3.h),
                              ],
                            ),
                          ),

                        // Negative tags input (only in custom mode)
                        if (_isCustomMode)
                          Column(
                            children: [
                              _buildNegativeTagsInput(),
                              SizedBox(height: 3.h),
                            ],
                          ),

                        // Generate button
                        _buildGenerateButton(),

                        SizedBox(height: 4.h),

                        // Recent generations
                        _buildRecentGenerations(),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MelodyAI',
                style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Create music with AI',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/settings-screen'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    final bool hasDescriptionError =
        _currentError?.type == AppErrorType.missingDescription ||
            _currentError?.type == AppErrorType.descriptionTooShort ||
            _currentError?.type == AppErrorType.descriptionTooLong;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasDescriptionError ? AppTheme.error : AppTheme.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 1.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'description',
                  color:
                      hasDescriptionError ? AppTheme.error : AppTheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Describe your music',
                  style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                    color: hasDescriptionError
                        ? AppTheme.error
                        : AppTheme.textPrimary,
                  ),
                ),
                Spacer(),
                Text(
                  '${_descriptionController.text.length}/500',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: _descriptionController.text.length < 10
                        ? AppTheme.error
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
            child: TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText:
                    'Describe the mood, style, instruments, or story you want your music to tell...',
                hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: (value) {
                setState(() {});
                // Clear error when user starts typing
                if (hasDescriptionError) {
                  _clearError();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.divider,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _titleController,
        maxLength: 100,
        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'title',
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          hintText: 'Song title (optional)',
          hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ),
          counterStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomModeToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.divider,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: _isCustomMode ? 'tune' : 'auto_awesome',
            color: AppTheme.primary,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isCustomMode ? 'Custom Mode' : 'Simple Mode',
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isCustomMode
                      ? 'Fine-tune generation parameters'
                      : 'Quick and easy music generation',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isCustomMode,
            onChanged: (value) {
              setState(() {
                _isCustomMode = value;
              });
              _toggleAdvancedParams();
              HapticFeedback.lightImpact();
            },
            activeColor: AppTheme.primary,
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNegativeTagsInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.divider,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _negativeTagsController,
        maxLength: 200,
        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'block',
              color: AppTheme.error,
              size: 20,
            ),
          ),
          hintText: 'Negative tags (what to avoid)',
          hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ),
          counterStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateMusic,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          disabledBackgroundColor: AppTheme.surface,
          disabledForegroundColor: AppTheme.textSecondary,
          elevation: _isGenerating ? 0 : 4,
          shadowColor: AppTheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGenerating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.textSecondary),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Generating...',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'auto_awesome',
                    color: AppTheme.onPrimary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Generate Music',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRecentGenerations() {
    if (_generationHistory.isEmpty) {
      return Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.divider.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'music_note',
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No generations yet',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your generated music will appear here',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Generations',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/generation-history-screen'),
              child: Text(
                'View All',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          height: 20.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 0),
            itemCount:
                _generationHistory.length > 5 ? 5 : _generationHistory.length,
            itemBuilder: (context, index) {
              final generation = _generationHistory[index];
              return GenerationHistoryCardWidget(
                generation: generation,
                onTap: () => _onHistoryCardTap(generation),
                onPlay: () => _onHistoryCardPlay(generation),
              );
            },
          ),
        ),
      ],
    );
  }
}
