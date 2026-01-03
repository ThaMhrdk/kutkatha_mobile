import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';
import 'user_model.dart';
import 'auth_storage.dart';

/// Repository untuk Auth (Login, Register, Logout)
class AuthRepository {
  final DioClient _dioClient;
  final AuthStorage _storage;

  AuthRepository({DioClient? dioClient, AuthStorage? storage})
    : _dioClient = dioClient ?? DioClient.instance,
      _storage = storage ?? AuthStorage();

  /// Login
  Future<User> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        final user = User.fromJson(response.data['data']['user']);

        // Only allow 'user' role to login via Flutter app
        if (user.role != 'user') {
          throw Exception(
            'Aplikasi ini hanya untuk pengguna. Silakan gunakan website untuk login sebagai ${user.role}.',
          );
        }

        await _storage.saveToken(token);
        await _storage.saveUser(user);

        return user;
      }
      throw Exception(response.data['message'] ?? 'Login gagal');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Register
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await _dioClient.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'role': 'user', // Default role for Flutter app registration
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        final user = User.fromJson(response.data['data']['user']);

        await _storage.saveToken(token);
        await _storage.saveUser(user);

        return user;
      }
      throw Exception(response.data['message'] ?? 'Registrasi gagal');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first);
        }
      }
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _dioClient.post('/logout');
    } catch (_) {
      // Ignore error saat logout
    } finally {
      await _storage.clear();
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      final isLoggedIn = await _storage.isLoggedIn();
      if (!isLoggedIn) return null;

      final response = await _dioClient.get('/user');
      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        await _storage.saveUser(user);
        return user;
      }
      return await _storage.getUser();
    } on DioException {
      return await _storage.getUser();
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? photoPath,
  }) async {
    try {
      // Gunakan POST dengan _method=PUT karena Laravel tidak bisa handle PUT dengan FormData
      final formData = FormData.fromMap({
        '_method': 'PUT',
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (address != null && address.isNotEmpty) 'address': address,
        if (photoPath != null)
          'photo': await MultipartFile.fromFile(
            photoPath,
            filename: 'profile.jpg',
          ),
      });

      final response = await _dioClient.post('/user/profile', data: formData);

      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        await _storage.saveUser(user);
        return user;
      }
      throw Exception(response.data['message'] ?? 'Gagal memperbarui profil');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first);
        }
      }
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Check login status
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  /// Get stored user
  Future<User?> getStoredUser() async {
    return await _storage.getUser();
  }
}
