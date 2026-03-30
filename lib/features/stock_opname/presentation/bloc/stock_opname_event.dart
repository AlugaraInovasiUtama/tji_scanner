import 'package:equatable/equatable.dart';

abstract class StockOpnameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StockOpnameReset extends StockOpnameEvent {}

class StockOpnameRackScanned extends StockOpnameEvent {
  final String rackCode;
  StockOpnameRackScanned(this.rackCode);
  @override
  List<Object?> get props => [rackCode];
}

class StockOpnamePalletScanned extends StockOpnameEvent {
  final String palletCode;
  StockOpnamePalletScanned(this.palletCode);
  @override
  List<Object?> get props => [palletCode];
}

class StockOpnameBoxScanned extends StockOpnameEvent {
  final String boxCode;
  StockOpnameBoxScanned(this.boxCode);
  @override
  List<Object?> get props => [boxCode];
}

class StockOpnameActualQtyChanged extends StockOpnameEvent {
  final String boxCode;
  final double qty;
  StockOpnameActualQtyChanged(this.boxCode, this.qty);
  @override
  List<Object?> get props => [boxCode, qty];
}

class StockOpnameConfirmed extends StockOpnameEvent {}
