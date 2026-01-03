import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../local/local_storage_service.dart';

/// Dio HTTP Client dengan interceptor untuk API calls
class ApiProvider {
  late Dio _dio;

  ApiProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Tambahkan interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Tambahkan token ke setiap request jika ada
          final token = await LocalStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          );
          print('ERROR MESSAGE: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  /// GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  /// Handle Dio Error dan kembalikan pesan yang user-friendly
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi timeout. Periksa koneksi internet Anda.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Coba lagi nanti.';
      case DioExceptionType.receiveTimeout:
        return 'Server tidak merespons. Coba lagi nanti.';
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request dibatalkan.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      default:
        return 'Terjadi kesalahan. Coba lagi nanti.';
    }
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid.';
      case 401:
        return 'Sesi telah berakhir. Silakan login kembali.';
      case 403:
        return 'Anda tidak memiliki akses.';
      case 404:
        return 'Data tidak ditemukan.';
      case 422:
        return 'Data yang dikirim tidak valid.';
      case 500:
        return 'Terjadi kesalahan di server.';
      default:
        return 'Terjadi kesalahan. (Error $statusCode)';
    }
  }
}
