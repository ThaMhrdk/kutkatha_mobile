import 'dart:convert';
import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../providers/api_provider.dart';
import '../local/local_storage_service.dart';

/// Repository untuk mengelola authentication
class AuthRepository {
  final ApiProvider _apiProvider;

  AuthRepository({ApiProvider? apiProvider})
    : _apiProvider = apiProvider ?? ApiProvider();

  /// Login user
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _apiProvider.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
          'device_name': 'flutter_mobile',
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Simpan token ke local storage
        await LocalStorageService.saveToken(data['token']);

        // Simpan user data
        await LocalStorageService.saveUserData(jsonEncode(data['user']));

        return User.fromJson(data['user']);
      } else {
        throw Exception(response.data['message'] ?? 'Login gagal');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Register user baru
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await _apiProvider.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'role': 'user', // Hanya user masyarakat
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Simpan token ke local storage
        await LocalStorageService.saveToken(data['token']);

        // Simpan user data
        await LocalStorageService.saveUserData(jsonEncode(data['user']));

        return User.fromJson(data['user']);
      } else {
        throw Exception(response.data['message'] ?? 'Registrasi gagal');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiProvider.post(ApiConfig.logout);
    } catch (e) {
      // Ignore error, tetap hapus local data
    } finally {
      await LocalStorageService.clearAll();
    }
  }

  /// Ambil data user saat ini
  Future<User?> getCurrentUser() async {
    try {
      // Coba ambil dari local storage dulu
      final userData = await LocalStorageService.getUserData();
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }

      // Jika tidak ada, ambil dari API
      final token = await LocalStorageService.getToken();
      if (token == null) return null;

      final response = await _apiProvider.get(ApiConfig.user);
      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        await LocalStorageService.saveUserData(
          jsonEncode(response.data['data']),
        );
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    return await LocalStorageService.isLoggedIn();
  }
}
