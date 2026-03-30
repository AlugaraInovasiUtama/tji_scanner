import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../scanner/widgets/qr_scanner_widget.dart';
import '../../../scanner/widgets/step_indicator_widget.dart';
import '../../../scanner/widgets/scanned_info_card.dart';
import '../../../../core/utils/scan_feedback.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class InternalTransferEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InternalTransferReset extends InternalTransferEvent {}

class InternalTransferSourceScanned extends InternalTransferEvent {
  final String code;
  InternalTransferSourceScanned(this.code);
  @override
  List<Object?> get props => [code];
}

class InternalTransferDestinationScanned extends InternalTransferEvent {
  final String code;
  InternalTransferDestinationScanned(this.code);
  @override
  List<Object?> get props => [code];
}

class InternalTransferConfirmed extends InternalTransferEvent {}

// ─── States ─────────────────────────────────────────────────────────────────

enum InternalTransferStep { scanSource, scanDestination, confirming, done }

class InternalTransferState extends Equatable {
  final InternalTransferStep step;
  final String? sourceCode;
  final String? destinationCode;
  final bool isLoading;
  final String? errorMessage;

  const InternalTransferState({
    this.step = InternalTransferStep.scanSource,
    this.sourceCode,
    this.destinationCode,
    this.isLoading = false,
    this.errorMessage,
  });

  InternalTransferState copyWith({
    InternalTransferStep? step,
    String? sourceCode,
    String? destinationCode,
    bool? isLoading,
    String? errorMessage,
  }) {
    return InternalTransferState(
      step: step ?? this.step,
      sourceCode: sourceCode ?? this.sourceCode,
      destinationCode: destinationCode ?? this.destinationCode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  int get currentStepIndex {
    switch (step) {
      case InternalTransferStep.scanSource: return 1;
      case InternalTransferStep.scanDestination: return 2;
      case InternalTransferStep.confirming:
      case InternalTransferStep.done: return 3;
    }
  }

  @override
  List<Object?> get props => [step, sourceCode, destinationCode, isLoading, errorMessage];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class InternalTransferBloc extends Bloc<InternalTransferEvent, InternalTransferState> {
  InternalTransferBloc() : super(const InternalTransferState()) {
    on<InternalTransferReset>((e, emit) => emit(const InternalTransferState()));
    on<InternalTransferSourceScanned>((e, emit) {
      if (state.step != InternalTransferStep.scanSource) return;
      emit(state.copyWith(step: InternalTransferStep.scanDestination, sourceCode: e.code));
    });
    on<InternalTransferDestinationScanned>((e, emit) {
      if (state.step != InternalTransferStep.scanDestination) return;
      emit(state.copyWith(step: InternalTransferStep.confirming, destinationCode: e.code));
    });
    on<InternalTransferConfirmed>((e, emit) async {
      emit(state.copyWith(isLoading: true));
      await Future.delayed(const Duration(milliseconds: 800));
      emit(state.copyWith(isLoading: false, step: InternalTransferStep.done));
    });
  }
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class InternalTransferScreen extends StatelessWidget {
  const InternalTransferScreen({super.key});

  static const _stepLabels = ['Sumber', 'Tujuan', 'Konfirmasi'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InternalTransferBloc(),
      child: BlocConsumer<InternalTransferBloc, InternalTransferState>(
        listener: (context, state) {
          if (state.step == InternalTransferStep.done) {
            ScanFeedback.complete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Internal Transfer berhasil!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<InternalTransferBloc>().add(InternalTransferReset());
          }
        },
        builder: (context, state) {
          final isConfirming = state.step == InternalTransferStep.confirming ||
              state.step == InternalTransferStep.done;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Internal Transfer'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<InternalTransferBloc>().add(InternalTransferReset()),
                ),
              ],
            ),
            body: LoadingOverlay(
              isLoading: state.isLoading,
              message: 'Menyimpan transfer...',
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: StepIndicatorWidget(
                      currentStep: state.currentStepIndex,
                      totalSteps: 3,
                      stepLabels: _stepLabels,
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
      ),
    );
  }
}

class _ScanView extends StatelessWidget {
  final InternalTransferState state;
  const _ScanView({required this.state});

  @override
  Widget build(BuildContext context) {
    final isSource = state.step == InternalTransferStep.scanSource;
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
              expectedType: 'any',
              instruction: isSource
                  ? '📦 Step 1: Scan Lokasi / Pallet Sumber'
                  : '🗄️ Step 2: Scan Rack Tujuan',
              onScanSuccess: (code) {
                final bloc = context.read<InternalTransferBloc>();
                isSource
                    ? bloc.add(InternalTransferSourceScanned(code))
                    : bloc.add(InternalTransferDestinationScanned(code));
              },
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.sourceCode == null
                ? const Center(child: Text('Arahkan kamera ke QR Code', style: TextStyle(color: AppColors.textHint)))
                : ScannedInfoCard(
                    title: 'Data Ter-scan',
                    fields: {
                      if (state.sourceCode != null) 'SUMBER': state.sourceCode!,
                      if (state.destinationCode != null) 'TUJUAN': state.destinationCode!,
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmView extends StatelessWidget {
  final InternalTransferState state;
  const _ConfirmView({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Konfirmasi Transfer', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),
          ScannedInfoCard(
            title: 'Ringkasan Transfer',
            titleColor: AppColors.info,
            fields: {
              'SUMBER': state.sourceCode ?? '-',
              'TUJUAN': state.destinationCode ?? '-',
            },
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Konfirmasi Transfer',
            icon: Icons.swap_horiz,
            onPressed: () => context.read<InternalTransferBloc>().add(InternalTransferConfirmed()),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Scan Ulang',
            icon: Icons.replay,
            isOutlined: true,
            onPressed: () => context.read<InternalTransferBloc>().add(InternalTransferReset()),
          ),
        ],
      ),
    );
  }
}
