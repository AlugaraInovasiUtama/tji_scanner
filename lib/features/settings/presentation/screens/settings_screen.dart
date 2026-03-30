import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/utils/scan_feedback.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrateEnabled = true;
  bool _beepEnabled = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          _SectionTitle(title: 'Feedback Scanner'),
          _SettingsTile(
            title: 'Vibration',
            subtitle: 'Getar saat scan berhasil/gagal',
            icon: Icons.vibration,
            trailing: Switch(
              value: _vibrateEnabled,
              activeColor: AppColors.primary,
              onChanged: (v) {
                setState(() => _vibrateEnabled = v);
                ScanFeedback.setVibrate(v);
              },
            ),
          ),
          _SettingsTile(
            title: 'Beep Sound',
            subtitle: 'Bunyi saat scan berhasil',
            icon: Icons.volume_up_outlined,
            trailing: Switch(
              value: _beepEnabled,
              activeColor: AppColors.primary,
              onChanged: (v) {
                setState(() => _beepEnabled = v);
                ScanFeedback.setBeep(v);
              },
            ),
          ),
          const SizedBox(height: 24),

          _SectionTitle(title: 'Tentang Aplikasi'),
          _SettingsTile(
            title: 'Versi Aplikasi',
            subtitle: '1.0.0 (Build 1)',
            icon: Icons.info_outline,
          ),
          _SettingsTile(
            title: 'Database',
            subtitle: 'Drift SQLite (Local)',
            icon: Icons.storage_outlined,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: trailing,
      ),
    );
  }
}
