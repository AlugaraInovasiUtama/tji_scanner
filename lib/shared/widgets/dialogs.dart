import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ErrorDialog(title: title, message: message, onRetry: onRetry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.titleLarge),
        ],
      ),
      content: Text(message, style: AppTextStyles.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        if (onRetry != null)
          AppButton(
            label: 'Coba Lagi',
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
          ),
      ],
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      builder: (_) => SuccessDialog(title: title, message: message, onClose: onClose),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 24),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.titleLarge),
        ],
      ),
      content: Text(message, style: AppTextStyles.bodyMedium),
      actions: [
        AppButton(
          label: 'OK',
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
        ),
      ],
    );
  }
}
