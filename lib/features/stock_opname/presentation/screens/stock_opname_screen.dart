import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/stock_opname_bloc.dart';
import '../bloc/stock_opname_event.dart';
import '../bloc/stock_opname_state.dart';
import '../../../scanner/widgets/qr_scanner_widget.dart';
import '../../../../core/utils/scan_feedback.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class StockOpnameScreen extends StatelessWidget {
  const StockOpnameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockOpnameBloc(),
      child: const _StockOpnameView(),
    );
  }
}

class _StockOpnameView extends StatelessWidget {
  const _StockOpnameView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StockOpnameBloc, StockOpnameState>(
      listener: (context, state) {
        if (state.step == StockOpnameStep.done) {
          ScanFeedback.complete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stock opname berhasil disimpan!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<StockOpnameBloc>().add(StockOpnameReset());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Stock Opname'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<StockOpnameBloc>().add(StockOpnameReset()),
              ),
              if (state.step == StockOpnameStep.scanning && state.scannedBoxes.isNotEmpty)
                TextButton(
                  onPressed: () => context.read<StockOpnameBloc>().add(StockOpnameConfirmed()),
                  child: const Text('Selesai', style: TextStyle(color: AppColors.primary)),
                ),
            ],
          ),
          body: LoadingOverlay(
            isLoading: state.isLoading,
            message: 'Menyimpan stock opname...',
            child: state.step == StockOpnameStep.scanRack
                ? _ScanRackView()
                : _ScanningView(state: state),
          ),
        );
      },
    );
  }
}

class _ScanRackView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 7,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: QrScannerWidget(
              expectedType: 'rack',
              instruction: '🗄️ Scan QR Code Rack untuk mulai Stock Opname',
              onScanSuccess: (code) =>
                  context.read<StockOpnameBloc>().add(StockOpnameRackScanned(code)),
              onScanError: (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err), backgroundColor: AppColors.error),
                );
              },
            ),
          ),
        ),
        const Expanded(
          flex: 3,
          child: Center(
            child: Text(
              'Scan rack terlebih dahulu untuk memulai',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanningView extends StatelessWidget {
  final StockOpnameState state;
  const _ScanningView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info rack
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Rack: ${state.rackCode ?? '-'}', style: AppTextStyles.titleMedium),
              const Spacer(),
              Text('${state.scannedBoxes.length} box', style: AppTextStyles.bodySmall),
            ],
          ),
        ),

        // Scanner
        SizedBox(
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: QrScannerWidget(
                expectedType: 'box',
                instruction: '📦 Scan Box untuk opname',
                onScanSuccess: (code) =>
                    context.read<StockOpnameBloc>().add(StockOpnameBoxScanned(code)),
                onScanError: (err) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: AppColors.error),
                  );
                },
              ),
            ),
          ),
        ),

        // Box list
        Expanded(
          child: state.scannedBoxes.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada box yang di-scan',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.scannedBoxes.length,
                  itemBuilder: (context, index) {
                    final box = state.scannedBoxes[index];
                    return _BoxQtyTile(box: box, index: index);
                  },
                ),
        ),

        if (state.scannedBoxes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: AppButton(
              label: 'Selesai & Konfirmasi',
              icon: Icons.check_circle_outline,
              onPressed: () => context.read<StockOpnameBloc>().add(StockOpnameConfirmed()),
            ),
          ),
      ],
    );
  }
}

class _BoxQtyTile extends StatefulWidget {
  final ScannedBoxItem box;
  final int index;

  const _BoxQtyTile({required this.box, required this.index});

  @override
  State<_BoxQtyTile> createState() => _BoxQtyTileState();
}

class _BoxQtyTileState extends State<_BoxQtyTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.box.actualQty > 0 ? widget.box.actualQty.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${widget.index + 1}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.box.boxCode, style: AppTextStyles.titleMedium),
                  Text(
                    'Sistem: ${widget.box.systemQty}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: TextFormField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Aktual',
                  labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 11),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (v) {
                  final qty = double.tryParse(v) ?? 0;
                  context.read<StockOpnameBloc>().add(
                    StockOpnameActualQtyChanged(widget.box.boxCode, qty),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
