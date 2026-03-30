import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class StepIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          // Step dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final stepIndex = index + 1;
              final isDone = stepIndex < currentStep;
              final isCurrent = stepIndex == currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isDone
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isCurrent ? 28 : 24,
                          height: isCurrent ? 28 : 24,
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.primary
                                : isCurrent
                                    ? AppColors.primary.withOpacity(0.2)
                                    : AppColors.divider,
                            shape: BoxShape.circle,
                            border: isCurrent
                                ? Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.black,
                                    size: 14,
                                  )
                                : Text(
                                    '$stepIndex',
                                    style: TextStyle(
                                      color: isCurrent
                                          ? AppColors.primary
                                          : AppColors.textHint,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        if (index < totalSteps - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: stepIndex < currentStep
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stepLabels[index],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isCurrent
                            ? AppColors.primary
                            : isDone
                                ? AppColors.textSecondary
                                : AppColors.textHint,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
