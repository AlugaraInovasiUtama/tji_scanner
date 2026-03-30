import 'package:flutter_bloc/flutter_bloc.dart';
import 'picking_event.dart';
import 'picking_state.dart';

class PickingBloc extends Bloc<PickingEvent, PickingState> {
  PickingBloc() : super(const PickingState()) {
    on<PickingReset>(_onReset);
    on<PickingProductScanned>(_onProductScanned);
    on<PickingPalletScanned>(_onPalletScanned);
    on<PickingConfirmed>(_onConfirmed);
  }

  void _onReset(PickingReset event, Emitter<PickingState> emit) {
    emit(const PickingState());
  }

  void _onProductScanned(PickingProductScanned event, Emitter<PickingState> emit) {
    if (state.step != PickingStep.scanProduct) return;
    emit(state.copyWith(step: PickingStep.scanPallet, productCode: event.productCode));
  }

  void _onPalletScanned(PickingPalletScanned event, Emitter<PickingState> emit) {
    if (state.step != PickingStep.scanPallet) return;
    emit(state.copyWith(step: PickingStep.confirming, palletCode: event.palletCode));
  }

  Future<void> _onConfirmed(PickingConfirmed event, Emitter<PickingState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      emit(state.copyWith(isLoading: false, step: PickingStep.done, successMessage: 'Picking berhasil!'));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
