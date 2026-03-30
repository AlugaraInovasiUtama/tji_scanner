import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Dummy data — replace with Drift DB query
  static const _dummyHistory = [
    _HistoryItem(
      type: 'Putaway',
      detail: 'BOX-001 → PAL-01 → RACK-A1',
      time: '06/03/2026 09:12',
      status: 'synced',
      icon: Icons.move_to_inbox_outlined,
      color: Color(0xFF2979FF),
    ),
    _HistoryItem(
      type: 'Picking',
      detail: 'PROD-007 → PAL-03',
      time: '06/03/2026 09:05',
      status: 'synced',
      icon: Icons.local_shipping_outlined,
      color: Color(0xFF4CAF50),
    ),
    _HistoryItem(
      type: 'Stock Opname',
      detail: 'RACK-B2 — 5 box',
      time: '06/03/2026 08:50',
      status: 'pending',
      icon: Icons.inventory_2_outlined,
      color: Color(0xFFFF9800),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Scan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: _dummyHistory.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat scan',
                style: TextStyle(color: AppColors.textHint),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _dummyHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _dummyHistory[index];
                return _HistoryCard(item: item);
              },
            ),
    );
  }
}

class _HistoryItem {
  final String type;
  final String detail;
  final String time;
  final String status;
  final IconData icon;
  final Color color;

  const _HistoryItem({
    required this.type,
    required this.detail,
    required this.time,
    required this.status,
    required this.icon,
    required this.color,
  });
}

class _HistoryCard extends StatelessWidget {
  final _HistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        item.status == 'synced' ? AppColors.success : AppColors.warning;
    final statusLabel = item.status == 'synced' ? 'Synced' : 'Pending';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.type, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(item.detail, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(item.time, style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
