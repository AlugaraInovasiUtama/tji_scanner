import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../scanner/data/scan_service.dart';
import '../../../../core/errors/exceptions.dart';
import 'validasi_picking_event.dart';
import 'validasi_picking_state.dart';

class ValidasiPickingBloc extends Bloc<ValidasiPickingEvent, ValidasiPickingState> {
  final ScanService _scanService;

  ValidasiPickingBloc(this._scanService) : super(const ValidasiPickingState()) {
    on<ValidasiPickingReset>(_onReset);
    on<ValidasiPickingGoBack>(_onGoBack);
    on<ValidasiPickingPickingScanned>(_onPickingScanned);
    on<ValidasiPickingLotUpdated>(_onLotUpdated);
    on<ValidasiPickingProductsConfirmed>(_onProductsConfirmed);
    on<ValidasiPickingLocationScanned>(_onLocationScanned);
    on<ValidasiPickingSkipLocation>(_onSkipLocation);
    on<ValidasiPickingConfirmed>(_onConfirmed);
    on<ValidasiPickingMoveLocationSet>(_onMoveLocationSet);
    on<ValidasiPickingMoveLocationCleared>(_onMoveLocationCleared);
  }

  // Expose helper methods to call ScanService from UI
  Future<PutInPackResult> putInPack(int pickingId) => _scanService.putInPack(pickingId: pickingId);

  Future<List<LotChoice>> searchLots(int productId, String query) => _scanService.searchLots(productId: productId, query: query);

  Future<String> nextLotSequence() => _scanService.nextLotSequence();

  Future<LocationInfo> getLocationInfo(String code) => _scanService.getLocationInfo(code);

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

  void _onReset(ValidasiPickingReset event, Emitter<ValidasiPickingState> emit) {
    emit(const ValidasiPickingState());
  }

  void _onGoBack(ValidasiPickingGoBack event, Emitter<ValidasiPickingState> emit) {
    switch (state.step) {
      case ValidasiPickingStep.showProducts:
        emit(state.copyWith(
          step: ValidasiPickingStep.scanPicking,
          pickingName: null,
          pickingId: null,
          pickingInfo: null,
          moveLotMap: const {},
          clearError: true,
        ));
        break;
      case ValidasiPickingStep.scanLocation:
        emit(state.copyWith(
          step: ValidasiPickingStep.showProducts,
          clearLocation: true,
          clearError: true,
        ));
        break;
      case ValidasiPickingStep.confirming:
        if (state.skippedLocation) {
          emit(state.copyWith(
            step: ValidasiPickingStep.showProducts,
            skippedLocation: false,
            clearLocation: true,
            clearError: true,
          ));
        } else {
          emit(state.copyWith(
            step: ValidasiPickingStep.scanLocation,
            clearLocation: true,
            clearError: true,
          ));
        }
        break;
      default:
        break;
    }
  }

  /// Fetch picking info, lalu pindah ke step showProducts
  Future<void> _onPickingScanned(
    ValidasiPickingPickingScanned event,
    Emitter<ValidasiPickingState> emit,
  ) async {
    if (state.step != ValidasiPickingStep.scanPicking) return;

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final pickingInfo = await _scanService.getPickingInfo(event.pickingName);

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
        step: ValidasiPickingStep.showProducts,
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
    ValidasiPickingLotUpdated event,
    Emitter<ValidasiPickingState> emit,
  ) {
    final updated = Map<int, MoveLotData>.from(state.moveLotMap);
    updated[event.data.moveId] = event.data;
    emit(state.copyWith(moveLotMap: updated));
  }

  /// User selesai mengisi lot — pindah ke scanLocation atau langsung confirming
  void _onProductsConfirmed(
    ValidasiPickingProductsConfirmed event,
    Emitter<ValidasiPickingState> emit,
  ) {
    if (state.step != ValidasiPickingStep.showProducts) return;
    // Helper role atau semua produk sudah punya lokasi tujuan → skip scan location
    if (event.skipLocation || state.allMovesHaveLocation) {
      emit(state.copyWith(
        step: ValidasiPickingStep.confirming,
        skippedLocation: event.skipLocation,
        clearLocation: true,
      ));
    } else {
      emit(state.copyWith(step: ValidasiPickingStep.scanLocation));
    }
  }

  /// Fetch location info untuk validasi lokasi tujuan ada di server
  Future<void> _onLocationScanned(
    ValidasiPickingLocationScanned event,
    Emitter<ValidasiPickingState> emit,
  ) async {
    if (state.step != ValidasiPickingStep.scanLocation) return;

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final locationInfo = await _scanService.getLocationInfo(event.locationCode);
      emit(state.copyWith(
        isLoading: false,
        step: ValidasiPickingStep.confirming,
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
    ValidasiPickingSkipLocation event,
    Emitter<ValidasiPickingState> emit,
  ) {
    if (state.step != ValidasiPickingStep.scanLocation) return;
    emit(state.copyWith(
      step: ValidasiPickingStep.confirming,
      skippedLocation: true,
      clearLocation: true,
    ));
  }

  Future<void> _onConfirmed(
    ValidasiPickingConfirmed event,
    Emitter<ValidasiPickingState> emit,
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
        step: ValidasiPickingStep.done,
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

  void _onMoveLocationSet(
    ValidasiPickingMoveLocationSet event,
    Emitter<ValidasiPickingState> emit,
  ) {
    final updated = Map<int, MoveLotData>.from(state.moveLotMap);
    final existing = updated[event.moveId];
    if (existing != null) {
      updated[event.moveId] = existing.copyWith(
        destLocationCode: event.destLocationCode,
        destLocationName: event.destLocationName,
      );
    }
    emit(state.copyWith(moveLotMap: updated));
  }

  void _onMoveLocationCleared(
    ValidasiPickingMoveLocationCleared event,
    Emitter<ValidasiPickingState> emit,
  ) {
    final updated = Map<int, MoveLotData>.from(state.moveLotMap);
    final existing = updated[event.moveId];
    if (existing != null) {
      updated[event.moveId] = existing.copyWith(clearDestLocation: true);
    }
    emit(state.copyWith(moveLotMap: updated));
  }
}
