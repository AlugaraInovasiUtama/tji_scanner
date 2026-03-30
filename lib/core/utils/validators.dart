import '../constants/scan_constants.dart';

class QrValidator {
  QrValidator._();

  static String detectType(String code) {
    if (code.startsWith(ScanConstants.boxPrefix)) return ScanConstants.typeBox;
    if (code.startsWith(ScanConstants.palletPrefix)) return ScanConstants.typePallet;
    if (code.startsWith(ScanConstants.rackPrefix)) return ScanConstants.typeRack;
    if (code.startsWith(ScanConstants.productPrefix)) return ScanConstants.typeProduct;
    return ScanConstants.typeUnknown;
  }

  static bool isBox(String code) => detectType(code) == ScanConstants.typeBox;
  static bool isPallet(String code) => detectType(code) == ScanConstants.typePallet;
  static bool isRack(String code) => detectType(code) == ScanConstants.typeRack;
  static bool isProduct(String code) => detectType(code) == ScanConstants.typeProduct;

  static bool isValid(String code) =>
      detectType(code) != ScanConstants.typeUnknown;

  static String errorMessage(String code, String expectedType) {
    final detected = detectType(code);
    return 'Scan salah. Dibutuhkan: ${_typeLabel(expectedType)}, '
        'tetapi yang di-scan: ${_typeLabel(detected)}.';
  }

  static String _typeLabel(String type) {
    switch (type) {
      case ScanConstants.typeBox:
        return 'Box';
      case ScanConstants.typePallet:
        return 'Pallet';
      case ScanConstants.typeRack:
        return 'Rack';
      case ScanConstants.typeProduct:
        return 'Product';
      default:
        return 'Unknown';
    }
  }
}
