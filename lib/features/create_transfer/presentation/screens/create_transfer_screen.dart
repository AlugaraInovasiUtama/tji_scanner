import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_transfer_bloc.dart';
import '../bloc/create_transfer_event.dart';
import '../bloc/create_transfer_state.dart';
import '../../../scanner/widgets/qr_scanner_widget.dart';
import '../../../scanner/widgets/step_indicator_widget.dart';
import '../../../scanner/data/scan_service.dart';
import '../../../../core/utils/scan_feedback.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class CreateTransferScreen extends StatelessWidget {
  final ScanService scanService;
  const CreateTransferScreen({super.key, required this.scanService});

  static const _stepLabels = [
    'Kontak',
    'Operasi',
    'Lokasi Asal',
    'Lokasi Tujuan',
    'Produk',
    'Konfirmasi',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateTransferBloc(scanService),
      child: const _CreateTransferView(),
    );
  }
}

// ─── Main view ────────────────────────────────────────────────────────────────

class _CreateTransferView extends StatelessWidget {
  const _CreateTransferView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateTransferBloc, CreateTransferState>(
      listener: (context, state) {
        if (state.step == CreateTransferStep.done) {
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
        if (state.step == CreateTransferStep.scanSrcLocation ||
            state.step == CreateTransferStep.scanDstLocation) {
          loadingMsg = 'Memverifikasi lokasi...';
        } else if (state.step == CreateTransferStep.confirming) {
          loadingMsg = 'Membuat & memvalidasi transfer...';
        }

        final canGoBack = state.step != CreateTransferStep.selectPartner &&
            state.step != CreateTransferStep.done;

        return WillPopScope(
          onWillPop: () async {
            if (canGoBack) {
              context.read<CreateTransferBloc>().add(CreateTransferGoBack());
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Buat Transfer'),
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              leading: canGoBack
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () =>
                          context.read<CreateTransferBloc>().add(CreateTransferGoBack()),
                    )
                  : null,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                  onPressed: () =>
                      context.read<CreateTransferBloc>().add(CreateTransferReset()),
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
                      totalSteps: 6,
                      stepLabels: CreateTransferScreen._stepLabels,
                      stepsPerRow: 3,
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

  Widget _buildBody(BuildContext context, CreateTransferState state) {
    switch (state.step) {
      case CreateTransferStep.selectPartner:
        return _SelectPartnerView();
      case CreateTransferStep.selectType:
        return _SelectTypeView();
      case CreateTransferStep.scanSrcLocation:
        return _ScanLocationView(
          state: state,
          isSource: true,
        );
      case CreateTransferStep.scanDstLocation:
        return _ScanLocationView(
          state: state,
          isSource: false,
        );
      case CreateTransferStep.addProducts:
        return _AddProductsView(state: state);
      case CreateTransferStep.confirming:
        return _ConfirmView(state: state);
      case CreateTransferStep.done:
        return _DoneView(state: state);
    }
  }
}

// ─── Step 1: Select Partner ───────────────────────────────────────────────────

class _SelectPartnerView extends StatefulWidget {
  @override
  State<_SelectPartnerView> createState() => _SelectPartnerViewState();
}

class _SelectPartnerViewState extends State<_SelectPartnerView> {
  final _searchCtrl = TextEditingController();
  List<PartnerInfo> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load(String query) async {
    setState(() => _loading = true);
    try {
      final bloc = context.read<CreateTransferBloc>();
      final list = await bloc.searchPartners(query);
      if (mounted) setState(() => _results = list);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Cari Kontak / Vendor',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: _load,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loading ? null : () => _load(_searchCtrl.text.trim()),
                child: const Text('Cari'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada kontak ditemukan',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final p = _results[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            child: Text(
                              p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(p.displayName, style: AppTextStyles.bodyMedium),
                          subtitle: p.companyName.isNotEmpty
                              ? Text(p.companyName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))
                              : null,
                          onTap: () => context.read<CreateTransferBloc>().add(
                                CreateTransferPartnerSelected(p),
                              ),
                        );
                      },
                    ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: AppButton(
            label: 'Lewati (tanpa kontak)',
            icon: Icons.skip_next_outlined,
            isOutlined: true,
            onPressed: () =>
                context.read<CreateTransferBloc>().add(CreateTransferPartnerSkipped()),
          ),
        ),
      ],
    );
  }
}

// ─── Step 2: Select Operation Type ───────────────────────────────────────────

class _SelectTypeView extends StatefulWidget {
  @override
  State<_SelectTypeView> createState() => _SelectTypeViewState();
}

class _SelectTypeViewState extends State<_SelectTypeView> {
  final _searchCtrl = TextEditingController();
  List<PickingTypeInfo> _types = [];
  List<PickingTypeInfo> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final bloc = context.read<CreateTransferBloc>();
      final list = await bloc.getPickingTypes();
      if (mounted) {
        setState(() {
          _types = list;
          _filtered = list;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _types = []; _filtered = []; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _types
          : _types.where((pt) =>
              pt.name.toLowerCase().contains(q) ||
              pt.warehouseName.toLowerCase().contains(q) ||
              pt.code.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateTransferBloc, CreateTransferState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.partner != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _InfoChip(
                  icon: Icons.person_outline,
                  label: state.partner!.displayName,
                  color: AppColors.info,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Cari Tipe Operasi',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tidak ada operation type ditemukan',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                              if (_types.isNotEmpty)
                                const SizedBox(height: 4),
                              if (_types.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _applyFilter();
                                  },
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Hapus pencarian'),
                                ),
                              if (_types.isEmpty) ...[
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _load,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Muat ulang'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final pt = _filtered[i];
                            final codeColor = pt.code == 'incoming'
                                ? AppColors.success
                                : pt.code == 'outgoing'
                                    ? AppColors.warning
                                    : AppColors.info;
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: codeColor.withOpacity(0.3)),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  pt.code == 'incoming'
                                      ? Icons.move_to_inbox
                                      : pt.code == 'outgoing'
                                          ? Icons.outbox
                                          : Icons.swap_horiz,
                                  color: codeColor,
                                ),
                                title: Text(pt.name, style: AppTextStyles.bodyMedium),
                                subtitle: pt.warehouseName.isNotEmpty
                                    ? Text(pt.warehouseName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))
                                    : null,
                                trailing: Chip(
                                  label: Text(pt.code, style: const TextStyle(fontSize: 10)),
                                  backgroundColor: codeColor.withOpacity(0.1),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                onTap: () => context.read<CreateTransferBloc>().add(
                                      CreateTransferTypeSelected(pt),
                                    ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Step 3 & 4: Scan Location ────────────────────────────────────────────────

class _ScanLocationView extends StatelessWidget {
  final CreateTransferState state;
  final bool isSource;

  const _ScanLocationView({required this.state, required this.isSource});

  @override
  Widget build(BuildContext context) {
    final label = isSource ? 'Lokasi Asal' : 'Lokasi Tujuan';
    final stepNum = isSource ? '3' : '4';
    final default_ = isSource
        ? state.pickingType?.defaultLocationSrcName
        : state.pickingType?.defaultLocationDestName;

    return Column(
      children: [
        if (state.pickingType != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _InfoChip(
              icon: Icons.swap_horiz,
              label: state.pickingType!.displayName,
              color: AppColors.primary,
            ),
          ),
        if (!isSource && state.srcLocationName != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: _InfoChip(
              icon: Icons.location_on_outlined,
              label: 'Dari: ${state.srcLocationName}',
              color: AppColors.success,
            ),
          ),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: QrScannerWidget(
              expectedType: 'any',
              instruction: '📍 Step $stepNum: Scan QR $label',
              onScanSuccess: (code) {
                if (isSource) {
                  context.read<CreateTransferBloc>().add(CreateTransferSrcLocationScanned(code));
                } else {
                  context.read<CreateTransferBloc>().add(CreateTransferDstLocationScanned(code));
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (default_ != null && default_.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  'Default $label: $default_',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Gunakan Default: $default_',
                  isOutlined: true,
                  icon: Icons.check_outlined,
                  onPressed: () {
                    if (isSource) {
                      context.read<CreateTransferBloc>().add(CreateTransferSrcLocationScanned(default_));
                    } else {
                      context.read<CreateTransferBloc>().add(CreateTransferDstLocationScanned(default_));
                    }
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Step 5: Add Products ─────────────────────────────────────────────────────

class _AddProductsView extends StatelessWidget {
  final CreateTransferState state;
  const _AddProductsView({required this.state});

  @override
  Widget build(BuildContext context) {
    final incomplete = state.lines.any((l) => !l.isComplete);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Produk Transfer', style: AppTextStyles.bodyMedium),
                    if (state.srcLocationName != null)
                      Text(
                        '${state.srcLocationName} → ${state.dstLocationName}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddProductSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.lines.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada produk.\nTap "Tambah" untuk menambah produk.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: state.lines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final line = state.lines[i];
                    final isDone = line.isComplete;
                    final statusColor = isDone ? AppColors.success : AppColors.warning;
                    final trackingLabel = line.product.tracking == 'none'
                        ? null
                        : line.product.tracking == 'serial'
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
                          child: Icon(
                            isDone ? Icons.check_circle : Icons.edit_note,
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                        title: Text(line.product.name, style: AppTextStyles.bodyMedium),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (line.product.defaultCode.isNotEmpty)
                              Text('[${line.product.defaultCode}]',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            Text(
                              'Qty: ${line.qty.toStringAsFixed(line.qty % 1 == 0 ? 0 : 2)} ${line.product.uom}',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            if (trackingLabel != null && line.lots.isNotEmpty)
                              Text(
                                '${line.lots.length} $trackingLabel — ${line.lots.map((e) => e.lotName).join(', ')}',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            else if (trackingLabel != null)
                              Text('Belum ada $trackingLabel',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (line.product.tracking != 'none')
                              TextButton(
                                onPressed: () => _showLotSheet(context, i, line),
                                child: Text(
                                  line.lots.isNotEmpty ? 'Edit' : 'Isi',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              onPressed: () => context
                                  .read<CreateTransferBloc>()
                                  .add(CreateTransferProductRemoved(i)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: AppButton(
            label: 'Lanjut ke Konfirmasi',
            icon: Icons.arrow_forward,
            onPressed: (state.lines.isEmpty || incomplete)
                ? null
                : () => context.read<CreateTransferBloc>().add(CreateTransferProductsConfirmed()),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddProductSheet(BuildContext context) async {
    final bloc = context.read<CreateTransferBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => _AddProductSheet(bloc: bloc),
    );
  }

  Future<void> _showLotSheet(BuildContext context, int index, TransferProductLine line) async {
    final bloc = context.read<CreateTransferBloc>();
    final result = await showModalBottomSheet<TransferProductLine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: _TransferLotSheet(line: line, bloc: bloc),
      ),
    );
    if (result != null && context.mounted) {
      context.read<CreateTransferBloc>().add(CreateTransferProductUpdated(index, result));
    }
  }
}

// ─── Bottom sheet: Add Product ────────────────────────────────────────────────

class _AddProductSheet extends StatefulWidget {
  final CreateTransferBloc bloc;
  const _AddProductSheet({required this.bloc});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _searchCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  List<ProductSearchResult> _results = [];
  ProductSearchResult? _selected;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final list = await widget.bloc.searchProducts(query);
      if (mounted) setState(() => _results = list);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _add() {
    final product = _selected;
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0.0;
    if (product == null || qty <= 0) return;

    final line = TransferProductLine(product: product, qty: qty);
    widget.bloc.add(CreateTransferProductAdded(line));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // Handle
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('Tambah Produk', style: AppTextStyles.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Cari Produk',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: _search,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : () => _search(_searchCtrl.text.trim()),
                    child: const Text('Cari'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final p = _results[i];
                        final isSelected = _selected?.id == p.id;
                        return ListTile(
                          dense: true,
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          leading: Radio<int>(
                            value: p.id,
                            groupValue: _selected?.id,
                            onChanged: (_) => setState(() => _selected = p),
                          ),
                          title: Text(p.name),
                          subtitle: Text(
                            '${p.defaultCode.isNotEmpty ? "[${p.defaultCode}] " : ""}${p.tracking != "none" ? p.tracking : p.uom}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          onTap: () => setState(() => _selected = p),
                        );
                      },
                    ),
            ),
            if (_selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Qty (${_selected!.uom})',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _qtyCtrl,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selected != null ? _add : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: AppColors.textDisabled,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambahkan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheet: Lot entry for transfer line ────────────────────────────────

class _TransferLotSheet extends StatefulWidget {
  final TransferProductLine line;
  final CreateTransferBloc bloc;

  const _TransferLotSheet({required this.line, required this.bloc});

  @override
  State<_TransferLotSheet> createState() => _TransferLotSheetState();
}

class _TransferLotSheetState extends State<_TransferLotSheet> {
  String _mode = 'manual'; // 'manual' | 'search' | 'generate'
  late List<_LotRow> _rows;
  final _searchCtrl = TextEditingController();
  List<LotChoice> _searchResults = [];
  final Map<int, double> _selectedQty = {};
  bool _searching = false;

  final _firstCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '1');
  final _qtyPerLotCtrl = TextEditingController(text: '1');
  final _totalQtyCtrl = TextEditingController();
  bool _generating = false;
  String? _generateError;

  @override
  void initState() {
    super.initState();
    final existing = widget.line.lots;
    _rows = existing.isEmpty
        ? [_LotRow()]
        : existing.map((e) => _LotRow(lotName: e.lotName, qty: e.qty)).toList();
    final demand = widget.line.qty;
    _totalQtyCtrl.text = demand % 1 == 0 ? demand.toInt().toString() : demand.toString();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _firstCtrl.dispose();
    _countCtrl.dispose();
    _qtyPerLotCtrl.dispose();
    _totalQtyCtrl.dispose();
    for (final r in _rows) r.dispose();
    super.dispose();
  }

  bool get _isSerial => widget.line.product.tracking == 'serial';

  bool get _manualCanSave => _rows.every((r) => r.lotCtrl.text.trim().isNotEmpty);

  void _addRow() => setState(() => _rows.add(_LotRow()));
  void _removeRow(int i) => setState(() => _rows.removeAt(i));

  Future<void> _doSearch(String query) async {
    setState(() => _searching = true);
    try {
      final res = await widget.bloc.searchLots(widget.line.product.id, query);
      if (mounted) setState(() => _searchResults = res);
    } catch (_) {
      if (mounted) setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _saveManual() {
    final lots = _rows
        .where((r) => r.lotCtrl.text.trim().isNotEmpty)
        .map((r) => LotEntry(
              lotName: r.lotCtrl.text.trim(),
              qty: _isSerial ? 1.0 : (double.tryParse(r.qtyCtrl.text) ?? 1.0),
            ))
        .toList();
    final updated = widget.line.copyWith(lots: lots);
    Navigator.of(context).pop(updated);
  }

  void _saveSelected() {
    final lots = _selectedQty.entries.map((e) {
      final lot = _searchResults.firstWhere((l) => l.id == e.key);
      return LotEntry(lotName: lot.name, qty: e.value);
    }).toList();
    final updated = widget.line.copyWith(lots: lots);
    Navigator.of(context).pop(updated);
  }

  Future<void> _doGenerate() async {
    final first = _firstCtrl.text.trim();
    if (first.isEmpty) {
      setState(() => _generateError = 'Isi first lot/serial');
      return;
    }
    setState(() { _generating = true; _generateError = null; });
    try {
      final count = int.tryParse(_countCtrl.text) ?? 1;
      final qtyPerLot = double.tryParse(_qtyPerLotCtrl.text) ?? 1.0;
      final totalQty = double.tryParse(_totalQtyCtrl.text) ?? 0.0;
      final created = await widget.bloc.generateLots(
        productId: widget.line.product.id,
        first: first,
        tracking: widget.line.product.tracking,
        count: count,
        qtyPerLot: qtyPerLot,
        totalQty: totalQty,
      );
      final lots = created.map((c) => LotEntry(lotName: c.name, qty: c.qty)).toList();
      final updated = widget.line.copyWith(lots: lots);
      if (mounted) Navigator.of(context).pop(updated);
    } catch (e) {
      if (mounted) setState(() => _generateError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _isSerial ? 'Serial' : 'Lot';
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Isi $label', style: AppTextStyles.titleMedium),
                        Text(
                          widget.line.product.name,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Mode tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'manual', label: Text('Manual')),
                  ButtonSegment(value: 'search', label: Text('Cari')),
                  ButtonSegment(value: 'generate', label: Text('Generate')),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() {
                  _mode = s.first;
                  _searchResults.clear();
                }),
              ),
            ),
            Expanded(
              child: _mode == 'search'
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  style: const TextStyle(color: AppColors.textPrimary),
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
                                onPressed: _searching ? null : () => _doSearch(_searchCtrl.text.trim()),
                                child: _searching
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text('Cari'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, idx) {
                              final lot = _searchResults[idx];
                              return ListTile(
                                dense: true,
                                leading: Checkbox(
                                  value: _selectedQty.containsKey(lot.id),
                                  onChanged: (v) => setState(() {
                                    if (v == true) {
                                      _selectedQty[lot.id] = lot.qty > 0 ? lot.qty : 1.0;
                                    } else {
                                      _selectedQty.remove(lot.id);
                                    }
                                  }),
                                ),
                                title: Text(lot.name),
                                subtitle: Text('Available: ${lot.qty.toStringAsFixed(lot.qty % 1 == 0 ? 0 : 2)}'),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _selectedQty.isNotEmpty ? _saveSelected : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                ),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Simpan'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _mode == 'generate'
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _firstCtrl,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  labelText: _isSerial ? 'First Serial Number' : 'First Lot Number',
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() => _generateError = null),
                              ),
                              if (_generateError != null) ...[
                                const SizedBox(height: 6),
                                Text(_generateError!,
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
                              ],
                              const SizedBox(height: 10),
                              if (_isSerial)
                                TextField(
                                  controller: _countCtrl,
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    labelText: 'Jumlah Serial',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _qtyPerLotCtrl,
                                        style: const TextStyle(color: AppColors.textPrimary),
                                        decoration: const InputDecoration(
                                          labelText: 'Qty per Lot',
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
                                          labelText: 'Total Qty',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: (_generating) ? null : _doGenerate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                ),
                                icon: const Icon(Icons.auto_awesome, size: 18),
                                label: Text(_generating ? 'Generating...' : 'Generate & Simpan'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
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
                                                style: const TextStyle(color: AppColors.textPrimary),
                                                decoration: InputDecoration(
                                                  labelText: label,
                                                  hintText: _isSerial ? 'SN001' : 'LOT-001',
                                                  border: const OutlineInputBorder(),
                                                  isDense: true,
                                                ),
                                                onChanged: (_) => setState(() {}),
                                              ),
                                            ),
                                            if (!_isSerial) ...[
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextField(
                                                  controller: _rows[i].qtyCtrl,
                                                  style: const TextStyle(color: AppColors.textPrimary),
                                                  decoration: const InputDecoration(
                                                    labelText: 'Qty',
                                                    border: OutlineInputBorder(),
                                                    isDense: true,
                                                  ),
                                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                ),
                                              ),
                                            ],
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: _rows.length > 1 ? () => _removeRow(i) : null,
                                              child: Icon(
                                                Icons.remove_circle_outline,
                                                color: _rows.length > 1
                                                    ? AppColors.error
                                                    : Colors.grey.shade300,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!_isSerial)
                                    TextButton.icon(
                                      onPressed: _addRow,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Tambah Lot'),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  ElevatedButton.icon(
                                    onPressed: _manualCanSave ? _saveManual : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.black,
                                      disabledBackgroundColor: AppColors.textDisabled,
                                    ),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Simpan'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper: _LotRow ─────────────────────────────────────────────────────────

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

// ─── Step 6: Konfirmasi ───────────────────────────────────────────────────────

class _ConfirmView extends StatefulWidget {
  final CreateTransferState state;
  const _ConfirmView({required this.state});

  @override
  State<_ConfirmView> createState() => _ConfirmViewState();
}

class _ConfirmViewState extends State<_ConfirmView> {
  bool _packing = false;

  Future<void> _putInPack(BuildContext context) async {
    setState(() => _packing = true);
    try {
      final bloc = context.read<CreateTransferBloc>();
      int? pickingId = widget.state.createdPickingId;

      if (pickingId == null) {
        // Create draft picking first, then pack
        final draft = await bloc.createDraftTransfer();
        if (draft.pickingId == null) {
          throw Exception('Gagal membuat draft picking');
        }
        if (context.mounted) {
          bloc.add(CreateTransferDraftSaved(draft.pickingId!, draft.pickingName));
        }
        pickingId = draft.pickingId!;
      }

      final result = await bloc.putInPack(pickingId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${result.message} — Paket: ${result.packageName}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _packing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryCard(state: widget.state),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: _packing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.inventory_2_outlined),
            label: Text(_packing ? 'Membuat paket...' : 'Put in Pack'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.info,
              side: const BorderSide(color: AppColors.info),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _packing ? null : () => _putInPack(context),
          ),
          if (widget.state.createdPickingName != null) ...[
            const SizedBox(height: 6),
            Text(
              'Draft: ${widget.state.createdPickingName}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          AppButton(
            label: 'Buat & Validasi Transfer',
            icon: Icons.check_circle_outline,
            onPressed: () =>
                context.read<CreateTransferBloc>().add(CreateTransferConfirmed()),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Kembali',
            icon: Icons.arrow_back,
            isOutlined: true,
            onPressed: () =>
                context.read<CreateTransferBloc>().add(CreateTransferGoBack()),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final CreateTransferState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
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
          Text('Ringkasan Transfer', style: AppTextStyles.titleMedium),
          const Divider(height: 24),
          if (state.partner != null) ...[
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Kontak',
              value: state.partner!.displayName,
              color: AppColors.info,
            ),
            const SizedBox(height: 10),
          ],
          _InfoRow(
            icon: Icons.swap_horiz,
            label: 'Tipe Operasi',
            value: state.pickingType?.displayName ?? '-',
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.upload_outlined,
            label: 'Dari',
            value: state.srcLocationName ?? '-',
            color: AppColors.warning,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.download_outlined,
            label: 'Ke',
            value: state.dstLocationName ?? '-',
            color: AppColors.success,
          ),
          const SizedBox(height: 16),
          Text('Produk (${state.lines.length})', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          ...state.lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l.product.name} — ${l.qty.toStringAsFixed(l.qty % 1 == 0 ? 0 : 2)} ${l.product.uom}'
                      '${l.lots.isNotEmpty ? " (${l.lots.length} ${l.product.tracking})" : ""}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Done ─────────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  final CreateTransferState state;
  const _DoneView({required this.state});

  void _showTransferSummary(BuildContext context, CreateTransferState s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (_, scrollCtrl) {
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text('Ringkasan Transfer', style: AppTextStyles.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                _SummaryRow(icon: Icons.tag, label: 'No. Transfer', value: s.result?.pickingName ?? '-'),
                if (s.partner != null)
                  _SummaryRow(icon: Icons.person_outline, label: 'Kontak', value: s.partner!.displayName),
                if (s.pickingType != null)
                  _SummaryRow(icon: Icons.swap_horiz, label: 'Tipe Operasi', value: s.pickingType!.displayName),
                if (s.srcLocationName != null)
                  _SummaryRow(icon: Icons.location_on_outlined, label: 'Lokasi Asal', value: s.srcLocationName!),
                if (s.dstLocationName != null)
                  _SummaryRow(icon: Icons.location_searching, label: 'Lokasi Tujuan', value: s.dstLocationName!),
                const Divider(height: 24),
                Text('Produk (${s.lines.length})', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                ...s.lines.map((line) {
                  final hasLots = line.lots.isNotEmpty;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(line.product.displayName, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text('Qty: ${line.qty} ${line.product.uom}', style: const TextStyle(fontSize: 11)),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        if (hasLots) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: line.lots.map((l) => Chip(
                              label: Text(l.lotName, style: const TextStyle(fontSize: 10)),
                              backgroundColor: AppColors.info.withOpacity(0.1),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = state.result;
    final isSuccess = result?.isSuccess ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 80,
            color: isSuccess ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(height: 16),
          Text(
            isSuccess ? 'Transfer Berhasil!' : 'Transfer Dibuat',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            result?.message ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          if (result?.pickingName.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, color: AppColors.success),
                  const SizedBox(width: 12),
                  Text(
                    result!.pickingName,
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (isSuccess) ...[
            AppButton(
              label: 'Lihat Ringkasan Transfer',
              icon: Icons.receipt_long_outlined,
              isOutlined: true,
              onPressed: () => _showTransferSummary(context, state),
            ),
            const SizedBox(height: 12),
          ],
          AppButton(
            label: 'Buat Transfer Baru',
            icon: Icons.add_circle_outline,
            onPressed: () =>
                context.read<CreateTransferBloc>().add(CreateTransferReset()),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Kembali ke Dashboard',
            icon: Icons.home_outlined,
            isOutlined: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ─── Helper: summary row ──────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          Expanded(
            child: Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Helper: info chip ────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
