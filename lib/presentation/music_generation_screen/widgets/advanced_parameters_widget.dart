import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class AdvancedParametersWidget extends StatelessWidget {
  final bool isInstrumental;
  final String selectedGender;
  final double styleWeight;
  final double weirdness;
  final double audioWeight;
  final Function(bool) onInstrumentalChanged;
  final Function(String) onGenderChanged;
  final Function(double) onStyleWeightChanged;
  final Function(double) onWeirdnessChanged;
  final Function(double) onAudioWeightChanged;

  const AdvancedParametersWidget({
    Key? key,
    required this.isInstrumental,
    required this.selectedGender,
    required this.styleWeight,
    required this.weirdness,
    required this.audioWeight,
    required this.onInstrumentalChanged,
    required this.onGenderChanged,
    required this.onStyleWeightChanged,
    required this.onWeirdnessChanged,
    required this.onAudioWeightChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.divider.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Parameters',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // Instrumental/Vocal Toggle
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.background.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: isInstrumental ? 'piano' : 'mic',
                  color: AppTheme.primary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track Type',
                        style:
                            AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        isInstrumental ? 'Instrumental' : 'With Vocals',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: !isInstrumental,
                  onChanged: (value) => onInstrumentalChanged(!value),
                  activeColor: AppTheme.primary,
                  inactiveThumbColor: AppTheme.textSecondary,
                  inactiveTrackColor:
                      AppTheme.textSecondary.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),

          // Gender Selection (only if not instrumental)
          if (!isInstrumental) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Vocal Gender',
                        style:
                            AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onGenderChanged('male'),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: selectedGender == 'male'
                                    ? AppTheme.primary.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selectedGender == 'male'
                                      ? AppTheme.primary
                                      : AppTheme.divider,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio<String>(
                                    value: 'male',
                                    groupValue: selectedGender,
                                    onChanged: (value) =>
                                        onGenderChanged(value!),
                                    activeColor: AppTheme.primary,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Male',
                                    style: AppTheme
                                        .darkTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: selectedGender == 'male'
                                          ? AppTheme.primary
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onGenderChanged('female'),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: selectedGender == 'female'
                                    ? AppTheme.primary.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selectedGender == 'female'
                                      ? AppTheme.primary
                                      : AppTheme.divider,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio<String>(
                                    value: 'female',
                                    groupValue: selectedGender,
                                    onChanged: (value) =>
                                        onGenderChanged(value!),
                                    activeColor: AppTheme.primary,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Female',
                                    style: AppTheme
                                        .darkTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: selectedGender == 'female'
                                          ? AppTheme.primary
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 3.h),

          // Style Weight Slider
          _buildParameterSlider(
            title: 'Style Weight',
            value: styleWeight,
            onChanged: onStyleWeightChanged,
            icon: 'tune',
            description:
                'Controls how strongly the selected genre influences the output',
          ),

          SizedBox(height: 2.h),

          // Weirdness Slider
          _buildParameterSlider(
            title: 'Weirdness',
            value: weirdness,
            onChanged: onWeirdnessChanged,
            icon: 'psychology',
            description: 'Adds creative unpredictability to the generation',
          ),

          SizedBox(height: 2.h),

          // Audio Weight Slider
          _buildParameterSlider(
            title: 'Audio Weight',
            value: audioWeight,
            onChanged: onAudioWeightChanged,
            icon: 'graphic_eq',
            description: 'Balances audio quality vs generation speed',
          ),
        ],
      ),
    );
  }

  Widget _buildParameterSlider({
    required String title,
    required double value,
    required Function(double) onChanged,
    required String icon,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: AppTheme.primary,
                size: 18,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value.toStringAsFixed(2),
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            description,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.primary.withValues(alpha: 0.3),
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}