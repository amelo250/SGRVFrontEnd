import 'package:sgrv_frontend/core/session/session_state.dart';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'jwt_token';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static Future<void> _writeQueue = Future<void>.value();

  static Future<void> _mutate(Future<void> Function() operation) {
    final result = _writeQueue.then((_) => operation());
    _writeQueue = result.then((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }

  static Future<void> saveToken(String token, {int? expectedGeneration}) => _mutate(() async {
    if (expectedGeneration != null) SessionState.requireCurrent(expectedGeneration);
    await _secureStorage.write(key: _tokenKey, value: token);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    SessionState.changed();
  });

  static Future<String?> getToken() async {
    await _writeQueue;
    final secureToken = await _secureStorage.read(key: _tokenKey);
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }

    final preferences = await SharedPreferences.getInstance();
    final legacyToken = preferences.getString(_tokenKey);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      await saveToken(legacyToken);
      return legacyToken;
    }

    return null;
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    try {
      final parts = token.split('.');
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))) as Map<String, dynamic>;
      final expiry = payload['exp'];
      if (expiry is num && expiry * 1000 > DateTime.now().millisecondsSinceEpoch) return true;
    } catch (_) {
      // Un token malformado no representa una sesión local válida.
    }
    await deleteToken();
    return false;
  }

  static Future<String?> getRole() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      const roleClaim =
          'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
      return (payload[roleClaim] ?? payload['role'])?.toString();
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteToken({int? expectedGeneration}) => _mutate(() async {
    if (expectedGeneration != null && SessionState.generation.value != expectedGeneration) return;
    await _secureStorage.delete(key: _tokenKey);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    SessionState.changed();
  });
}
