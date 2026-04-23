import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../scanner/data/scan_service.dart';
import '../../../../core/errors/exceptions.dart';
import 'create_transfer_event.dart';
import 'create_transfer_state.dart';

class CreateTransferBloc extends Bloc<CreateTransferEvent, CreateTransferState> {
  final ScanService _scanService;

  CreateTransferBloc(this._scanService) : super(const CreateTransferState()) {
    on<CreateTransferReset>(_onReset);
    on<CreateTransferGoBack>(_onGoBack);
    on<CreateTransferPartnerSelected>(_onPartnerSelected);
    on<CreateTransferPartnerSkipped>(_onPartnerSkipped);
    on<CreateTransferTypeSelected>(_onTypeSelected);
    on<CreateTransferSrcLocationScanned>(_onSrcLocationScanned);
    on<CreateTransferDstLocationScanned>(_onDstLocationScanned);
    on<CreateTransferProductAdded>(_onProductAdded);
    on<CreateTransferProductUpdated>(_onProductUpdated);
    on<CreateTransferProductRemoved>(_onProductRemoved);
    on<CreateTransferProductsConfirmed>(_onProductsConfirmed);
    on<CreateTransferConfirmed>(_onConfirmed);
  }

  // Expose helper methods for UI
  Future<List<PartnerInfo>> searchPartners(String query) =>
      _scanService.searchPartners(query: query);

  Future<List<PickingTypeInfo>> getPickingTypes() =>
      _scanService.getPickingTypes();

  Future<List<ProductSearchResult>> searchProducts(String query) =>
      _scanService.searchProducts(query: query);

  Future<LocationInfo> getLocationInfo(String code) =>
      _scanService.getLocationInfo(code);

  Future<List<LotChoice>> searchLots(int productId, String query) =>
      _scanService.searchLots(productId: productId, query: query);

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

  void _onReset(CreateTransferReset event, Emitter<CreateTransferState> emit) {
    emit(const CreateTransferState());
  }

  void _onGoBack(CreateTransferGoBack event, Emitter<CreateTransferState> emit) {
    switch (state.step) {
      case CreateTransferStep.selectType:
        emit(state.copyWith(step: CreateTransferStep.selectPartner));
        break;
      case CreateTransferStep.scanSrcLocation:
        emit(state.copyWith(step: CreateTransferStep.selectType));
        break;
      case CreateTransferStep.scanDstLocation:
        emit(state.copyWith(step: CreateTransferStep.scanSrcLocation));
        break;
      case CreateTransferStep.addProducts:
        emit(state.copyWith(step: CreateTransferStep.scanDstLocation));
        break;
      case CreateTransferStep.confirming:
        emit(state.copyWith(step: CreateTransferStep.addProducts));
        break;
      default:
        break;
    }
  }

  void _onPartnerSelected(
    CreateTransferPartnerSelected event,
    Emitter<CreateTransferState> emit,
  ) {
    emit(state.copyWith(
      partner: event.partner,
      skippedPartner: false,
      step: CreateTransferStep.selectType,
      clearError: true,
    ));
  }

  void _onPartnerSkipped(
    CreateTransferPartnerSkipped event,
    Emitter<CreateTransferState> emit,
  ) {
    emit(state.copyWith(
      skippedPartner: true,
      step: CreateTransferStep.selectType,
      clearError: true,
      clearPartner: true,
    ));
  }

  void _onTypeSelected(
    CreateTransferTypeSelected event,
    Emitter<CreateTransferState> emit,
  ) {
    final pt = event.pickingType;
    emit(state.copyWith(
      pickingType: pt,
      step: CreateTransferStep.scanSrcLocation,
      // Pre-fill default locations if available
      srcLocationCode: pt.defaultLocationSrcName.isNotEmpty ? pt.defaultLocationSrcName : state.srcLocationCode,
      srcLocationName: pt.defaultLocationSrcName.isNotEmpty ? pt.defaultLocationSrcName : state.srcLocationName,
      dstLocationCode: pt.defaultLocationDestName.isNotEmpty ? pt.defaultLocationDestName : state.dstLocationCode,
      dstLocationName: pt.defaultLocationDestName.isNotEmpty ? pt.defaultLocationDestName : state.dstLocationName,
      clearError: true,
    ));
  }

  Future<void> _onSrcLocationScanned(
    CreateTransferSrcLocationScanned event,
    Emitter<CreateTransferState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final info = await _scanService.getLocationInfo(event.locationCode);
      emit(state.copyWith(
        isLoading: false,
        srcLocationCode: info.location,
        srcLocationName: info.location,
        step: CreateTransferStep.scanDstLocation,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDstLocationScanned(
    CreateTransferDstLocationScanned event,
    Emitter<CreateTransferState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final info = await _scanService.getLocationInfo(event.locationCode);
      emit(state.copyWith(
        isLoading: false,
        dstLocationCode: info.location,
        dstLocationName: info.location,
        step: CreateTransferStep.addProducts,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onProductAdded(
    CreateTransferProductAdded event,
    Emitter<CreateTransferState> emit,
  ) {
    final updated = List<TransferProductLine>.from(state.lines)..add(event.line);
    emit(state.copyWith(lines: updated));
  }

  void _onProductUpdated(
    CreateTransferProductUpdated event,
    Emitter<CreateTransferState> emit,
  ) {
    final updated = List<TransferProductLine>.from(state.lines);
    if (event.index >= 0 && event.index < updated.length) {
      updated[event.index] = event.line;
      emit(state.copyWith(lines: updated));
    }
  }

  void _onProductRemoved(
    CreateTransferProductRemoved event,
    Emitter<CreateTransferState> emit,
  ) {
    final updated = List<TransferProductLine>.from(state.lines);
    if (event.index >= 0 && event.index < updated.length) {
      updated.removeAt(event.index);
      emit(state.copyWith(lines: updated));
    }
  }

  void _onProductsConfirmed(
    CreateTransferProductsConfirmed event,
    Emitter<CreateTransferState> emit,
  ) {
    if (state.lines.isEmpty) {
      emit(state.copyWith(errorMessage: 'Tambahkan minimal 1 produk'));
      return;
    }
    if (!state.lines.every((l) => l.isComplete)) {
      emit(state.copyWith(errorMessage: 'Lengkapi lot/serial untuk semua produk'));
      return;
    }
    emit(state.copyWith(step: CreateTransferStep.confirming, clearError: true));
  }

  Future<void> _onConfirmed(
    CreateTransferConfirmed event,
    Emitter<CreateTransferState> emit,
  ) async {
    if (!state.canConfirm) return;

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final result = await _scanService.createTransfer(
        pickingTypeId: state.pickingType!.id,
        locationSrc: state.srcLocationCode!,
        locationDest: state.dstLocationCode!,
        partnerId: state.partner?.id,
        moveLines: state.lines.map((l) => l.toMoveLine()).toList(),
      );
      emit(state.copyWith(
        isLoading: false,
        step: CreateTransferStep.done,
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
