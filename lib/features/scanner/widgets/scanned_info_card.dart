import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class ScannedInfoCard extends StatelessWidget {
  final Map<String, String> fields;
  final String? title;
  final Color? titleColor;

  const ScannedInfoCard({
    super.key,
    required this.fields,
    this.title,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (titleColor ?? AppColors.primary).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: (titleColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: titleColor ?? AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title!,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: titleColor ?? AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: fields.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(e.key, style: AppTextStyles.scanLabel),
                      ),
                      Expanded(
                        child: Text(
                          e.value,
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
