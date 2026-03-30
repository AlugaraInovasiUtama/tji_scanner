import 'package:equatable/equatable.dart';

abstract class PickingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickingReset extends PickingEvent {}

class PickingProductScanned extends PickingEvent {
  final String productCode;
  PickingProductScanned(this.productCode);
  @override
  List<Object?> get props => [productCode];
}

class PickingPalletScanned extends PickingEvent {
  final String palletCode;
  PickingPalletScanned(this.palletCode);
  @override
  List<Object?> get props => [palletCode];
}

class PickingConfirmed extends PickingEvent {}
