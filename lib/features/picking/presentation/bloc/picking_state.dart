import 'package:equatable/equatable.dart';

enum PickingStep { scanProduct, scanPallet, confirming, done }

class PickingState extends Equatable {
  final PickingStep step;
  final String? productCode;
  final String? palletCode;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const PickingState({
    this.step = PickingStep.scanProduct,
    this.productCode,
    this.palletCode,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  PickingState copyWith({
    PickingStep? step,
    String? productCode,
    String? palletCode,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return PickingState(
      step: step ?? this.step,
      productCode: productCode ?? this.productCode,
      palletCode: palletCode ?? this.palletCode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  int get currentStepIndex {
    switch (step) {
      case PickingStep.scanProduct: return 1;
      case PickingStep.scanPallet: return 2;
      case PickingStep.confirming:
      case PickingStep.done: return 3;
    }
  }

  @override
  List<Object?> get props => [step, productCode, palletCode, isLoading, errorMessage, successMessage];
}
