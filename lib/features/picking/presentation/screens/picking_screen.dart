import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/picking_bloc.dart';
import '../bloc/picking_event.dart';
import '../bloc/picking_state.dart';
import '../../../scanner/widgets/qr_scanner_widget.dart';
import '../../../scanner/widgets/step_indicator_widget.dart';
import '../../../scanner/widgets/scanned_info_card.dart';
import '../../../../core/utils/scan_feedback.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class PickingScreen extends StatelessWidget {
  const PickingScreen({super.key});

  static const _stepLabels = ['Scan Product', 'Scan Pallet', 'Konfirmasi'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PickingBloc(),
      child: const _PickingView(),
    );
  }
}

class _PickingView extends StatelessWidget {
  const _PickingView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PickingBloc, PickingState>(
      listener: (context, state) {
        if (state.step == PickingStep.done) {
          ScanFeedback.complete();
          _showSuccess(context);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final isConfirming = state.step == PickingStep.confirming || state.step == PickingStep.done;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Picking / Delivery'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<PickingBloc>().add(PickingReset()),
              ),
            ],
          ),
          body: LoadingOverlay(
            isLoading: state.isLoading,
            message: 'Menyimpan picking...',
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: StepIndicatorWidget(
                    currentStep: state.currentStepIndex,
                    totalSteps: 3,
                    stepLabels: PickingScreen._stepLabels,
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

  void _showSuccess(BuildContext context) {
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
            Text('Picking Berhasil!', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: const Text('Data picking berhasil disimpan.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PickingBloc>().add(PickingReset());
            },
            child: const Text('Picking Berikutnya'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }
}

class _ScanView extends StatelessWidget {
  final PickingState state;
  const _ScanView({required this.state});

  @override
  Widget build(BuildContext context) {
    final (type, instruction) = state.step == PickingStep.scanProduct
        ? ('product', '🏷️ Step 1: Scan QR Code Product')
        : ('pallet', '📦 Step 2: Scan QR Code Pallet');

    return Column(
      children: [
        Expanded(
          flex: 6,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: QrScannerWidget(
              expectedType: type,
              instruction: instruction,
              onScanSuccess: (code) {
                final bloc = context.read<PickingBloc>();
                if (state.step == PickingStep.scanProduct) {
                  bloc.add(PickingProductScanned(code));
                } else {
                  bloc.add(PickingPalletScanned(code));
                }
              },
              onScanError: (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err), backgroundColor: AppColors.error),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.productCode == null
                ? const Center(child: Text('Arahkan kamera ke QR Code', style: TextStyle(color: AppColors.textHint)))
                : ScannedInfoCard(
                    title: 'Data Ter-scan',
                    fields: {
                      if (state.productCode != null) 'PRODUCT ID': state.productCode!,
                      if (state.palletCode != null) 'PALLET ID': state.palletCode!,
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmView extends StatelessWidget {
  final PickingState state;
  const _ConfirmView({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Konfirmasi Picking', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),
          ScannedInfoCard(
            title: 'Ringkasan Picking',
            titleColor: AppColors.success,
            fields: {
              'PRODUCT ID': state.productCode ?? '-',
              'PALLET ID': state.palletCode ?? '-',
            },
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Konfirmasi Picking',
            icon: Icons.check_circle_outline,
            isLoading: state.isLoading,
            onPressed: () => context.read<PickingBloc>().add(PickingConfirmed()),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Scan Ulang',
            icon: Icons.replay,
            isOutlined: true,
            onPressed: () => context.read<PickingBloc>().add(PickingReset()),
          ),
        ],
      ),
    );
  }
}
