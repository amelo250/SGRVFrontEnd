import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'jwt_token';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
  }

  static Future<String?> getToken() async {
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
    return token != null && token.isNotEmpty;
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
  }
}
