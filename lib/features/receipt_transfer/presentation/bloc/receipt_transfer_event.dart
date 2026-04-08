import 'package:equatable/equatable.dart';
import '../../../../features/scanner/data/scan_service.dart';

abstract class ReceiptTransferEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReceiptTransferReset extends ReceiptTransferEvent {}

/// Scan nomor picking (contoh: WH/IN/00001 atau barcode picking)
class ReceiptTransferPickingScanned extends ReceiptTransferEvent {
  final String pickingName;
  ReceiptTransferPickingScanned(this.pickingName);
  @override
  List<Object?> get props => [pickingName];
}

/// User mengisi/mengubah data lot untuk satu move
class ReceiptTransferLotUpdated extends ReceiptTransferEvent {
  final MoveLotData data;
  ReceiptTransferLotUpdated(this.data);
  @override
  List<Object?> get props => [data.moveId];
}

/// User selesai mengisi semua lot, lanjut ke scan lokasi
class ReceiptTransferProductsConfirmed extends ReceiptTransferEvent {}

/// Scan barcode lokasi tujuan (opsional – bisa dilewati)
class ReceiptTransferLocationScanned extends ReceiptTransferEvent {
  final String locationCode;
  ReceiptTransferLocationScanned(this.locationCode);
  @override
  List<Object?> get props => [locationCode];
}

/// Lewati scan lokasi tujuan (hanya validasi receipt saja)
class ReceiptTransferSkipLocation extends ReceiptTransferEvent {}

/// Konfirmasi eksekusi: validasi receipt (+ internal transfer bila ada target)
class ReceiptTransferConfirmed extends ReceiptTransferEvent {}
