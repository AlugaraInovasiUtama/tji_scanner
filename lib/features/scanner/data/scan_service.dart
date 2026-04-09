import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';

class LotInfo {
  final int productId;
  final String productName;
  final double qty;
  final String uom;
  final String lot;
  final String? expiredDate;

  const LotInfo({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.uom,
    required this.lot,
    this.expiredDate,
  });

  factory LotInfo.fromJson(Map<String, dynamic> json) {
    return LotInfo(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      qty: (json['qty'] as num).toDouble(),
      uom: json['uom'] as String,
      lot: json['lot'] as String,
      expiredDate: json['expired_date'] as String?,
    );
  }
}

class LocationChild {
  final int id;
  final String name;
  final String completeName;
  final String? barcode;
  final String usage;

  const LocationChild({
    required this.id,
    required this.name,
    required this.completeName,
    this.barcode,
    required this.usage,
  });

  factory LocationChild.fromJson(Map<String, dynamic> json) {
    return LocationChild(
      id: json['id'] as int,
      name: json['name'] as String,
      completeName: json['complete_name'] as String,
      barcode: json['barcode'] as String?,
      usage: json['usage'] as String,
    );
  }
}

class LocationInfo {
  final String location;
  final int totalChilds;
  final List<LocationChild> lines;

  const LocationInfo({
    required this.location,
    required this.totalChilds,
    required this.lines,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? [];
    return LocationInfo(
      location: json['location'] as String,
      totalChilds: json['total_childs'] as int,
      lines: rawLines
          .map((e) => LocationChild.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class PalletProduct {
  final int productId;
  final String? defaultCode;
  final String productName;
  final double qty;
  final String uom;
  final String? lot;
  final String? expirationDate;
  final String? packaging;
  final double? capacityPackaging;
  final String? uomPackaging;

  const PalletProduct({
    required this.productId,
    this.defaultCode,
    required this.productName,
    required this.qty,
    required this.uom,
    this.lot,
    this.expirationDate,
    this.packaging,
    this.capacityPackaging,
    this.uomPackaging,
  });

  factory PalletProduct.fromJson(Map<String, dynamic> json) {
    return PalletProduct(
      productId: json['product_id'] as int,
      defaultCode: json['default_code'] as String?,
      productName: json['product_name'] as String,
      qty: (json['qty'] as num).toDouble(),
      uom: json['uom'] as String,
      lot: json['lot'] as String?,
      expirationDate: json['expiration_date'] as String?,
      packaging: json['packaging'] as String?,
      capacityPackaging: json['capacity_packaging'] == null
          ? null
          : (json['capacity_packaging'] as num).toDouble(),
      uomPackaging: json['uom_packaging'] as String?,
    );
  }
}

class PalletPackage {
  final int packageId;
  final String packageName;
  final String? packageType;
  final List<PalletProduct> products;

  const PalletPackage({
    required this.packageId,
    required this.packageName,
    this.packageType,
    required this.products,
  });

  factory PalletPackage.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? [];
    return PalletPackage(
      packageId: json['package_id'] as int,
      packageName: json['package_name'] as String,
      packageType: json['package_type'] as String?,
      products: rawProducts
          .map((e) => PalletProduct.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class PalletInfo {
  final int palletId;
  final String pallet;
  final int totalPackages;
  final List<PalletPackage> packages;

  const PalletInfo({
    required this.palletId,
    required this.pallet,
    required this.totalPackages,
    required this.packages,
  });

  factory PalletInfo.fromJson(Map<String, dynamic> json) {
    final rawPackages = json['packages'] as List<dynamic>? ?? [];
    return PalletInfo(
      palletId: json['pallet_id'] as int,
      pallet: json['pallet'] as String,
      totalPackages: json['total_packages'] as int,
      packages: rawPackages
          .map((e) => PalletPackage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class PickingLine {
  final int moveId;
  final int productId;
  final String? defaultCode;
  final String productName;
  final double qtyDemand;
  final double qtyDone;
  final String uom;
  /// 'none', 'lot', or 'serial'
  final String tracking;

  const PickingLine({
    required this.moveId,
    required this.productId,
    this.defaultCode,
    required this.productName,
    required this.qtyDemand,
    required this.qtyDone,
    required this.uom,
    this.tracking = 'none',
  });

  factory PickingLine.fromJson(Map<String, dynamic> json) {
    return PickingLine(
      moveId: json['move_id'] as int? ?? 0,
      productId: json['product_id'] as int,
      defaultCode: json['default_code'] as String?,
      productName: json['product_name'] as String,
      qtyDemand: (json['qty_demand'] as num).toDouble(),
      qtyDone: (json['qty_done'] as num).toDouble(),
      uom: json['uom'] as String,
      tracking: json['tracking'] as String? ?? 'none',
    );
  }
}

class PickingInfo {
  final int id;
  final String name;
  final String? origin;
  final String pickingType;
  final int? partnerId;
  final String? partnerName;
  final int locationId;
  final String locationName;
  final int locationDestId;
  final String locationDestName;
  final String state;
  final String? scheduledDate;
  final int totalLines;
  final List<PickingLine> lines;

  const PickingInfo({
    required this.id,
    required this.name,
    this.origin,
    required this.pickingType,
    this.partnerId,
    this.partnerName,
    required this.locationId,
    required this.locationName,
    required this.locationDestId,
    required this.locationDestName,
    required this.state,
    this.scheduledDate,
    required this.totalLines,
    required this.lines,
  });

  factory PickingInfo.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? [];
    return PickingInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      origin: json['origin'] as String?,
      pickingType: json['picking_type'] as String,
      partnerId: json['partner_id'] as int?,
      partnerName: json['partner_name'] as String?,
      locationId: json['location_id'] as int,
      locationName: json['location_name'] as String,
      locationDestId: json['location_dest_id'] as int,
      locationDestName: json['location_dest_name'] as String,
      state: json['state'] as String,
      scheduledDate: json['scheduled_date'] as String?,
      totalLines: json['total_lines'] as int,
      lines: rawLines
          .map((e) => PickingLine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class ReceiptTransferLine {
  final int productId;
  final String? defaultCode;
  final String productName;
  final double qtyDone;
  final String uom;

  const ReceiptTransferLine({
    required this.productId,
    this.defaultCode,
    required this.productName,
    required this.qtyDone,
    required this.uom,
  });

  factory ReceiptTransferLine.fromJson(Map<String, dynamic> json) {
    return ReceiptTransferLine(
      productId: json['product_id'] as int,
      defaultCode: json['default_code'] as String?,
      productName: json['product_name'] as String,
      qtyDone: (json['qty_done'] as num).toDouble(),
      uom: json['uom'] as String,
    );
  }
}

class ReceiptTransferResult {
  final String status;
  final bool receiptDone;
  final String receiptName;
  final List<ReceiptTransferLine> lines;
  final int? internalPickingId;
  final String? internalPickingName;
  final bool internalDone;
  final String message;

  const ReceiptTransferResult({
    required this.status,
    required this.receiptDone,
    required this.receiptName,
    required this.lines,
    this.internalPickingId,
    this.internalPickingName,
    required this.internalDone,
    required this.message,
  });

  factory ReceiptTransferResult.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? [];
    return ReceiptTransferResult(
      status: json['status'] as String? ?? 'ok',
      receiptDone: json['receipt_done'] as bool? ?? false,
      receiptName: json['receipt_name'] as String? ?? '',
      lines: rawLines
          .map((e) => ReceiptTransferLine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      internalPickingId: json['internal_picking_id'] as int?,
      internalPickingName: json['internal_picking_name'] as String?,
      internalDone: json['internal_done'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

// ─── Lot entry models ──────────────────────────────────────────────────────

class LotEntry {
  final String lotName;
  final double qty;
  final int? resultPackageId;

  const LotEntry({
    required this.lotName,
    required this.qty,
    this.resultPackageId,
  });

  Map<String, dynamic> toJson() => {
    'lot_name': lotName,
    'qty': qty,
    if (resultPackageId != null) 'result_package_id': resultPackageId,
  };
}

class LotChoice {
  final int id;
  final String name;
  final double qty;
  final String? expirationDate;

  const LotChoice({required this.id, required this.name, required this.qty, this.expirationDate});

  factory LotChoice.fromJson(Map<String, dynamic> json) {
    return LotChoice(
      id: json['id'] as int,
      name: json['name'] as String,
      qty: (json['qty'] as num).toDouble(),
      expirationDate: json['expiration_date'] as String?,
    );
  }
}

class CreatedLot {
  final int id;
  final String name;
  final double qty;

  const CreatedLot({required this.id, required this.name, this.qty = 1.0});

  factory CreatedLot.fromJson(Map<String, dynamic> json) => CreatedLot(
    id: json['id'] as int,
    name: json['name'] as String,
    qty: (json['qty'] as num?)?.toDouble() ?? 1.0,
  );
}

class MoveLotData {
  final int moveId;
  final String tracking; // 'none', 'lot', 'serial'
  final List<LotEntry> lots;
  final double qty;

  const MoveLotData({
    required this.moveId,
    required this.tracking,
    this.lots = const [],
    required this.qty,
  });

  bool get isComplete {
    if (tracking == 'none') return qty > 0;
    return lots.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'move_id': moveId,
    if (lots.isNotEmpty) 'lots': lots.map((l) => l.toJson()).toList(),
    'qty': qty,
  };

  MoveLotData copyWith({
    List<LotEntry>? lots,
    double? qty,
  }) =>
      MoveLotData(
        moveId: moveId,
        tracking: tracking,
        lots: lots ?? this.lots,
        qty: qty ?? this.qty,
      );
}

class ScanService {
  final Dio _dio;

  ScanService(this._dio);

  Future<LotInfo> getLotInfo(String code) async {
    try {
      final response = await _dio.post(
        ApiConstants.lotInfoPath,
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {'code': code},
        },
      );

      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;

      if (result == null) {
        throw const ServerException('Respon tidak valid dari server');
      }
      if (result.containsKey('error')) {
        throw ServerException(result['error'] as String);
      }

      return LotInfo.fromJson(result);
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Gagal terhubung ke server');
    }
  }

  Future<LocationInfo> getLocationInfo(String code) async {
    try {
      final response = await _dio.post(
        ApiConstants.locationInfoPath,
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {'code': code},
        },
      );

      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;

      if (result == null) {
        throw const ServerException('Respon tidak valid dari server');
      }
      if (result.containsKey('error')) {
        throw ServerException(result['error'] as String);
      }

      return LocationInfo.fromJson(result);
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Gagal terhubung ke server');
    }
  }

  Future<PalletInfo> getPalletInfo(String code) async {
    try {
      final response = await _dio.post(
        ApiConstants.palletInfoPath,
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {'code': code},
        },
      );

      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;

      if (result == null) {
        throw const ServerException('Respon tidak valid dari server');
      }
      if (result.containsKey('error')) {
        throw ServerException(result['error'] as String);
      }

      return PalletInfo.fromJson(result);
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Gagal terhubung ke server');
    }
  }

  Future<PickingInfo> getPickingInfo(String name) async {
    try {
      final response = await _dio.post(
        ApiConstants.pickingInfoPath,
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {'name': name},
        },
      );

      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;

      if (result == null) {
        throw const ServerException('Respon tidak valid dari server');
      }
      if (result.containsKey('error')) {
        throw ServerException(result['error'] as String);
      }

      return PickingInfo.fromJson(result);
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Gagal terhubung ke server');
    }
  }

  Future<ReceiptTransferResult> validateReceiptWithTransfer({
    required int pickingId,
    required List<MoveLotData> moveLines,
    String? targetLocationCode,
  }) async {
    try {
      final params = <String, dynamic>{
        'picking_id': pickingId,
        'move_lines': moveLines.map((m) => m.toJson()).toList(),
      };
      if (targetLocationCode != null) {
        params['target_location_code'] = targetLocationCode;
      }

      final response = await _dio.post(
        ApiConstants.receiptValidatePath,
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': params,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;

      if (result == null) {
        throw const ServerException('Respon tidak valid dari server');
      }
      if (result.containsKey('error')) {
        throw ServerException(result['error'] as String);
      }

      return ReceiptTransferResult.fromJson(result);
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Gagal terhubung ke server');
    }
  }

  Future<List<LotChoice>> searchLots({required int productId, String query = ''}) async {
    try {
      final response = await _dio.post(
        ApiConstants.lotSearchPath,
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {'product_id': productId, 'query': query},
        },
      );
      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) throw const ServerException('Respon tidak valid dari server');
      if (result.containsKey('error')) throw ServerException(result['error'] as String);
      final raw = result['lots'] as List<dynamic>? ?? [];
      return raw.map((e) => LotChoice.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Gagal terhubung ke server');
    }
  }

  Future<String> nextLotSequence() async {
    try {
      final response = await _dio.post(
        ApiConstants.lotNextSequencePath,
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {},
        },
      );
      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) throw const ServerException('Respon tidak valid dari server');
      if (result.containsKey('error')) throw ServerException(result['error'] as String);
      return result['next_lot'] as String? ?? '';
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Gagal terhubung ke server');
    }
  }

  Future<List<CreatedLot>> generateLots({
    required int productId,
    required String first,
    required String tracking,
    int count = 1,
    double qtyPerLot = 1.0,
    double totalQty = 0.0,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.lotGeneratePath,
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'product_id': productId,
            'first': first,
            'tracking': tracking,
            'count': count,
            'qty_per_lot': qtyPerLot,
            'total_qty': totalQty,
          },
        },
      );
      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) throw const ServerException('Respon tidak valid dari server');
      if (result.containsKey('error')) throw ServerException(result['error'] as String);
      final raw = result['created'] as List<dynamic>? ?? [];
      return raw.map((e) => CreatedLot.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Gagal terhubung ke server');
    }
  }
}
