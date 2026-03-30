import 'package:equatable/equatable.dart';

enum StockOpnameStep { scanRack, scanning, confirming, done }

class ScannedBoxItem extends Equatable {
  final String boxCode;
  final double systemQty;
  final double actualQty;

  const ScannedBoxItem({
    required this.boxCode,
    required this.systemQty,
    required this.actualQty,
  });

  ScannedBoxItem copyWith({double? actualQty}) {
    return ScannedBoxItem(
      boxCode: boxCode,
      systemQty: systemQty,
      actualQty: actualQty ?? this.actualQty,
    );
  }

  @override
  List<Object?> get props => [boxCode, systemQty, actualQty];
}

class StockOpnameState extends Equatable {
  final StockOpnameStep step;
  final String? rackCode;
  final String? palletCode;
  final List<ScannedBoxItem> scannedBoxes;
  final bool isLoading;
  final String? errorMessage;

  const StockOpnameState({
    this.step = StockOpnameStep.scanRack,
    this.rackCode,
    this.palletCode,
    this.scannedBoxes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  StockOpnameState copyWith({
    StockOpnameStep? step,
    String? rackCode,
    String? palletCode,
    List<ScannedBoxItem>? scannedBoxes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StockOpnameState(
      step: step ?? this.step,
      rackCode: rackCode ?? this.rackCode,
      palletCode: palletCode ?? this.palletCode,
      scannedBoxes: scannedBoxes ?? this.scannedBoxes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [step, rackCode, palletCode, scannedBoxes, isLoading, errorMessage];
}
