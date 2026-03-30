class AppConstants {
  AppConstants._();

  static const String appName = 'TJI Scanner';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyBaseUrl = 'base_url';
  static const String keySessionId = 'session_id';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyDarkMode = 'dark_mode';
  static const String keyBeepEnabled = 'beep_enabled';
  static const String keyVibrateEnabled = 'vibrate_enabled';

  // Cache durations
  static const Duration productCacheDuration = Duration(hours: 24);
  static const Duration locationCacheDuration = Duration(hours: 1);
  static const Duration stockCacheDuration = Duration(minutes: 15);

  // Sync settings
  static const int maxRetryCount = 3;
  static const Duration syncInterval = Duration(minutes: 5);

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
