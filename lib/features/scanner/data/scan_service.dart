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
  final int productId;
  final String? defaultCode;
  final String productName;
  final double qtyDemand;
  final double qtyDone;
  final String uom;

  const PickingLine({
    required this.productId,
    this.defaultCode,
    required this.productName,
    required this.qtyDemand,
    required this.qtyDone,
    required this.uom,
  });

  factory PickingLine.fromJson(Map<String, dynamic> json) {
    return PickingLine(
      productId: json['product_id'] as int,
      defaultCode: json['default_code'] as String?,
      productName: json['product_name'] as String,
      qtyDemand: (json['qty_demand'] as num).toDouble(),
      qtyDone: (json['qty_done'] as num).toDouble(),
      uom: json['uom'] as String,
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
}
