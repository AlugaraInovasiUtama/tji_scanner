import 'package:equatable/equatable.dart';

enum IncomingStep { scanBox, scanPallet, scanRack, confirming, done }

class IncomingState extends Equatable {
  final IncomingStep step;
  final String? boxCode;
  final String? palletCode;
  final String? rackCode;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const IncomingState({
    this.step = IncomingStep.scanBox,
    this.boxCode,
    this.palletCode,
    this.rackCode,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  IncomingState copyWith({
    IncomingStep? step,
    String? boxCode,
    String? palletCode,
    String? rackCode,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return IncomingState(
      step: step ?? this.step,
      boxCode: boxCode ?? this.boxCode,
      palletCode: palletCode ?? this.palletCode,
      rackCode: rackCode ?? this.rackCode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  int get currentStepIndex {
    switch (step) {
      case IncomingStep.scanBox:
        return 1;
      case IncomingStep.scanPallet:
        return 2;
      case IncomingStep.scanRack:
        return 3;
      case IncomingStep.confirming:
      case IncomingStep.done:
        return 4;
    }
  }

  @override
  List<Object?> get props => [
    step, boxCode, palletCode, rackCode, isLoading, errorMessage, successMessage,
  ];
}
