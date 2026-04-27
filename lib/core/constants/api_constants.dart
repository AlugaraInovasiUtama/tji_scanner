class ApiConstants {
  ApiConstants._();

  static const String defaultBaseUrl = 'https://odootji.alugara.my.id';
  // static const String defaultBaseUrl = 'https://odoo16.odoohub.site';
  static const String jsonRpcPath = '/web/dataset/call_kw';
  static const String loginPath = '/web/session/authenticate';
  static const String logoutPath = '/web/session/destroy';

  // Warehouse scan endpoints
  static const String lotInfoPath = '/api/lot/info';
  static const String lotSearchPath = '/api/lot/search';
  static const String lotGeneratePath = '/api/lot/generate';
  static const String lotNextSequencePath = '/api/lot/next_sequence';
  static const String locationInfoPath = '/api/location/info';
  static const String palletInfoPath = '/api/pallet/info';
  static const String pickingInfoPath = '/api/picking/info';
  static const String receiptValidatePath = '/api/picking/validate_receipt_transfer';
  static const String putInPackPath = '/api/picking/put_in_pack';
  static const String userRolePath = '/api/user/role';

  // Create Transfer endpoints
  static const String partnerSearchPath = '/api/partner/search';
  static const String pickingTypeListPath = '/api/picking_type/list';
  static const String productSearchPath = '/api/product/search';
  static const String transferCreatePath = '/api/transfer/create';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String contentType = 'application/json';
}
