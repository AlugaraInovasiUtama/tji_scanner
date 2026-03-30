import 'package:flutter_bloc/flutter_bloc.dart';
import 'stock_opname_event.dart';
import 'stock_opname_state.dart';

class StockOpnameBloc extends Bloc<StockOpnameEvent, StockOpnameState> {
  StockOpnameBloc() : super(const StockOpnameState()) {
    on<StockOpnameReset>(_onReset);
    on<StockOpnameRackScanned>(_onRackScanned);
    on<StockOpnamePalletScanned>(_onPalletScanned);
    on<StockOpnameBoxScanned>(_onBoxScanned);
    on<StockOpnameActualQtyChanged>(_onQtyChanged);
    on<StockOpnameConfirmed>(_onConfirmed);
  }

  void _onReset(StockOpnameReset event, Emitter<StockOpnameState> emit) {
    emit(const StockOpnameState());
  }

  void _onRackScanned(StockOpnameRackScanned event, Emitter<StockOpnameState> emit) {
    emit(state.copyWith(rackCode: event.rackCode, step: StockOpnameStep.scanning));
  }

  void _onPalletScanned(StockOpnamePalletScanned event, Emitter<StockOpnameState> emit) {
    emit(state.copyWith(palletCode: event.palletCode));
  }

  void _onBoxScanned(StockOpnameBoxScanned event, Emitter<StockOpnameState> emit) {
    // Avoid duplicate box
    if (state.scannedBoxes.any((b) => b.boxCode == event.boxCode)) return;

    final updated = List<ScannedBoxItem>.from(state.scannedBoxes)
      ..add(ScannedBoxItem(
        boxCode: event.boxCode,
        systemQty: 0, // TODO: fetch from API/cache
        actualQty: 0,
      ));
    emit(state.copyWith(scannedBoxes: updated));
  }

  void _onQtyChanged(StockOpnameActualQtyChanged event, Emitter<StockOpnameState> emit) {
    final updated = state.scannedBoxes.map((b) {
      if (b.boxCode == event.boxCode) return b.copyWith(actualQty: event.qty);
      return b;
    }).toList();
    emit(state.copyWith(scannedBoxes: updated));
  }

  Future<void> _onConfirmed(StockOpnameConfirmed event, Emitter<StockOpnameState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      emit(state.copyWith(isLoading: false, step: StockOpnameStep.done));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
