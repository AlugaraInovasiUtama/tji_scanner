import 'package:equatable/equatable.dart';
import '../../../scanner/data/scan_service.dart';
import 'create_transfer_state.dart';

abstract class CreateTransferEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateTransferReset extends CreateTransferEvent {}

class CreateTransferGoBack extends CreateTransferEvent {}

// Step 1: partner
class CreateTransferPartnerSelected extends CreateTransferEvent {
  final PartnerInfo partner;
  CreateTransferPartnerSelected(this.partner);
  @override
  List<Object?> get props => [partner.id];
}

class CreateTransferPartnerSkipped extends CreateTransferEvent {}

// Step 2: operation type
class CreateTransferTypeSelected extends CreateTransferEvent {
  final PickingTypeInfo pickingType;
  CreateTransferTypeSelected(this.pickingType);
  @override
  List<Object?> get props => [pickingType.id];
}

// Step 3: source location scanned
class CreateTransferSrcLocationScanned extends CreateTransferEvent {
  final String locationCode;
  CreateTransferSrcLocationScanned(this.locationCode);
  @override
  List<Object?> get props => [locationCode];
}

// Step 4: destination location scanned
class CreateTransferDstLocationScanned extends CreateTransferEvent {
  final String locationCode;
  CreateTransferDstLocationScanned(this.locationCode);
  @override
  List<Object?> get props => [locationCode];
}

// Step 5: product line management
class CreateTransferProductAdded extends CreateTransferEvent {
  final TransferProductLine line;
  CreateTransferProductAdded(this.line);
  @override
  List<Object?> get props => [line.product.id];
}

class CreateTransferProductUpdated extends CreateTransferEvent {
  final int index;
  final TransferProductLine line;
  CreateTransferProductUpdated(this.index, this.line);
  @override
  List<Object?> get props => [index];
}

class CreateTransferProductRemoved extends CreateTransferEvent {
  final int index;
  CreateTransferProductRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class CreateTransferProductsConfirmed extends CreateTransferEvent {}

// Final confirm
class CreateTransferConfirmed extends CreateTransferEvent {}
