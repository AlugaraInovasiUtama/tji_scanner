import 'package:flutter/material.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../data/scan_service.dart';
import '../widgets/qr_scanner_widget.dart';

class LocationInfoScreen extends StatefulWidget {
  final ScanService scanService;

  const LocationInfoScreen({super.key, required this.scanService});

  @override
  State<LocationInfoScreen> createState() => _LocationInfoScreenState();
}

class _LocationInfoScreenState extends State<LocationInfoScreen> {
  LocationInfo? _locationInfo;
  String? _errorMessage;
  bool _isLoading = false;
  bool _showResult = false;
  String? _lastCode;

  void _onScanSuccess(String code) async {
    if (code == _lastCode && _showResult) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _locationInfo = null;
      _showResult = false;
      _lastCode = code;
    });

    try {
      final info = await widget.scanService.getLocationInfo(code);
      if (!mounted) return;
      setState(() {
        _locationInfo = info;
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
      _locationInfo = null;
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
        title: const Text('Info Lokasi'),
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
      instruction: 'Scan QR Code pada rak / lokasi untuk melihat sub lokasi',
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
        if (_locationInfo != null && !_isLoading) ...[
          // Header lokasi
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3460), Color(0xFF16213E)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.info,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _locationInfo!.location,
                        style: AppTextStyles.titleLarge,
                      ),
                      Text(
                        '${_locationInfo!.totalChilds} sub lokasi',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Child locations
          Expanded(
            child: _locationInfo!.lines.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Tidak ada sub lokasi',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _locationInfo!.lines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final location = _locationInfo!.lines[index];
                      return _LocationChildCard(location: location);
                    },
                  ),
          ),
        ],

        // Tombol scan ulang
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Lokasi Lain'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationChildCard extends StatelessWidget {
  final LocationChild location;

  const _LocationChildCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location name + usage badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getLocationIcon(location.usage),
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      location.completeName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getUsageColor(location.usage).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _getUsageColor(location.usage).withOpacity(0.4)),
                ),
                child: Text(
                  _getUsageLabel(location.usage),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _getUsageColor(location.usage),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (location.barcode != null) ...[
            const SizedBox(height: 8),
            _Chip(
              icon: Icons.qr_code,
              label: location.barcode!,
              color: AppColors.info,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getLocationIcon(String usage) {
    switch (usage) {
      case 'internal':
        return Icons.inventory_2_outlined;
      case 'view':
        return Icons.folder_outlined;
      case 'customer':
        return Icons.person_outlined;
      case 'supplier':
        return Icons.business_outlined;
      case 'inventory':
        return Icons.assignment_outlined;
      case 'production':
        return Icons.precision_manufacturing_outlined;
      case 'transit':
        return Icons.local_shipping_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  Color _getUsageColor(String usage) {
    switch (usage) {
      case 'internal':
        return AppColors.primary;
      case 'view':
        return AppColors.info;
      case 'customer':
        return AppColors.success;
      case 'supplier':
        return AppColors.warning;
      case 'inventory':
        return AppColors.textSecondary;
      case 'production':
        return Colors.purple;
      case 'transit':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  String _getUsageLabel(String usage) {
    switch (usage) {
      case 'internal':
        return 'Internal';
      case 'view':
        return 'View';
      case 'customer':
        return 'Customer';
      case 'supplier':
        return 'Supplier';
      case 'inventory':
        return 'Inventory';
      case 'production':
        return 'Production';
      case 'transit':
        return 'Transit';
      default:
        return usage;
    }
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
