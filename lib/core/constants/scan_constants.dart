class ScanConstants {
  ScanConstants._();

  // QR Code prefixes
  static const String boxPrefix = 'BOX-';
  static const String palletPrefix = 'PAL-';
  static const String rackPrefix = 'RACK-';
  static const String productPrefix = 'PROD-';

  // Debounce settings
  static const Duration scanCooldown = Duration(milliseconds: 1500);
  static const Duration processingTimeout = Duration(seconds: 10);

  // Scan types
  static const String typeBox = 'box';
  static const String typePallet = 'pallet';
  static const String typeRack = 'rack';
  static const String typeProduct = 'product';
  static const String typeUnknown = 'unknown';
}
