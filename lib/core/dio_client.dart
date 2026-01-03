import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP Client menggunakan Dio untuk komunikasi dengan API
class DioClient {
  static DioClient? _instance;
  late Dio _dio;

  // ===========================================
  // PILIH SALAH SATU BASE URL:
  // ===========================================

  // 1. PRODUCTION (Server Hosting) - Gunakan ini untuk build release/APK final
  static const String baseUrl =
      'https://kutkatha.sisteminformasikotacerdas.id/api';

  // 2. LOCAL DEVELOPMENT - Uncomment salah satu di bawah jika testing lokal:
  // static const String baseUrl = 'http://192.168.137.1:8000/api'; // Device via Hotspot
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Emulator Android

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: connectTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to headers
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          debugPrint('ERROR MESSAGE: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  // Helper methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  /// Handle error dari DioException
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi timeout. Silakan coba lagi.';
      case DioExceptionType.sendTimeout:
        return 'Gagal mengirim data. Silakan coba lagi.';
      case DioExceptionType.receiveTimeout:
        return 'Gagal menerima data. Silakan coba lagi.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'];
        if (statusCode == 401) {
          return 'Sesi telah berakhir. Silakan login kembali.';
        } else if (statusCode == 422) {
          return message ?? 'Data tidak valid.';
        } else if (statusCode == 404) {
          return 'Data tidak ditemukan.';
        } else if (statusCode == 500) {
          return 'Terjadi kesalahan server.';
        }
        return message ?? 'Terjadi kesalahan.';
      case DioExceptionType.cancel:
        return 'Request dibatalkan.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
