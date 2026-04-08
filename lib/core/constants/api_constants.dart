class ApiConstants {
  ApiConstants._();

  // static const String defaultBaseUrl = 'https://odootji.alugara.my.id';
  static const String defaultBaseUrl = 'https://odoo16.odoohub.site';
  static const String jsonRpcPath = '/web/dataset/call_kw';
  static const String loginPath = '/web/session/authenticate';
  static const String logoutPath = '/web/session/destroy';

  // Warehouse scan endpoints
  static const String lotInfoPath = '/api/lot/info';
  static const String lotSearchPath = '/api/lot/search';
  static const String lotGeneratePath = '/api/lot/generate';
  static const String locationInfoPath = '/api/location/info';
  static const String palletInfoPath = '/api/pallet/info';
  static const String pickingInfoPath = '/api/picking/info';
  static const String receiptValidatePath = '/api/picking/validate_receipt_transfer';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String contentType = 'application/json';
}
