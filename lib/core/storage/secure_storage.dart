import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keySessionId = 'tji_session_id';
  static const _keyUserId = 'tji_user_id';
  static const _keyUserName = 'tji_user_name';
  static const _keyUserRole = 'tji_user_role';
  static const _keyBaseUrl = 'tji_base_url';
  static const _keyUrlList = 'tji_url_list';

  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: _keySessionId, value: sessionId);
  }

  Future<String?> getSessionId() async {
    return _storage.read(key: _keySessionId);
  }

  Future<void> saveUserId(int userId) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
  }

  Future<int?> getUserId() async {
    final val = await _storage.read(key: _keyUserId);
    return val != null ? int.tryParse(val) : null;
  }

  Future<void> saveUserName(String name) async {
    await _storage.write(key: _keyUserName, value: name);
  }

  Future<String?> getUserName() async {
    return _storage.read(key: _keyUserName);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _keyUserRole, value: role);
  }

  Future<String> getUserRole() async {
    return await _storage.read(key: _keyUserRole) ?? '';
  }

  Future<void> saveBaseUrl(String url) async {
    await _storage.write(key: _keyBaseUrl, value: url);
  }

  Future<String?> getBaseUrl() async {
    return _storage.read(key: _keyBaseUrl);
  }

  Future<List<String>> getUrlList() async {
    final raw = await _storage.read(key: _keyUrlList);
    if (raw == null) return [];
    try {
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }

  Future<void> addUrlToList(String url) async {
    final list = await getUrlList();
    if (!list.contains(url)) {
      list.insert(0, url);
    }
    await _storage.write(key: _keyUrlList, value: jsonEncode(list));
  }

  Future<void> removeUrlFromList(String url) async {
    final list = await getUrlList();
    list.remove(url);
    await _storage.write(key: _keyUrlList, value: jsonEncode(list));
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
