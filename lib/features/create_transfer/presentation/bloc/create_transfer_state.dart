import 'package:equatable/equatable.dart';
import '../../../scanner/data/scan_service.dart';

enum CreateTransferStep {
  selectPartner,   // Step 1: pilih contact (optional)
  selectType,      // Step 2: pilih operation type
  scanSrcLocation, // Step 3: scan source location
  scanDstLocation, // Step 4: scan destination location
  addProducts,     // Step 5: tambah produk & lot
  confirming,      // Step 6: konfirmasi
  done,            // Selesai
}

class TransferProductLine {
  final ProductSearchResult product;
  final double qty;
  final List<LotEntry> lots;

  const TransferProductLine({
    required this.product,
    required this.qty,
    this.lots = const [],
  });

  bool get isComplete {
    if (product.tracking == 'none') return qty > 0;
    return lots.isNotEmpty;
  }

  TransferProductLine copyWith({
    double? qty,
    List<LotEntry>? lots,
  }) =>
      TransferProductLine(
        product: product,
        qty: qty ?? this.qty,
        lots: lots ?? this.lots,
      );

  TransferMoveLine toMoveLine() => TransferMoveLine(
        productId: product.id,
        qty: qty,
        tracking: product.tracking,
        lots: lots,
      );
}

class CreateTransferState extends Equatable {
  final CreateTransferStep step;

  // Step 1: partner (optional)
  final PartnerInfo? partner;
  final bool skippedPartner;

  // Step 2: operation type
  final PickingTypeInfo? pickingType;

  // Step 3: source location
  final String? srcLocationCode;
  final String? srcLocationName;

  // Step 4: destination location
  final String? dstLocationCode;
  final String? dstLocationName;

  // Step 5: products
  final List<TransferProductLine> lines;

  // Loading & error
  final bool isLoading;
  final String? errorMessage;

  // Result
  final CreateTransferResult? result;

  // Draft picking created for Put-in-Pack flow
  final int? createdPickingId;
  final String? createdPickingName;

  const CreateTransferState({
    this.step = CreateTransferStep.selectPartner,
    this.partner,
    this.skippedPartner = false,
    this.pickingType,
    this.srcLocationCode,
    this.srcLocationName,
    this.dstLocationCode,
    this.dstLocationName,
    this.lines = const [],
    this.isLoading = false,
    this.errorMessage,
    this.result,
    this.createdPickingId,
    this.createdPickingName,
  });

  int get currentStepIndex {
    switch (step) {
      case CreateTransferStep.selectPartner:
        return 1;
      case CreateTransferStep.selectType:
        return 2;
      case CreateTransferStep.scanSrcLocation:
        return 3;
      case CreateTransferStep.scanDstLocation:
        return 4;
      case CreateTransferStep.addProducts:
        return 5;
      case CreateTransferStep.confirming:
      case CreateTransferStep.done:
        return 6;
    }
  }

  bool get canConfirm =>
      pickingType != null &&
      srcLocationCode != null &&
      dstLocationCode != null &&
      lines.isNotEmpty &&
      lines.every((l) => l.isComplete);

  CreateTransferState copyWith({
    CreateTransferStep? step,
    PartnerInfo? partner,
    bool? skippedPartner,
    PickingTypeInfo? pickingType,
    String? srcLocationCode,
    String? srcLocationName,
    String? dstLocationCode,
    String? dstLocationName,
    List<TransferProductLine>? lines,
    bool? isLoading,
    String? errorMessage,
    CreateTransferResult? result,
    int? createdPickingId,
    String? createdPickingName,
    bool clearError = false,
    bool clearPartner = false,
  }) {
    return CreateTransferState(
      step: step ?? this.step,
      partner: clearPartner ? null : (partner ?? this.partner),
      skippedPartner: skippedPartner ?? this.skippedPartner,
      pickingType: pickingType ?? this.pickingType,
      srcLocationCode: srcLocationCode ?? this.srcLocationCode,
      srcLocationName: srcLocationName ?? this.srcLocationName,
      dstLocationCode: dstLocationCode ?? this.dstLocationCode,
      dstLocationName: dstLocationName ?? this.dstLocationName,
      lines: lines ?? this.lines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage,
      result: result ?? this.result,
      createdPickingId: createdPickingId ?? this.createdPickingId,
      createdPickingName: createdPickingName ?? this.createdPickingName,
    );
  }

  @override
  List<Object?> get props => [
        step,
        partner,
        skippedPartner,
        pickingType,
        srcLocationCode,
        srcLocationName,
        dstLocationCode,
        dstLocationName,
        lines,
        isLoading,
        errorMessage,
        result,
        createdPickingId,
        createdPickingName,
      ];
}
