import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class ScanFeedback {
  ScanFeedback._();

  static bool _vibrateEnabled = true;
  static bool _beepEnabled = true;

  static void setVibrate(bool enabled) => _vibrateEnabled = enabled;
  static void setBeep(bool enabled) => _beepEnabled = enabled;

  /// Called on every successful scan
  static Future<void> success() async {
    if (_vibrateEnabled) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) await Vibration.vibrate(duration: 80);
    }
    if (_beepEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Called on scan error / wrong QR type
  static Future<void> error() async {
    if (_vibrateEnabled) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        await Vibration.vibrate(pattern: [0, 100, 80, 100]);
      }
    }
    if (_beepEnabled) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Called on workflow completion (e.g., putaway confirmed)
  static Future<void> complete() async {
    if (_vibrateEnabled) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        await Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 300]);
      }
    }
  }

  /// Called on duplicate scan detected
  static Future<void> duplicate() async {
    if (_vibrateEnabled) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) await Vibration.vibrate(duration: 50);
    }
  }
}
