import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/validasi_picking_bloc.dart';
import '../bloc/validasi_picking_event.dart';
import '../bloc/validasi_picking_state.dart';
import '../../../scanner/widgets/qr_scanner_widget.dart';
import '../../../scanner/widgets/step_indicator_widget.dart';
import '../../../scanner/widgets/scanned_info_card.dart';
import '../../../../core/utils/scan_feedback.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../features/scanner/data/scan_service.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';


class ValidasiPickingScreen extends StatelessWidget {
  final ScanService scanService;
  const ValidasiPickingScreen({super.key, required this.scanService});

  static const _stepLabels = ['Scan Picking', 'Produk & Lot', 'Lokasi', 'Konfirmasi'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ValidasiPickingBloc(scanService),
      child: const _ValidasiPickingView(),
    );
  }
}

// ─── Main view ───────────────────────────────────────────────────────────────

class _ValidasiPickingView extends StatelessWidget {
  const _ValidasiPickingView();

  bool _isAdmin(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Treat everyone who is NOT explicitly 'helper' as admin (full access)
      return authState.user.role != 'helper';
    }
    return true; // default: full access
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ValidasiPickingBloc, ValidasiPickingState>(
      listener: (context, state) {
        if (state.step == ValidasiPickingStep.done) {
          ScanFeedback.complete();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        String loadingMsg = 'Memproses...';
        if (state.step == ValidasiPickingStep.scanPicking) {
          loadingMsg = 'Mengambil data picking...';
        } else if (state.step == ValidasiPickingStep.scanLocation) {
          loadingMsg = 'Memverifikasi lokasi...';
        } else if (state.step == ValidasiPickingStep.confirming) {
          loadingMsg = 'Memvalidasi picking & transfer...';
        }

        final canGoBack = state.step != ValidasiPickingStep.scanPicking &&
            state.step != ValidasiPickingStep.done;

        return WillPopScope(
          onWillPop: () async {
            if (canGoBack) {
              context.read<ValidasiPickingBloc>().add(ValidasiPickingGoBack());
              return false;
            }
            return true;
          },
          child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Validasi Picking'),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            leading: canGoBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () =>
                        context.read<ValidasiPickingBloc>().add(ValidasiPickingGoBack()),
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset',
                onPressed: () =>
                    context.read<ValidasiPickingBloc>().add(ValidasiPickingReset()),
              ),
            ],
          ),
          body: LoadingOverlay(
            isLoading: state.isLoading,
            message: loadingMsg,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: StepIndicatorWidget(
                    currentStep: state.currentStepIndex,
                    totalSteps: 4,
                    stepLabels: ValidasiPickingScreen._stepLabels,
                  ),
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ValidasiPickingState state) {
    final isAdmin = _isAdmin(context);
    switch (state.step) {
      case ValidasiPickingStep.scanPicking:
        return _ScanPickingView();
      case ValidasiPickingStep.showProducts:
        return _ShowProductsView(state: state, isAdmin: isAdmin);
      case ValidasiPickingStep.scanLocation:
        return _ScanLocationView(state: state);
      case ValidasiPickingStep.confirming:
        return _ConfirmView(state: state, isAdmin: isAdmin);
      case ValidasiPickingStep.done:
        return _ResultView(state: state);
    }
  }
}

// ─── Step 1: Scan Picking ────────────────────────────────────────────────────

class _ScanPickingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              instruction: '📋 Step 1: Scan QR nomor Picking',
              onScanSuccess: (code) {
                context
                    .read<ValidasiPickingBloc>()
                    .add(ValidasiPickingPickingScanned(code));
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Scan barcode / QR kode pada dokumen picking',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Step 2: Produk & Lot ────────────────────────────────────────────────────

class _ShowProductsView extends StatelessWidget {
  final ValidasiPickingState state;
  final bool isAdmin;
  const _ShowProductsView({required this.state, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final lines = state.pickingInfo?.lines ?? [];
    final trackedIncomplete = lines.any((l) {
      if (l.tracking == 'none') return false;
      final d = state.moveLotMap[l.moveId];
      return d == null || !d.isComplete;
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ScannedInfoCard(
            title: '✅ Picking',
            titleColor: AppColors.success,
            fields: {
              'Nomor': state.pickingName ?? '-',
              if (state.pickingInfo?.pickingTypeName != null && state.pickingInfo!.pickingTypeName!.isNotEmpty)
                'Tipe': state.pickingInfo!.pickingTypeName!,
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            isAdmin
                ? 'Isi lot/serial untuk produk yang membutuhkan. Tap ikon lokasi untuk set lokasi tujuan per produk.'
                : 'Isi lot/serial untuk produk yang membutuhkan.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: lines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final line = lines[i];
              final lotData = state.moveLotMap[line.moveId];
              final needsLot = line.tracking != 'none';
              final isDone = !needsLot || (lotData?.isComplete ?? false);
              return _ProductLineCard(
                line: line,
                lotData: lotData,
                isDone: isDone,
                isAdmin: isAdmin,
                onEdit: needsLot
                    ? () async {
                        final bloc = context.read<ValidasiPickingBloc>();
                        final result = await showModalBottomSheet<MoveLotData>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.surface,
                        elevation: 4,
                        builder: (sheetCtx) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
                          ),
                          child: _LotEntrySheet(
                            line: line,
                            initialData: lotData,
                            bloc: bloc,
                          ),
                        ),
                      );
                        if (result != null && context.mounted) {
                          context
                              .read<ValidasiPickingBloc>()
                              .add(ValidasiPickingLotUpdated(result));
                        }
                      }
                    : null,
                onLocationTap: isAdmin
                    ? () async {
                        final bloc = context.read<ValidasiPickingBloc>();
                        final result = await showModalBottomSheet<_LocationResult>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.surface,
                          elevation: 4,
                          builder: (_) => _LocationScanSheet(
                            bloc: bloc,
                            moveId: line.moveId,
                            currentLocationName: lotData?.destLocationName,
                          ),
                        );
                        if (result != null && context.mounted) {
                          if (result.clear) {
                            context.read<ValidasiPickingBloc>().add(
                                  ValidasiPickingMoveLocationCleared(line.moveId),
                                );
                          } else {
                            context.read<ValidasiPickingBloc>().add(
                                  ValidasiPickingMoveLocationSet(
                                    line.moveId,
                                    result.code,
                                    result.name,
                                  ),
                                );
                          }
                        }
                      }
                    : null,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isAdmin && state.someButNotAllMovesHaveLocation)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Set lokasi untuk semua produk, atau kosongkan semua lokasi untuk lanjut.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                  ),
                ),
              AppButton(
                label: isAdmin
                    ? (state.allMovesHaveLocation
                        ? 'Langsung ke Konfirmasi'
                        : 'Lanjut ke Lokasi Tujuan')
                    : 'Lanjut ke Konfirmasi',
                icon: (isAdmin && state.allMovesHaveLocation) || !isAdmin
                    ? Icons.check_circle_outline
                    : Icons.arrow_forward,
                onPressed: (trackedIncomplete || (isAdmin && state.someButNotAllMovesHaveLocation))
                    ? null
                    : () => context
                        .read<ValidasiPickingBloc>()
                        .add(ValidasiPickingProductsConfirmed(skipLocation: !isAdmin)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Product card ─────────────────────────────────────────────────────────────

class _ProductLineCard extends StatelessWidget {
  final PickingLine line;
  final MoveLotData? lotData;
  final bool isDone;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onLocationTap;

  const _ProductLineCard({
    required this.line,
    required this.lotData,
    required this.isDone,
    required this.isAdmin,
    this.onEdit,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isDone ? AppColors.success : AppColors.warning;
    final statusIcon = isDone ? Icons.check_circle : Icons.edit_note;
    final trackingLabel = line.tracking == 'none'
        ? null
        : line.tracking == 'serial'
            ? 'Serial'
            : 'Lot';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(line.productName, style: AppTextStyles.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (line.defaultCode != null)
              Text('[${line.defaultCode}]',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            Text(
              'Demand: ${line.qtyDemand.toStringAsFixed(line.qtyDemand % 1 == 0 ? 0 : 2)} ${line.uom}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            if (trackingLabel != null && (lotData?.lots.isNotEmpty ?? false))
              Text(
                '${lotData!.lots.length} $trackingLabel — '
                '${lotData!.lots.map((e) => e.lotName).join(', ')}',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else if (trackingLabel != null)
              Text('Belum ada $trackingLabel',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.warning)),
            // Per-product destination location (admin only)
            if (isAdmin)
              GestureDetector(
                onTap: onLocationTap,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: lotData?.destLocationName != null
                          ? AppColors.info
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        lotData?.destLocationName ?? 'Tap untuk set lokasi tujuan',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: lotData?.destLocationName != null
                              ? AppColors.info
                              : AppColors.textHint,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lotData?.destLocationName != null)
                      GestureDetector(
                        onTap: onLocationTap,
                        child: const Icon(Icons.close, size: 13, color: AppColors.textHint),
                      ),
                  ],
                ),
              ),
          ],
        ),
        trailing: onEdit != null
            ? TextButton(
                onPressed: onEdit,
                child: Text(
                  (lotData?.lots.isNotEmpty ?? false) ? 'Edit' : 'Isi',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Text(
                '${line.qtyDemand.toStringAsFixed(line.qtyDemand % 1 == 0 ? 0 : 2)} ${line.uom}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
      ),
    );
  }
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _LotEntrySheet extends StatefulWidget {
  final PickingLine line;
  final MoveLotData? initialData;

  /// Passed explicitly because the sheet runs in a separate modal route
  /// (no BLoC ancestor in that widget tree).
  final ValidasiPickingBloc bloc;

  const _LotEntrySheet({
    required this.line,
    required this.bloc,
    this.initialData,
  });

  @override
  State<_LotEntrySheet> createState() => _LotEntrySheetState();
}

class _LotEntrySheetState extends State<_LotEntrySheet> {
  // ── mode ──────────────────────────────────────────────────────────────────
  String _mode = 'existing'; // 'existing' | 'generate'

  // ── existing / manual ─────────────────────────────────────────────────────
  late List<_LotRow> _rows;
  final TextEditingController _searchCtrl = TextEditingController();
  List<LotChoice> _searchResults = [];
  final Map<int, double> _selectedQty = {};
  bool _searching = false;

  // ── generate ──────────────────────────────────────────────────────────────
  final TextEditingController _firstCtrl = TextEditingController();
  final TextEditingController _countCtrl = TextEditingController(text: '1');
  final TextEditingController _qtyPerLotCtrl = TextEditingController(text: '1');
  final TextEditingController _totalQtyCtrl = TextEditingController();
  bool _generating = false;
  bool _fetchingSequence = false;
  String? _generateError;

  @override
  void initState() {
    super.initState();
    final existing = widget.initialData?.lots ?? [];
    _rows = existing.isEmpty
        ? [_LotRow()]
        : existing
            .map((e) => _LotRow(lotName: e.lotName, qty: e.qty))
            .toList();
    final demand = widget.line.qtyDemand;
    _totalQtyCtrl.text = demand % 1 == 0
        ? demand.toInt().toString()
        : demand.toString();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _firstCtrl.dispose();
    _countCtrl.dispose();
    _qtyPerLotCtrl.dispose();
    _totalQtyCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  bool get _isSerial => widget.line.tracking == 'serial';

  bool get _manualCanSave =>
      _rows.every((r) => r.lotCtrl.text.trim().isNotEmpty);

  void _addRow() => setState(() => _rows.add(_LotRow()));

  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  void _saveManual() {
    if (!_manualCanSave) return;
    final lots = _rows
        .where((r) => r.lotCtrl.text.trim().isNotEmpty)
        .map((r) => LotEntry(
              lotName: r.lotCtrl.text.trim(),
              qty: _isSerial
                  ? 1.0
                  : (double.tryParse(r.qtyCtrl.text) ?? 1.0),
            ))
        .toList();
    Navigator.of(context).pop(MoveLotData(
      moveId: widget.line.moveId,
      tracking: widget.line.tracking,
      lots: lots,
      qty: lots.fold(0.0, (s, l) => s + l.qty),
    ));
  }

  void _saveSelected() {
    final lots = <LotEntry>[];
    for (final entry in _selectedQty.entries) {
      final found = _searchResults.firstWhere(
        (l) => l.id == entry.key,
        orElse: () => const LotChoice(id: 0, name: '', qty: 0),
      );
      if (found.id != 0 && entry.value > 0) {
        lots.add(LotEntry(lotName: found.name, qty: entry.value));
      }
    }
    if (lots.isEmpty) return;
    Navigator.of(context).pop(MoveLotData(
      moveId: widget.line.moveId,
      tracking: widget.line.tracking,
      lots: lots,
      qty: lots.fold(0.0, (s, l) => s + l.qty),
    ));
  }

  Future<void> _doSearch(String q) async {
    setState(() => _searching = true);
    try {
      final results =
          await widget.bloc.searchLots(widget.line.productId, q);
      if (mounted) setState(() => _searchResults = results);
    } catch (_) {
      // keep empty list
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _fetchNextSequence() async {
    setState(() => _fetchingSequence = true);
    try {
      final next = await widget.bloc.nextLotSequence();
      if (mounted && next.isNotEmpty) {
        setState(() {
          _firstCtrl.text = next;
          _fetchingSequence = false;
        });
      } else if (mounted) {
        setState(() => _fetchingSequence = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fetchingSequence = false;
          _generateError = 'Gagal ambil sequence: ${e.toString().replaceFirst('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _doGenerate() async {
    final first = _firstCtrl.text.trim();
    if (first.isEmpty) {
      setState(() => _generateError = 'Masukkan nomor awal lot/serial terlebih dahulu');
      return;
    }

    final int count;
    final double qtyPerLot;
    final double totalQty;

    if (_isSerial) {
      count = int.tryParse(_countCtrl.text) ?? 1;
      qtyPerLot = 1.0;
      totalQty = 0.0;
    } else {
      count = 0;
      qtyPerLot = double.tryParse(_qtyPerLotCtrl.text) ?? 1.0;
      totalQty = double.tryParse(_totalQtyCtrl.text) ?? qtyPerLot;
    }

    setState(() => _generating = true);
    try {
      final created = await widget.bloc.generateLots(
        productId: widget.line.productId,
        first: first,
        tracking: widget.line.tracking,
        count: count,
        qtyPerLot: qtyPerLot,
        totalQty: totalQty,
      );
      if (!mounted) return;
      final lots = created
          .map((c) => LotEntry(lotName: c.name, qty: c.qty))
          .toList();
      Navigator.of(context).pop(MoveLotData(
        moveId: widget.line.moveId,
        tracking: widget.line.tracking,
        lots: lots,
        qty: lots.fold(0.0, (s, l) => s + l.qty),
      ));
    } catch (e) {
      if (mounted) {
        setState(() {
          _generating = false;
          _generateError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _isSerial ? 'Serial Number' : 'Nomor Lot';

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textHint),
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.line.productName,
                            style: AppTextStyles.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.line.defaultCode != null)
                            Text(
                              '[${widget.line.defaultCode}]',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isSerial ? 'Serial' : 'Lot',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'existing', label: Text('Existing')),
                    ButtonSegment(value: 'generate', label: Text('Generate')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) {
                    setState(() => _mode = s.first);
                    if (s.first == 'generate' && _firstCtrl.text.isEmpty) {
                      _fetchNextSequence();
                    }
                  },
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: _mode == 'existing'
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Cari lot / serial',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onSubmitted: _doSearch,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _searching
                                      ? null
                                      : () => _doSearch(_searchCtrl.text.trim()),
                                  child: _searching
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Cari'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _searchResults.isNotEmpty
                                ? ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    itemCount: _searchResults.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (_, idx) {
                                      final lot = _searchResults[idx];
                                      final isSelected = _selectedQty.containsKey(lot.id);
                                      final qtyCtrl = TextEditingController(
                                        text: (_selectedQty[lot.id] ?? lot.qty).toString(),
                                      );

                                      return ListTile(
                                        dense: true,
                                        leading: Checkbox(
                                          value: isSelected,
                                          onChanged: (v) => setState(() {
                                            if (v == true) {
                                              _selectedQty[lot.id] = lot.qty > 0
                                                  ? lot.qty
                                                  : 1.0;
                                            } else {
                                              _selectedQty.remove(lot.id);
                                            }
                                          }),
                                        ),
                                        title: Text(lot.name),
                                        subtitle: Text(
                                          'Available: ${lot.qty.toStringAsFixed(lot.qty % 1 == 0 ? 0 : 2)}',
                                        ),
                                        trailing: SizedBox(
                                          width: 80,
                                          child: TextField(
                                            controller: qtyCtrl,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                            ),
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 6,
                                              ),
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                            onChanged: (v) {
                                              final val = double.tryParse(v) ?? 0.0;
                                              setState(() => _selectedQty[lot.id] = val);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Column(
                                      children: [
                                        for (int i = 0; i < _rows.length; i++)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: _isSerial ? 1 : 2,
                                                  child: TextField(
                                                    controller: _rows[i].lotCtrl,
                                                    style: const TextStyle(
                                                      color: AppColors.textPrimary,
                                                    ),
                                                    decoration: InputDecoration(
                                                      labelText: label,
                                                      border: const OutlineInputBorder(),
                                                      isDense: true,
                                                    ),
                                                  ),
                                                ),
                                                if (!_isSerial) ...[
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: _rows[i].qtyCtrl,
                                                      style: const TextStyle(
                                                        color: AppColors.textPrimary,
                                                      ),
                                                      decoration: const InputDecoration(
                                                        labelText: 'Qty',
                                                        border: OutlineInputBorder(),
                                                        isDense: true,
                                                      ),
                                                      keyboardType: const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline,
                                                      color: AppColors.error),
                                                  onPressed: () => _removeRow(i),
                                                ),
                                              ],
                                            ),
                                          ),
                                        TextButton.icon(
                                          onPressed: _addRow,
                                          icon: const Icon(Icons.add),
                                          label: Text('Tambah $label'),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Row(
                              children: [
                                if (_searchResults.isNotEmpty) ...[
                                  Expanded(
                                    child: AppButton(
                                      label: 'Pilih Lot (${_selectedQty.length})',
                                      onPressed: _selectedQty.isEmpty ? null : _saveSelected,
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: AppButton(
                                      label: 'Simpan',
                                      onPressed: _manualCanSave ? _saveManual : null,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _firstCtrl,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: _isSerial ? 'First Serial Number' : 'First Lot Number',
                                hintText: _isSerial ? 'e.g. SN0001' : 'e.g. LOT-001',
                                border: const OutlineInputBorder(),
                                isDense: true,
                                suffixIcon: _fetchingSequence
                                    ? const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      )
                                    : null,
                              ),
                              onChanged: (_) => setState(() => _generateError = null),
                            ),
                            if (_generateError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _generateError!,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                              ),
                            ],
                            const SizedBox(height: 10),
                            if (_isSerial)
                              TextField(
                                controller: _countCtrl,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  labelText: 'Jumlah Serial (Count)',
                                  hintText: 'e.g. 10',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                              )
                            else ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _qtyPerLotCtrl,
                                      style: const TextStyle(color: AppColors.textPrimary),
                                      decoration: const InputDecoration(
                                        labelText: 'Qty per Lot',
                                        hintText: 'e.g. 10',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _totalQtyCtrl,
                                      style: const TextStyle(color: AppColors.textPrimary),
                                      decoration: const InputDecoration(
                                        labelText: 'Total Qty Diterima',
                                        hintText: 'e.g. 100',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            AppButton(
                              label: _generating ? 'Generating...' : 'Generate',
                              onPressed: _generating ? null : _doGenerate,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper: one manual lot/serial row ───────────────────────────────────────

class _LotRow {
  final TextEditingController lotCtrl;
  final TextEditingController qtyCtrl;

  _LotRow({String lotName = '', double qty = 1.0})
      : lotCtrl = TextEditingController(text: lotName),
        qtyCtrl = TextEditingController(
          text: lotName.isNotEmpty
              ? (qty % 1 == 0 ? qty.toInt().toString() : qty.toString())
              : '',
        );

  void dispose() {
    lotCtrl.dispose();
    qtyCtrl.dispose();
  }
}

// ─── Location result helper ───────────────────────────────────────────────────

class _LocationResult {
  final String code;
  final String name;
  final bool clear;
  const _LocationResult({required this.code, required this.name, this.clear = false});
  static const _LocationResult cleared = _LocationResult(code: '', name: '', clear: true);
}

// ─── Location scan bottom sheet ───────────────────────────────────────────────

class _LocationScanSheet extends StatefulWidget {
  final ValidasiPickingBloc bloc;
  final int moveId;
  final String? currentLocationName;

  const _LocationScanSheet({
    required this.bloc,
    required this.moveId,
    this.currentLocationName,
  });

  @override
  State<_LocationScanSheet> createState() => _LocationScanSheetState();
}

class _LocationScanSheetState extends State<_LocationScanSheet> {
  bool _scanning = false;
  String? _error;

  Future<void> _onScanned(String code) async {
    setState(() {
      _scanning = true;
      _error = null;
    });
    try {
      final info = await widget.bloc.getLocationInfo(code);
      if (mounted) {
        Navigator.of(context).pop(
          _LocationResult(code: info.location, name: info.location),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scanning = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text('Set Lokasi Tujuan', style: AppTextStyles.titleMedium),
                ],
              ),
            ),
            if (widget.currentLocationName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Saat ini: ${widget.currentLocationName}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_LocationResult.cleared),
                      child: Text(
                        'Hapus',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  _error!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ),
            Expanded(
              child: _scanning
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: QrScannerWidget(
                        expectedType: 'any',
                        instruction: 'Scan QR lokasi tujuan produk ini',
                        onScanSuccess: _onScanned,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Scan Lokasi Tujuan (Opsional) ───────────────────────────────────

class _ScanLocationView extends StatelessWidget {
  final ValidasiPickingState state;
  const _ScanLocationView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ScannedInfoCard(
            title: '✅ Picking',
            titleColor: AppColors.success,
            fields: {'Nomor': state.pickingName ?? '-'},
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: QrScannerWidget(
              expectedType: 'any',
              instruction: '🗄️ Step 3: Scan lokasi tujuan penyimpanan',
              onScanSuccess: (code) {
                context
                    .read<ValidasiPickingBloc>()
                    .add(ValidasiPickingLocationScanned(code));
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                'Scan QR lokasi rak tujuan — atau lewati untuk hanya validasi picking',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Lewati (hanya validasi picking)',
                onPressed: () => context
                    .read<ValidasiPickingBloc>()
                    .add(ValidasiPickingSkipLocation()),
                isOutlined: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Step 4: Konfirmasi ──────────────────────────────────────────────────────

class _ConfirmView extends StatelessWidget {
  final ValidasiPickingState state;
  final bool isAdmin;
  const _ConfirmView({required this.state, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryCard(state: state),
          const SizedBox(height: 24),
          AppButton(
            label: state.hasTargetLocation
                ? 'Validasi Picking & Buat Transfer'
                : 'Validasi Picking',
            icon: Icons.check_circle_outline,
            onPressed: () => context
                .read<ValidasiPickingBloc>()
                .add(ValidasiPickingConfirmed()),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Batal',
            onPressed: () => context
                .read<ValidasiPickingBloc>()
                .add(ValidasiPickingReset()),
            isOutlined: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ValidasiPickingState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final lines = state.pickingInfo?.lines ?? [];
    final hasPerProductLoc = state.allMovesHaveLocation;
    final hasGlobalLoc = state.locationCode != null;
    final uniqueInternal = state.uniqueDestLocationCount;
    final totalTx = 1 +
        (hasPerProductLoc
            ? uniqueInternal
            : hasGlobalLoc
                ? 1
                : 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Proses', style: AppTextStyles.titleMedium),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.receipt_long_outlined,
            label: 'Picking',
            value: state.pickingName ?? '-',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          if (hasPerProductLoc) ...[
            for (final line in lines) ...[
              _InfoRow(
                icon: Icons.inventory_2_outlined,
                label: line.productName,
                value: state.moveLotMap[line.moveId]?.destLocationName ?? '-',
                color: AppColors.info,
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            _TransactionInfoBox(
              totalTx: totalTx,
              perProductLocs: state.moveLotMap.values
                  .map((m) => m.destLocationName)
                  .whereType<String>()
                  .toList(),
              uniqueInternal: uniqueInternal,
            ),
          ] else if (hasGlobalLoc) ...[
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Lokasi Tujuan',
              value: state.targetLocationName ?? state.locationCode ?? '-',
              color: AppColors.info,
            ),
            const SizedBox(height: 16),
            _TransactionInfoBox(
              totalTx: totalTx,
              perProductLocs: [],
              uniqueInternal: 1,
            ),
          ] else ...[
            // No location selected — show default info from picking
            if (state.pickingInfo?.pickingTypeName != null &&
                state.pickingInfo!.pickingTypeName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _InfoRow(
                  icon: Icons.swap_horiz_outlined,
                  label: 'Tipe Operasi',
                  value: state.pickingInfo!.pickingTypeName!,
                  color: AppColors.warning,
                ),
              ),
            if (state.pickingInfo?.locationDestName.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Lokasi Tujuan Default',
                  value: state.pickingInfo!.locationDestName,
                  color: AppColors.textSecondary,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hanya validasi picking\n(tanpa pemindahan ke lokasi tertentu)',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionInfoBox extends StatelessWidget {
  final int totalTx;
  final List<String> perProductLocs;
  final int uniqueInternal;

  const _TransactionInfoBox({
    required this.totalTx,
    required this.perProductLocs,
    required this.uniqueInternal,
  });

  @override
  Widget build(BuildContext context) {
    final uniqueLocs = perProductLocs.toSet().toList();
    final lines = <String>['Akan dibuat $totalTx transaksi:'];
    lines.add('1. Validasi picking');
    if (uniqueInternal == 1) {
      lines.add('2. Internal transfer ke lokasi tujuan');
    } else {
      for (int i = 0; i < uniqueLocs.length; i++) {
        lines.add('${i + 2}. Internal transfer → ${uniqueLocs[i]}');
      }
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.info, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lines.join('\n'),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info row widget ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Step 5: Hasil ───────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final ValidasiPickingState state;
  const _ResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    final result = state.result;
    final isPartial = result?.status == 'partial';
    final headerColor = isPartial ? AppColors.warning : AppColors.success;
    final headerIcon = isPartial
        ? Icons.warning_amber_rounded
        : Icons.check_circle_rounded;
    final headerTitle = isPartial ? 'Sebagian Berhasil' : 'Berhasil!';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: headerColor.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Icon(headerIcon, color: headerColor, size: 52),
                const SizedBox(height: 8),
                Text(headerTitle,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: headerColor)),
                const SizedBox(height: 8),
                Text(
                  result?.message ?? '-',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (result != null) ...[
            _ResultDetailCard(result: result),
            const SizedBox(height: 20),
          ],
          if (result?.lines.isNotEmpty == true) ...[
            Text('Produk Diproses', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            _ProductList(lines: result!.lines),
            const SizedBox(height: 20),
          ],
          AppButton(
            label: 'Proses Berikutnya',
            icon: Icons.refresh,
            onPressed: () => context
                .read<ValidasiPickingBloc>()
                .add(ValidasiPickingReset()),
          ),
        ],
      ),
    );
  }
}

class _ResultDetailCard extends StatelessWidget {
  final ReceiptTransferResult result;
  const _ResultDetailCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detail Transaksi', style: AppTextStyles.titleMedium),
          const Divider(height: 20),
          _ResultRow(
            label: 'Picking',
            value: result.receiptName,
            icon: Icons.receipt_long_outlined,
            status: result.receiptDone,
          ),
          if (result.internalTransfers.isNotEmpty) ...[
            for (int i = 0; i < result.internalTransfers.length; i++) ...[
              const SizedBox(height: 8),
              _ResultRow(
                label: result.internalTransfers.length == 1
                    ? 'Internal Transfer'
                    : 'Transfer ${i + 1}'
                        '${result.internalTransfers[i].destLocation != null ? ' → ${result.internalTransfers[i].destLocation}' : ''}',
                value: result.internalTransfers[i].name ??
                    (result.internalTransfers[i].error ?? 'Gagal dibuat'),
                icon: Icons.swap_horiz_rounded,
                status: result.internalTransfers[i].done,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool status;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status
                ? AppColors.success.withOpacity(0.15)
                : AppColors.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status ? 'Done' : 'Gagal',
            style: TextStyle(
              color: status ? AppColors.success : AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductList extends StatelessWidget {
  final List<ReceiptTransferLine> lines;
  const _ProductList({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: lines.length,
        separatorBuilder: (_, __) => Divider(
            height: 1,
            color: AppColors.textSecondary.withOpacity(0.1)),
        itemBuilder: (_, i) {
          final line = lines[i];
          return ListTile(
            dense: true,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: AppColors.primary, size: 18),
            ),
            title: Text(line.productName, style: AppTextStyles.bodyMedium),
            subtitle: line.defaultCode != null
                ? Text('[${line.defaultCode}]',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary))
                : null,
            trailing: Text(
              '${line.qtyDone.toStringAsFixed(line.qtyDone % 1 == 0 ? 0 : 2)} ${line.uom}',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }
}
