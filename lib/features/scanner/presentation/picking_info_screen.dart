import 'package:flutter/material.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../data/scan_service.dart';
import '../widgets/qr_scanner_widget.dart';

class PickingInfoScreen extends StatefulWidget {
  final ScanService scanService;

  const PickingInfoScreen({super.key, required this.scanService});

  @override
  State<PickingInfoScreen> createState() => _PickingInfoScreenState();
}

class _PickingInfoScreenState extends State<PickingInfoScreen> {
  PickingInfo? _pickingInfo;
  String? _errorMessage;
  bool _isLoading = false;
  bool _showResult = false;
  String? _lastCode;

  void _onScanSuccess(String code) async {
    if (code == _lastCode && _showResult) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pickingInfo = null;
      _showResult = false;
      _lastCode = code;
    });

    try {
      final info = await widget.scanService.getPickingInfo(code);
      if (!mounted) return;
      setState(() {
        _pickingInfo = info;
        _isLoading = false;
        _showResult = true;
      });
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
        _showResult = true;
      });
    } on NetworkException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
        _showResult = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
        _showResult = true;
      });
    }
  }

  void _onScanError(String error) {
    setState(() {
      _errorMessage = error;
      _showResult = true;
      _isLoading = false;
    });
  }

  void _reset() {
    setState(() {
      _pickingInfo = null;
      _errorMessage = null;
      _isLoading = false;
      _showResult = false;
      _lastCode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Info Picking'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (_showResult)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Scan lagi',
              onPressed: _reset,
            ),
        ],
      ),
      body: _showResult ? _buildResult() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return QrScannerWidget(
      expectedType: 'any',
      instruction: 'Scan QR Code pada dokumen picking untuk melihat detail',
      onScanSuccess: _onScanSuccess,
      onScanError: _onScanError,
    );
  }

  Widget _buildResult() {
    return Column(
      children: [
        if (_isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        if (_errorMessage != null && !_isLoading)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _ErrorCard(message: _errorMessage!),
            ),
          ),
        if (_pickingInfo != null && !_isLoading) ...[
          _buildHeader(),
          const SizedBox(height: 8),
          Expanded(child: _buildLineList()),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    final info = _pickingInfo!;
    final stateColor = _stateColor(info.state);
    final stateLabel = _stateLabel(info.state);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name, style: AppTextStyles.titleLarge),
                    if (info.origin != null)
                      Text(
                        'SO/PO: ${info.origin}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: stateColor.withOpacity(0.5)),
                ),
                child: Text(
                  stateLabel,
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Vendor / Pengirim',
            value: info.partnerName ?? '-',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.arrow_forward_outlined,
            label: 'Dari',
            value: info.locationName,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.place_outlined,
            label: 'Tujuan',
            value: info.locationDestName,
          ),
          if (info.scheduledDate != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal',
              value: info.scheduledDate!.split(' ').first,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLineList() {
    final info = _pickingInfo!;
    if (info.lines.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Tidak ada produk dalam picking ini',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: info.lines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) => _LineCard(line: info.lines[index]),
    );
  }

  Color _stateColor(String state) {
    switch (state) {
      case 'done':
        return AppColors.success;
      case 'cancel':
        return AppColors.error;
      case 'assigned':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  String _stateLabel(String state) {
    switch (state) {
      case 'draft':
        return 'Draft';
      case 'waiting':
        return 'Waiting';
      case 'confirmed':
        return 'Confirmed';
      case 'assigned':
        return 'Ready';
      case 'done':
        return 'Done';
      case 'cancel':
        return 'Cancelled';
      default:
        return state;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LineCard extends StatelessWidget {
  final PickingLine line;

  const _LineCard({required this.line});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (line.defaultCode != null)
                  Text(
                    '[${line.defaultCode}]',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  line.productName,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${line.qtyDone.toStringAsFixed(line.qtyDone.truncateToDouble() == line.qtyDone ? 0 : 2)} / ${line.qtyDemand.toStringAsFixed(line.qtyDemand.truncateToDouble() == line.qtyDemand ? 0 : 2)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: line.qtyDone >= line.qtyDemand
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              Text(
                line.uom,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
