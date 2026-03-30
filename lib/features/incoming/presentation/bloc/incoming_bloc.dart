import 'package:flutter_bloc/flutter_bloc.dart';
import 'incoming_event.dart';
import 'incoming_state.dart';

class IncomingBloc extends Bloc<IncomingEvent, IncomingState> {
  IncomingBloc() : super(const IncomingState()) {
    on<IncomingReset>(_onReset);
    on<IncomingBoxScanned>(_onBoxScanned);
    on<IncomingPalletScanned>(_onPalletScanned);
    on<IncomingRackScanned>(_onRackScanned);
    on<IncomingConfirmed>(_onConfirmed);
  }

  void _onReset(IncomingReset event, Emitter<IncomingState> emit) {
    emit(const IncomingState());
  }

  void _onBoxScanned(IncomingBoxScanned event, Emitter<IncomingState> emit) {
    if (state.step != IncomingStep.scanBox) return;
    emit(state.copyWith(
      step: IncomingStep.scanPallet,
      boxCode: event.boxCode,
    ));
  }

  void _onPalletScanned(
      IncomingPalletScanned event, Emitter<IncomingState> emit) {
    if (state.step != IncomingStep.scanPallet) return;
    emit(state.copyWith(
      step: IncomingStep.scanRack,
      palletCode: event.palletCode,
    ));
  }

  void _onRackScanned(IncomingRackScanned event, Emitter<IncomingState> emit) {
    if (state.step != IncomingStep.scanRack) return;
    emit(state.copyWith(
      step: IncomingStep.confirming,
      rackCode: event.rackCode,
    ));
  }

  Future<void> _onConfirmed(
      IncomingConfirmed event, Emitter<IncomingState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      // TODO: call repository to submit putaway
      await Future.delayed(const Duration(milliseconds: 800)); // simulate API
      emit(state.copyWith(
        isLoading: false,
        step: IncomingStep.done,
        successMessage: 'Putaway berhasil disimpan!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan: ${e.toString()}',
      ));
    }
  }
}
