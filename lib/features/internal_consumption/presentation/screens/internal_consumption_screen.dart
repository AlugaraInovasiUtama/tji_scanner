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

abstract class InternalConsumptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InternalConsumptionReset extends InternalConsumptionEvent {}

class InternalConsumptionProductScanned extends InternalConsumptionEvent {
  final String code;
  InternalConsumptionProductScanned(this.code);
  @override
  List<Object?> get props => [code];
}

class InternalConsumptionQtyChanged extends InternalConsumptionEvent {
  final double qty;
  InternalConsumptionQtyChanged(this.qty);
  @override
  List<Object?> get props => [qty];
}

class InternalConsumptionConfirmed extends InternalConsumptionEvent {}

// ─── State ─────────────────────────────────────────────────────────────────

enum InternalConsumptionStep { scan, inputQty, done }

class InternalConsumptionState extends Equatable {
  final InternalConsumptionStep step;
  final String? productCode;
  final double qty;
  final bool isLoading;
  final String? errorMessage;

  const InternalConsumptionState({
    this.step = InternalConsumptionStep.scan,
    this.productCode,
    this.qty = 1,
    this.isLoading = false,
    this.errorMessage,
  });

  InternalConsumptionState copyWith({
    InternalConsumptionStep? step,
    String? productCode,
    double? qty,
    bool? isLoading,
    String? errorMessage,
  }) {
    return InternalConsumptionState(
      step: step ?? this.step,
      productCode: productCode ?? this.productCode,
      qty: qty ?? this.qty,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [step, productCode, qty, isLoading, errorMessage];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class InternalConsumptionBloc extends Bloc<InternalConsumptionEvent, InternalConsumptionState> {
  InternalConsumptionBloc() : super(const InternalConsumptionState()) {
    on<InternalConsumptionReset>((e, emit) => emit(const InternalConsumptionState()));
    on<InternalConsumptionProductScanned>((e, emit) {
      emit(state.copyWith(step: InternalConsumptionStep.inputQty, productCode: e.code));
    });
    on<InternalConsumptionQtyChanged>((e, emit) => emit(state.copyWith(qty: e.qty)));
    on<InternalConsumptionConfirmed>((e, emit) async {
      emit(state.copyWith(isLoading: true));
      await Future.delayed(const Duration(milliseconds: 800));
      emit(state.copyWith(isLoading: false, step: InternalConsumptionStep.done));
    });
  }
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class InternalConsumptionScreen extends StatelessWidget {
  const InternalConsumptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InternalConsumptionBloc(),
      child: BlocConsumer<InternalConsumptionBloc, InternalConsumptionState>(
        listener: (context, state) {
          if (state.step == InternalConsumptionStep.done) {
            ScanFeedback.complete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Internal Consumption berhasil!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<InternalConsumptionBloc>().add(InternalConsumptionReset());
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Internal Consumption'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<InternalConsumptionBloc>().add(InternalConsumptionReset()),
                ),
              ],
            ),
            body: LoadingOverlay(
              isLoading: state.isLoading,
              message: 'Menyimpan consumption...',
              child: state.step == InternalConsumptionStep.scan
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
                              instruction: '🛒 Scan QR Code Product yang dikonsumsi',
                              onScanSuccess: (code) => context
                                  .read<InternalConsumptionBloc>()
                                  .add(InternalConsumptionProductScanned(code)),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              'Scan product untuk dicatat sebagai konsumsi internal',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textHint),
                            ),
                          ),
                        ),
                      ],
                    )
                  : _ConsumptionForm(state: state),
            ),
          );
        },
      ),
    );
  }
}

class _ConsumptionForm extends StatefulWidget {
  final InternalConsumptionState state;
  const _ConsumptionForm({required this.state});

  @override
  State<_ConsumptionForm> createState() => _ConsumptionFormState();
}

class _ConsumptionFormState extends State<_ConsumptionForm> {
  final _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
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
            titleColor: const Color(0xFFE91E63),
            fields: {'CODE': widget.state.productCode ?? '-'},
          ),
          const SizedBox(height: 16),
          Text('Jumlah Konsumsi', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  final current = double.tryParse(_qtyController.text) ?? 1;
                  if (current > 1) {
                    _qtyController.text = (current - 1).toString();
                    context.read<InternalConsumptionBloc>().add(
                      InternalConsumptionQtyChanged(current - 1),
                    );
                  }
                },
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary, size: 32),
              ),
              Expanded(
                child: TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) {
                    final qty = double.tryParse(v) ?? 1;
                    context.read<InternalConsumptionBloc>().add(InternalConsumptionQtyChanged(qty));
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  final current = double.tryParse(_qtyController.text) ?? 1;
                  _qtyController.text = (current + 1).toString();
                  context.read<InternalConsumptionBloc>().add(
                    InternalConsumptionQtyChanged(current + 1),
                  );
                },
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Konfirmasi Consumption',
            icon: Icons.shopping_basket_outlined,
            onPressed: () => context.read<InternalConsumptionBloc>().add(InternalConsumptionConfirmed()),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Scan Ulang',
            icon: Icons.replay,
            isOutlined: true,
            onPressed: () => context.read<InternalConsumptionBloc>().add(InternalConsumptionReset()),
          ),
        ],
      ),
    );
  }
}
