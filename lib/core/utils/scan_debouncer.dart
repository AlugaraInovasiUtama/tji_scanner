import '../constants/scan_constants.dart';

class ScanDebouncer {
  final _scannedCodes = <String, DateTime>{};
  final Duration _cooldown;

  ScanDebouncer({Duration? cooldown})
      : _cooldown = cooldown ?? ScanConstants.scanCooldown;

  bool isDuplicate(String code) {
    _cleanup();
    final lastScan = _scannedCodes[code];
    if (lastScan == null) return false;
    return DateTime.now().difference(lastScan) < _cooldown;
  }

  void recordScan(String code) {
    _scannedCodes[code] = DateTime.now();
    _cleanup();
  }

  void reset() {
    _scannedCodes.clear();
  }

  void _cleanup() {
    _scannedCodes.removeWhere(
      (_, time) => DateTime.now().difference(time) > const Duration(minutes: 5),
    );
  }
}
