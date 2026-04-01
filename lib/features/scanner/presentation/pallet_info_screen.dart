import 'package:flutter/material.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../data/scan_service.dart';
import '../widgets/qr_scanner_widget.dart';

class PalletInfoScreen extends StatefulWidget {
  final ScanService scanService;

  const PalletInfoScreen({super.key, required this.scanService});

  @override
  State<PalletInfoScreen> createState() => _PalletInfoScreenState();
}

class _PalletInfoScreenState extends State<PalletInfoScreen> {
  PalletInfo? _palletInfo;
  String? _errorMessage;
  bool _isLoading = false;
  bool _showResult = false;
  String? _lastCode;

  void _onScanSuccess(String code) async {
    if (code == _lastCode && _showResult) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _palletInfo = null;
      _showResult = false;
      _lastCode = code;
    });

    try {
      final info = await widget.scanService.getPalletInfo(code);
      if (!mounted) return;
      setState(() {
        _palletInfo = info;
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
      _palletInfo = null;
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
        title: const Text('Info Pallet'),
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
      instruction: 'Scan QR Code pada lokasi pallet untuk melihat isi paket',
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
        if (_palletInfo != null && !_isLoading) ...[
          // Header pallet
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
                    color: AppColors.success.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.view_in_ar_outlined,
                    color: AppColors.success,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _palletInfo!.pallet,
                        style: AppTextStyles.titleLarge,
                      ),
                      Text(
                        '${_palletInfo!.totalPackages} paket',
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

          // Package list
          Expanded(
            child: _palletInfo!.packages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Tidak ada paket di lokasi ini',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _palletInfo!.packages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      return _PackageCard(
                          package: _palletInfo!.packages[index]);
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
              label: const Text('Scan Pallet Lain'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
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

// ── Package Card ──────────────────────────────────────────────────────────────

class _PackageCard extends StatefulWidget {
  final PalletPackage package;

  const _PackageCard({required this.package});

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Package header – tap to expand/collapse
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_outlined,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.package.packageName,
                          style: AppTextStyles.titleMedium,
                        ),
                        if (widget.package.packageType != null &&
                            widget.package.packageType!.isNotEmpty)
                          Text(
                            widget.package.packageType!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.package.products.length} item',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Products
          if (_expanded && widget.package.products.isNotEmpty) ...[
            Divider(
                height: 1, color: AppColors.divider, indent: 14, endIndent: 14),
            ...widget.package.products.map(
              (product) => _ProductRow(product: product),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Product Row ───────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  final PalletProduct product;

  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name + default code
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.circle,
                size: 8,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.defaultCode != null &&
                        product.defaultCode!.isNotEmpty)
                      Text(
                        '[${product.defaultCode}]',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      product.productName,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              // Qty badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  '${product.qty.toStringAsFixed(2)} ${product.uom}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Lot & expiry
          if (product.lot != null && product.lot!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 16),
                _Chip(
                  icon: Icons.tag,
                  label: 'Lot: ${product.lot!}',
                  color: AppColors.info,
                ),
                if (product.expirationDate != null &&
                    product.expirationDate!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _Chip(
                    icon: Icons.event_outlined,
                    label: product.expirationDate!,
                    color: AppColors.warning,
                  ),
                ],
              ],
            ),
          ],

          // Packaging
          if (product.packaging != null && product.packaging!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 16),
                _Chip(
                  icon: Icons.category_outlined,
                  label: product.capacityPackaging != null
                      ? '${product.packaging!}  ×${product.capacityPackaging!.toStringAsFixed(0)} ${product.uomPackaging ?? ''}'
                      : product.packaging!,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shared Chip ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }
}

// ── Error Card ────────────────────────────────────────────────────────────────

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
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
