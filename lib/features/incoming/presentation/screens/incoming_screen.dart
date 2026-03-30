import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/incoming_bloc.dart';
import '../bloc/incoming_event.dart';
import '../bloc/incoming_state.dart';
import '../../../scanner/widgets/qr_scanner_widget.dart';
import '../../../scanner/widgets/step_indicator_widget.dart';
import '../../../scanner/widgets/scanned_info_card.dart';
import '../../../../core/utils/scan_feedback.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class IncomingScreen extends StatelessWidget {
  const IncomingScreen({super.key});

  static const _stepLabels = ['Scan Box', 'Scan Pallet', 'Scan Rack', 'Konfirmasi'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IncomingBloc(),
      child: const _IncomingView(),
    );
  }
}

class _IncomingView extends StatelessWidget {
  const _IncomingView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncomingBloc, IncomingState>(
      listener: (context, state) {
        if (state.step == IncomingStep.done) {
          ScanFeedback.complete();
          _showSuccessAndReset(context);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isConfirming = state.step == IncomingStep.confirming ||
            state.step == IncomingStep.done;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Incoming (Putaway)'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset',
                onPressed: () =>
                    context.read<IncomingBloc>().add(IncomingReset()),
              ),
            ],
          ),
          body: LoadingOverlay(
            isLoading: state.isLoading,
            message: 'Menyimpan putaway...',
            child: Column(
              children: [
                // Step indicator
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: StepIndicatorWidget(
                    currentStep: state.currentStepIndex,
                    totalSteps: 4,
                    stepLabels: IncomingScreen._stepLabels,
                  ),
                ),

                Expanded(
                  child: isConfirming
                      ? _ConfirmView(state: state)
                      : _ScanView(state: state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessAndReset(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('Putaway Berhasil!',
                style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: const Text(
          'Data putaway berhasil disimpan.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<IncomingBloc>().add(IncomingReset());
            },
            child: const Text('Scan Berikutnya'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Kembali ke Dashboard'),
          ),
        ],
      ),
    );
  }
}

class _ScanView extends StatelessWidget {
  final IncomingState state;

  const _ScanView({required this.state});

  @override
  Widget build(BuildContext context) {
    final (expectedType, instruction) = _getStepConfig(state.step);

    return Column(
      children: [
        // Scanner
        Expanded(
          flex: 6,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: QrScannerWidget(
              expectedType: expectedType,
              instruction: instruction,
              onScanSuccess: (code) => _onScanSuccess(context, code),
              onScanError: (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(err),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ),

        // Scanned info below camera
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildScannedInfo(state),
          ),
        ),
      ],
    );
  }

  (String, String) _getStepConfig(IncomingStep step) {
    switch (step) {
      case IncomingStep.scanBox:
        return ('box', '📦 Step 1: Scan QR Code Box');
      case IncomingStep.scanPallet:
        return ('pallet', '🏷️ Step 2: Scan QR Code Pallet');
      case IncomingStep.scanRack:
        return ('rack', '🗄️ Step 3: Scan QR Code Rack');
      default:
        return ('any', 'Scan...');
    }
  }

  void _onScanSuccess(BuildContext context, String code) {
    final bloc = context.read<IncomingBloc>();
    switch (state.step) {
      case IncomingStep.scanBox:
        bloc.add(IncomingBoxScanned(code));
      case IncomingStep.scanPallet:
        bloc.add(IncomingPalletScanned(code));
      case IncomingStep.scanRack:
        bloc.add(IncomingRackScanned(code));
      default:
        break;
    }
  }

  Widget _buildScannedInfo(IncomingState state) {
    final fields = <String, String>{};
    if (state.boxCode != null) fields['BOX ID'] = state.boxCode!;
    if (state.palletCode != null) fields['PALLET ID'] = state.palletCode!;
    if (state.rackCode != null) fields['RACK ID'] = state.rackCode!;

    if (fields.isEmpty) {
      return const Center(
        child: Text(
          'Arahkan kamera ke QR Code',
          style: TextStyle(color: AppColors.textHint),
        ),
      );
    }

    return ScannedInfoCard(
      title: 'Data Ter-scan',
      fields: fields,
    );
  }
}

class _ConfirmView extends StatelessWidget {
  final IncomingState state;

  const _ConfirmView({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Konfirmasi Putaway', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Pastikan data berikut sudah benar sebelum konfirmasi.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),

          ScannedInfoCard(
            title: 'Ringkasan Putaway',
            titleColor: AppColors.success,
            fields: {
              'BOX ID': state.boxCode ?? '-',
              'PALLET ID': state.palletCode ?? '-',
              'RACK ID': state.rackCode ?? '-',
              'WAKTU': _formatNow(),
            },
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'Konfirmasi Putaway',
            icon: Icons.check_circle_outline,
            isLoading: state.isLoading,
            onPressed: () =>
                context.read<IncomingBloc>().add(IncomingConfirmed()),
          ),
          const SizedBox(height: 12),

          AppButton(
            label: 'Scan Ulang',
            icon: Icons.replay,
            isOutlined: true,
            onPressed: () =>
                context.read<IncomingBloc>().add(IncomingReset()),
          ),
        ],
      ),
    );
  }

  String _formatNow() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }
}
