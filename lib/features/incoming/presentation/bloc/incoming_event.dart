import 'package:equatable/equatable.dart';

abstract class IncomingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class IncomingReset extends IncomingEvent {}

class IncomingBoxScanned extends IncomingEvent {
  final String boxCode;
  IncomingBoxScanned(this.boxCode);
  @override
  List<Object?> get props => [boxCode];
}

class IncomingPalletScanned extends IncomingEvent {
  final String palletCode;
  IncomingPalletScanned(this.palletCode);
  @override
  List<Object?> get props => [palletCode];
}

class IncomingRackScanned extends IncomingEvent {
  final String rackCode;
  IncomingRackScanned(this.rackCode);
  @override
  List<Object?> get props => [rackCode];
}

class IncomingConfirmed extends IncomingEvent {}
