import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../scanner/data/scan_service.dart';
import '../../../../core/errors/exceptions.dart';
import 'receipt_transfer_event.dart';
import 'receipt_transfer_state.dart';

class ReceiptTransferBloc extends Bloc<ReceiptTransferEvent, ReceiptTransferState> {
  final ScanService _scanService;

  ReceiptTransferBloc(this._scanService) : super(const ReceiptTransferState()) {
    on<ReceiptTransferReset>(_onReset);
    on<ReceiptTransferPickingScanned>(_onPickingScanned);
    on<ReceiptTransferLotUpdated>(_onLotUpdated);
    on<ReceiptTransferProductsConfirmed>(_onProductsConfirmed);
    on<ReceiptTransferLocationScanned>(_onLocationScanned);
    on<ReceiptTransferSkipLocation>(_onSkipLocation);
    on<ReceiptTransferConfirmed>(_onConfirmed);
  }

  // Expose helper methods to call ScanService from UI (search/generate lots)
  Future<List<LotChoice>> searchLots(int productId, String query) => _scanService.searchLots(productId: productId, query: query);

  Future<String> nextLotSequence() => _scanService.nextLotSequence();

  Future<List<CreatedLot>> generateLots({
    required int productId,
    required String first,
    required String tracking,
    int count = 1,
    double qtyPerLot = 1.0,
    double totalQty = 0.0,
  }) =>
      _scanService.generateLots(
        productId: productId,
        first: first,
        tracking: tracking,
        count: count,
        qtyPerLot: qtyPerLot,
        totalQty: totalQty,
      );

  void _onReset(ReceiptTransferReset event, Emitter<ReceiptTransferState> emit) {
    emit(const ReceiptTransferState());
  }

  /// Fetch picking info, lalu pindah ke step showProducts
  Future<void> _onPickingScanned(
    ReceiptTransferPickingScanned event,
    Emitter<ReceiptTransferState> emit,
  ) async {
    if (state.step != ReceiptTransferStep.scanPicking) return;

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final pickingInfo = await _scanService.getPickingInfo(event.pickingName);

      if (pickingInfo.pickingType != 'incoming') {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Bukan receipt (tipe: ${pickingInfo.pickingType})',
        ));
        return;
      }

      if (pickingInfo.state == 'done') {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Picking ${pickingInfo.name} sudah divalidasi',
        ));
        return;
      }

      if (pickingInfo.state == 'cancel') {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Picking ${pickingInfo.name} sudah dibatalkan',
        ));
        return;
      }

      // Build initial moveLotMap: non-tracked=qty demanded, tracked=empty lots
      final moveLotMap = <int, MoveLotData>{};
      for (final line in pickingInfo.lines) {
        moveLotMap[line.moveId] = MoveLotData(
          moveId: line.moveId,
          tracking: line.tracking,
          qty: line.qtyDemand,
          lots: const [],
        );
      }

      emit(state.copyWith(
        isLoading: false,
        step: ReceiptTransferStep.showProducts,
        pickingName: pickingInfo.name,
        pickingId: pickingInfo.id,
        pickingInfo: pickingInfo,
        moveLotMap: moveLotMap,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// User mengupdate data lot untuk satu move (dari dialog)
  void _onLotUpdated(
    ReceiptTransferLotUpdated event,
    Emitter<ReceiptTransferState> emit,
  ) {
    final updated = Map<int, MoveLotData>.from(state.moveLotMap);
    updated[event.data.moveId] = event.data;
    emit(state.copyWith(moveLotMap: updated));
  }

  /// User selesai mengisi lot — pindah ke scanLocation
  void _onProductsConfirmed(
    ReceiptTransferProductsConfirmed event,
    Emitter<ReceiptTransferState> emit,
  ) {
    if (state.step != ReceiptTransferStep.showProducts) return;
    emit(state.copyWith(step: ReceiptTransferStep.scanLocation));
  }

  /// Fetch location info untuk validasi lokasi tujuan ada di server
  Future<void> _onLocationScanned(
    ReceiptTransferLocationScanned event,
    Emitter<ReceiptTransferState> emit,
  ) async {
    if (state.step != ReceiptTransferStep.scanLocation) return;

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final locationInfo = await _scanService.getLocationInfo(event.locationCode);
      emit(state.copyWith(
        isLoading: false,
        step: ReceiptTransferStep.confirming,
        locationCode: event.locationCode,
        targetLocationName: locationInfo.location,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onSkipLocation(
    ReceiptTransferSkipLocation event,
    Emitter<ReceiptTransferState> emit,
  ) {
    if (state.step != ReceiptTransferStep.scanLocation) return;
    emit(state.copyWith(
      step: ReceiptTransferStep.confirming,
      clearLocation: true,
    ));
  }

  Future<void> _onConfirmed(
    ReceiptTransferConfirmed event,
    Emitter<ReceiptTransferState> emit,
  ) async {
    if (state.pickingId == null) return;

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final moveLines = state.moveLotMap.values.toList();
      final result = await _scanService.validateReceiptWithTransfer(
        pickingId: state.pickingId!,
        moveLines: moveLines,
        targetLocationCode: state.locationCode,
      );

      emit(state.copyWith(
        isLoading: false,
        step: ReceiptTransferStep.done,
        result: result,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
