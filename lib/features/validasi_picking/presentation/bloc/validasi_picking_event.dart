import 'package:equatable/equatable.dart';
import '../../../../features/scanner/data/scan_service.dart';

abstract class ValidasiPickingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ValidasiPickingReset extends ValidasiPickingEvent {}

/// Navigate back to the previous step
class ValidasiPickingGoBack extends ValidasiPickingEvent {}

/// Scan nomor picking (contoh: WH/IN/00001 atau barcode picking)
class ValidasiPickingPickingScanned extends ValidasiPickingEvent {
  final String pickingName;
  ValidasiPickingPickingScanned(this.pickingName);
  @override
  List<Object?> get props => [pickingName];
}

/// User mengisi/mengubah data lot untuk satu move
class ValidasiPickingLotUpdated extends ValidasiPickingEvent {
  final MoveLotData data;
  ValidasiPickingLotUpdated(this.data);
  @override
  List<Object?> get props => [data.moveId];
}

/// User selesai mengisi semua lot, lanjut ke scan lokasi
/// [skipLocation] = true untuk role helper (langsung ke confirming)
class ValidasiPickingProductsConfirmed extends ValidasiPickingEvent {
  final bool skipLocation;
  ValidasiPickingProductsConfirmed({this.skipLocation = false});
  @override
  List<Object?> get props => [skipLocation];
}

/// Scan barcode lokasi tujuan (opsional – bisa dilewati)
class ValidasiPickingLocationScanned extends ValidasiPickingEvent {
  final String locationCode;
  ValidasiPickingLocationScanned(this.locationCode);
  @override
  List<Object?> get props => [locationCode];
}

/// Lewati scan lokasi tujuan (hanya validasi picking saja)
class ValidasiPickingSkipLocation extends ValidasiPickingEvent {}

/// Konfirmasi eksekusi: validasi picking (+ internal transfer bila ada target)
class ValidasiPickingConfirmed extends ValidasiPickingEvent {}

/// Set lokasi tujuan per-produk (move)
class ValidasiPickingMoveLocationSet extends ValidasiPickingEvent {
  final int moveId;
  final String destLocationCode;
  final String destLocationName;
  ValidasiPickingMoveLocationSet(this.moveId, this.destLocationCode, this.destLocationName);
  @override
  List<Object?> get props => [moveId, destLocationCode];
}

/// Hapus lokasi tujuan per-produk (move)
class ValidasiPickingMoveLocationCleared extends ValidasiPickingEvent {
  final int moveId;
  ValidasiPickingMoveLocationCleared(this.moveId);
  @override
  List<Object?> get props => [moveId];
}
