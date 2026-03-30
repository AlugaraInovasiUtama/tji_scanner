import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;

  const OfflineBanner({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isOffline
          ? Container(
              key: const ValueKey('offline'),
              width: double.infinity,
              color: AppColors.warning,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Offline — Data akan disync saat terhubung',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('online')),
    );
  }
}
