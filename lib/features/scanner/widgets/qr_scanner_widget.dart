import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/utils/scan_debouncer.dart';
import '../../../../core/utils/scan_feedback.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class QrScannerWidget extends StatefulWidget {
  final String expectedType; // 'box', 'pallet', 'rack', 'product', 'any'
  final String instruction;
  final void Function(String code) onScanSuccess;
  final void Function(String error)? onScanError;

  const QrScannerWidget({
    super.key,
    required this.expectedType,
    required this.instruction,
    required this.onScanSuccess,
    this.onScanError,
  });

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  final ScanDebouncer _debouncer = ScanDebouncer();
  bool _torchOn = false;
  bool _isProcessing = false;
  ScanResult _scanResult = ScanResult.idle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
      formats: const [BarcodeFormat.qrCode, BarcodeFormat.code128],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _controller.start();
      case AppLifecycleState.inactive:
        _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final code = barcode.rawValue!;

    if (_debouncer.isDuplicate(code)) {
      ScanFeedback.duplicate();
      return;
    }

    // Validate type if not 'any'
    if (widget.expectedType != 'any') {
      final prefix = _prefixForType(widget.expectedType);
      if (!code.startsWith(prefix)) {
        setState(() => _scanResult = ScanResult.error);
        ScanFeedback.error();
        widget.onScanError?.call(
          'Scan salah. Dibutuhkan ${widget.expectedType.toUpperCase()}, bukan kode ini.',
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _scanResult = ScanResult.idle);
        });
        return;
      }
    }

    setState(() {
      _isProcessing = true;
      _scanResult = ScanResult.success;
    });
    _debouncer.recordScan(code);
    ScanFeedback.success();
    widget.onScanSuccess(code);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _scanResult = ScanResult.idle;
        });
      }
    });
  }

  String _prefixForType(String type) {
    switch (type) {
      case 'box':
        return 'BOX-';
      case 'pallet':
        return 'PAL-';
      case 'rack':
        return 'RACK-';
      case 'product':
        return 'PROD-';
      default:
        return '';
    }
  }

  Color get _borderColor {
    switch (_scanResult) {
      case ScanResult.success:
        return AppColors.success;
      case ScanResult.error:
        return AppColors.error;
      case ScanResult.idle:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera view
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),

        // Dark overlay with cutout
        _ScanOverlay(borderColor: _borderColor),

        // Top instruction
        Positioned(
          top: 24,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.instruction,
              textAlign: TextAlign.center,
              style: AppTextStyles.scanInstruction,
            ),
          ),
        ),

        // Torch toggle
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.small(
            heroTag: 'torch',
            backgroundColor: _torchOn ? AppColors.primary : AppColors.surface,
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
            child: Icon(
              _torchOn ? Icons.flashlight_on : Icons.flashlight_off,
              color: _torchOn ? Colors.black : AppColors.textPrimary,
            ),
          ),
        ),

        // Processing indicator
        if (_isProcessing)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum ScanResult { idle, success, error }

class _ScanOverlay extends StatelessWidget {
  final Color borderColor;

  const _ScanOverlay({required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(borderColor: borderColor),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Color borderColor;

  _OverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 240.0;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: cutoutSize,
      height: cutoutSize,
    );

    // Dark overlay
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    // Corner borders
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;
    final l = cutoutRect.left;
    final t = cutoutRect.top;
    final r = cutoutRect.right;
    final b = cutoutRect.bottom;

    // Top-left
    canvas.drawLine(Offset(l, t + cornerLength), Offset(l, t), borderPaint);
    canvas.drawLine(Offset(l, t), Offset(l + cornerLength, t), borderPaint);
    // Top-right
    canvas.drawLine(Offset(r - cornerLength, t), Offset(r, t), borderPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + cornerLength), borderPaint);
    // Bottom-left
    canvas.drawLine(Offset(l, b - cornerLength), Offset(l, b), borderPaint);
    canvas.drawLine(Offset(l, b), Offset(l + cornerLength, b), borderPaint);
    // Bottom-right
    canvas.drawLine(Offset(r - cornerLength, b), Offset(r, b), borderPaint);
    canvas.drawLine(Offset(r, b), Offset(r, b - cornerLength), borderPaint);
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
