import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';

  SharedPreferences? _prefs;
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveEmail(String email) async {
    final prefs = await _getPrefs();
    await prefs.setString(_emailKey, email);
  }

  Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(_emailKey);
  }

  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
  }
}
