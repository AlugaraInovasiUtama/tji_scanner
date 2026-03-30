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
}
