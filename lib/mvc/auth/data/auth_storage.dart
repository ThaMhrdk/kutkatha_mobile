import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_model.dart';

/// Storage lokal untuk auth (token & user data)
class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Simpan token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Ambil token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Hapus token
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Simpan user data
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Ambil user data
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  /// Hapus user data
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Cek apakah sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Clear semua data
  Future<void> clear() async {
    await deleteToken();
    await deleteUser();
  }
}
