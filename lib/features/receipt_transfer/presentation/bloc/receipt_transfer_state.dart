import 'package:equatable/equatable.dart';
import '../../../scanner/data/scan_service.dart';

enum ReceiptTransferStep {
  scanPicking,
  showProducts,  // step baru: isi lot/serial per produk
  scanLocation,
  confirming,
  done,
}

class ReceiptTransferState extends Equatable {
  final ReceiptTransferStep step;

  /// Nama picking hasil scan (contoh: WH/IN/00001)
  final String? pickingName;

  /// ID picking dari server (setelah fetch info)
  final int? pickingId;

  /// Info lengkap picking (lines dengan tracking info)
  final PickingInfo? pickingInfo;

  /// Data lot per move: key = moveId
  final Map<int, MoveLotData> moveLotMap;

  /// Nama/barcode lokasi tujuan hasil scan
  final String? locationCode;

  /// Nama lengkap lokasi tujuan (dari server)
  final String? targetLocationName;

  final bool isLoading;
  final String? errorMessage;

  /// Hasil setelah konfirmasi berhasil
  final ReceiptTransferResult? result;

  const ReceiptTransferState({
    this.step = ReceiptTransferStep.scanPicking,
    this.pickingName,
    this.pickingId,
    this.pickingInfo,
    this.moveLotMap = const {},
    this.locationCode,
    this.targetLocationName,
    this.isLoading = false,
    this.errorMessage,
    this.result,
  });

  ReceiptTransferState copyWith({
    ReceiptTransferStep? step,
    String? pickingName,
    int? pickingId,
    PickingInfo? pickingInfo,
    Map<int, MoveLotData>? moveLotMap,
    String? locationCode,
    String? targetLocationName,
    bool? isLoading,
    String? errorMessage,
    ReceiptTransferResult? result,
    bool clearError = false,
    bool clearLocation = false,
  }) {
    return ReceiptTransferState(
      step: step ?? this.step,
      pickingName: pickingName ?? this.pickingName,
      pickingId: pickingId ?? this.pickingId,
      pickingInfo: pickingInfo ?? this.pickingInfo,
      moveLotMap: moveLotMap ?? this.moveLotMap,
      locationCode: clearLocation ? null : (locationCode ?? this.locationCode),
      targetLocationName: clearLocation ? null : (targetLocationName ?? this.targetLocationName),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage,
      result: result ?? this.result,
    );
  }

  /// Step numbernya: 1-based, for StepIndicator (totalSteps=4)
  int get currentStepIndex {
    switch (step) {
      case ReceiptTransferStep.scanPicking:
        return 1;
      case ReceiptTransferStep.showProducts:
        return 2;
      case ReceiptTransferStep.scanLocation:
        return 3;
      case ReceiptTransferStep.confirming:
      case ReceiptTransferStep.done:
        return 4;
    }
  }

  bool get hasTargetLocation =>
      locationCode != null ||
      moveLotMap.values.any((m) => m.destLocationCode != null);

  /// True kalau semua produk memiliki lokasi tujuan per-move
  bool get allMovesHaveLocation {
    final info = pickingInfo;
    if (info == null || info.lines.isEmpty) return false;
    for (final line in info.lines) {
      final lotData = moveLotMap[line.moveId];
      if (lotData?.destLocationCode == null) return false;
    }
    return true;
  }

  /// True kalau sebagian (bukan semua, bukan nol) produk punya lokasi tujuan
  bool get someButNotAllMovesHaveLocation {
    final info = pickingInfo;
    if (info == null || info.lines.isEmpty) return false;
    int withLoc = 0;
    for (final line in info.lines) {
      final lotData = moveLotMap[line.moveId];
      if (lotData?.destLocationCode != null) withLoc++;
    }
    return withLoc > 0 && withLoc < info.lines.length;
  }

  /// Jumlah internal transfer unik berdasarkan lokasi tujuan
  int get uniqueDestLocationCount {
    return moveLotMap.values
        .map((m) => m.destLocationCode)
        .whereType<String>()
        .toSet()
        .length;
  }

  /// True kalau semua line tracked sudah terisi lot
  bool get allLotsComplete {
    final info = pickingInfo;
    if (info == null) return true;
    for (final line in info.lines) {
      if (line.tracking != 'none') {
        final lotData = moveLotMap[line.moveId];
        if (lotData == null || !lotData.isComplete) return false;
      }
    }
    return true;
  }

  @override
  List<Object?> get props => [
        step,
        pickingName,
        pickingId,
        pickingInfo,
        moveLotMap,
        locationCode,
        targetLocationName,
        isLoading,
        errorMessage,
        result,
      ];
}
