import 'package:flutter/material.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../data/scan_service.dart';
import '../widgets/qr_scanner_widget.dart';
import '../widgets/scanned_info_card.dart';

class ProductInfoScreen extends StatefulWidget {
  final ScanService scanService;

  const ProductInfoScreen({super.key, required this.scanService});

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  LotInfo? _lotInfo;
  String? _errorMessage;
  bool _isLoading = false;
  bool _showResult = false;
  String? _lastCode;

  void _onScanSuccess(String code) async {
    if (code == _lastCode && _showResult) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _lotInfo = null;
      _showResult = false;
      _lastCode = code;
    });

    try {
      final info = await widget.scanService.getLotInfo(code);
      if (!mounted) return;
      setState(() {
        _lotInfo = info;
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
      _lotInfo = null;
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
        title: const Text('Info Product / Lot'),
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
      instruction: 'Scan QR Code pada produk / lot',
      onScanSuccess: _onScanSuccess,
      onScanError: _onScanError,
    );
  }

  Widget _buildResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Loading state
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),

          // Error state
          if (_errorMessage != null && !_isLoading)
            _ErrorCard(message: _errorMessage!),

          // Success state
          if (_lotInfo != null && !_isLoading) ...[
            // Header
            Container(
              padding: const EdgeInsets.all(16),
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
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lotInfo!.productName,
                          style: AppTextStyles.titleLarge,
                        ),
                        Text(
                          'Lot: ${_lotInfo!.lot}',
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
            const SizedBox(height: 16),

            // Info fields
            ScannedInfoCard(
              title: 'Detail Product',
              fields: {
                'Nama Product': _lotInfo!.productName,
                'Lot / Serial': _lotInfo!.lot,
                'Qty Tersedia': '${_lotInfo!.qty.toStringAsFixed(2)} ${_lotInfo!.uom}',
                'Expired Date': _lotInfo!.expiredDate?.isNotEmpty == true
                    ? _lotInfo!.expiredDate!
                    : '-',
              },
            ),
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Lain'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
