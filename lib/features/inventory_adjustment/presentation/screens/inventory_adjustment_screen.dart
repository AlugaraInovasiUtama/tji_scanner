import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../scanner/widgets/qr_scanner_widget.dart';
import '../../../scanner/widgets/scanned_info_card.dart';
import '../../../../core/utils/scan_feedback.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class InventoryAdjEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InventoryAdjReset extends InventoryAdjEvent {}

class InventoryAdjProductScanned extends InventoryAdjEvent {
  final String code;
  InventoryAdjProductScanned(this.code);
  @override
  List<Object?> get props => [code];
}

class InventoryAdjQtyChanged extends InventoryAdjEvent {
  final double qty;
  InventoryAdjQtyChanged(this.qty);
  @override
  List<Object?> get props => [qty];
}

class InventoryAdjReasonChanged extends InventoryAdjEvent {
  final String reason;
  InventoryAdjReasonChanged(this.reason);
  @override
  List<Object?> get props => [reason];
}

class InventoryAdjConfirmed extends InventoryAdjEvent {}

// ─── State ─────────────────────────────────────────────────────────────────

enum InventoryAdjStep { scan, inputQty, confirming, done }

class InventoryAdjState extends Equatable {
  final InventoryAdjStep step;
  final String? productCode;
  final double adjustQty;
  final String reason;
  final bool isLoading;
  final String? errorMessage;

  const InventoryAdjState({
    this.step = InventoryAdjStep.scan,
    this.productCode,
    this.adjustQty = 0,
    this.reason = '',
    this.isLoading = false,
    this.errorMessage,
  });

  InventoryAdjState copyWith({
    InventoryAdjStep? step,
    String? productCode,
    double? adjustQty,
    String? reason,
    bool? isLoading,
    String? errorMessage,
  }) {
    return InventoryAdjState(
      step: step ?? this.step,
      productCode: productCode ?? this.productCode,
      adjustQty: adjustQty ?? this.adjustQty,
      reason: reason ?? this.reason,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [step, productCode, adjustQty, reason, isLoading, errorMessage];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class InventoryAdjBloc extends Bloc<InventoryAdjEvent, InventoryAdjState> {
  InventoryAdjBloc() : super(const InventoryAdjState()) {
    on<InventoryAdjReset>((e, emit) => emit(const InventoryAdjState()));
    on<InventoryAdjProductScanned>((e, emit) {
      emit(state.copyWith(step: InventoryAdjStep.inputQty, productCode: e.code));
    });
    on<InventoryAdjQtyChanged>((e, emit) {
      emit(state.copyWith(adjustQty: e.qty, step: InventoryAdjStep.confirming));
    });
    on<InventoryAdjReasonChanged>((e, emit) => emit(state.copyWith(reason: e.reason)));
    on<InventoryAdjConfirmed>((e, emit) async {
      emit(state.copyWith(isLoading: true));
      await Future.delayed(const Duration(milliseconds: 800));
      emit(state.copyWith(isLoading: false, step: InventoryAdjStep.done));
    });
  }
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class InventoryAdjustmentScreen extends StatelessWidget {
  const InventoryAdjustmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryAdjBloc(),
      child: BlocConsumer<InventoryAdjBloc, InventoryAdjState>(
        listener: (context, state) {
          if (state.step == InventoryAdjStep.done) {
            ScanFeedback.complete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inventory Adjustment berhasil!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<InventoryAdjBloc>().add(InventoryAdjReset());
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Inventory Adjustment'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<InventoryAdjBloc>().add(InventoryAdjReset()),
                ),
              ],
            ),
            body: LoadingOverlay(
              isLoading: state.isLoading,
              message: 'Menyimpan adjustment...',
              child: state.step == InventoryAdjStep.scan
                  ? Column(
                      children: [
                        Expanded(
                          flex: 7,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            child: QrScannerWidget(
                              expectedType: 'any',
                              instruction: '🔍 Scan QR Code Product / Box',
                              onScanSuccess: (code) =>
                                  context.read<InventoryAdjBloc>().add(InventoryAdjProductScanned(code)),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              'Scan product untuk memulai adjustment',
                              style: TextStyle(color: AppColors.textHint),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _AdjustmentForm(state: state),
            ),
          );
        },
      ),
    );
  }
}

class _AdjustmentForm extends StatefulWidget {
  final InventoryAdjState state;
  const _AdjustmentForm({required this.state});

  @override
  State<_AdjustmentForm> createState() => _AdjustmentFormState();
}

class _AdjustmentFormState extends State<_AdjustmentForm> {
  final _qtyController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScannedInfoCard(
            title: 'Product',
            fields: {'CODE': widget.state.productCode ?? '-'},
          ),
          const SizedBox(height: 16),
          Text('Input Adjustment', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qtyController,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Qty Adjustment (+/-)',
              hintText: 'Contoh: 5 atau -3',
              prefixIcon: const Icon(Icons.tune, color: AppColors.textHint),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _reasonController,
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: (v) => context.read<InventoryAdjBloc>().add(InventoryAdjReasonChanged(v)),
            decoration: InputDecoration(
              labelText: 'Alasan Adjustment',
              hintText: 'Contoh: Barang rusak, kesalahan input...',
              prefixIcon: const Icon(Icons.notes, color: AppColors.textHint),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Konfirmasi Adjustment',
            icon: Icons.check_circle_outline,
            onPressed: () {
              final qty = double.tryParse(_qtyController.text) ?? 0;
              context.read<InventoryAdjBloc>().add(InventoryAdjQtyChanged(qty));
              context.read<InventoryAdjBloc>().add(InventoryAdjConfirmed());
            },
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Scan Ulang',
            icon: Icons.replay,
            isOutlined: true,
            onPressed: () => context.read<InventoryAdjBloc>().add(InventoryAdjReset()),
          ),
        ],
      ),
    );
  }
}
