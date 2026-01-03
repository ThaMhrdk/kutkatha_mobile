import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';
import 'psikolog_model.dart';

/// Repository untuk Psikolog
class PsikologRepository {
  final DioClient _dioClient;

  PsikologRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  /// Get daftar psikolog
  Future<List<Psikolog>> getPsikologs({
    String? specialization,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (specialization != null) {
        queryParams['specialization'] = specialization;
      }
      if (search != null) {
        queryParams['search'] = search;
      }

      final response = await _dioClient.get(
        '/psikologs',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        return dataList.map((json) => Psikolog.fromJson(json)).toList();
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil data psikolog',
      );
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Get detail psikolog
  Future<Psikolog> getPsikologDetail(int psikologId) async {
    try {
      final response = await _dioClient.get('/psikologs/$psikologId');

      if (response.data['success'] == true) {
        return Psikolog.fromJson(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil detail psikolog',
      );
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Get jadwal psikolog
  Future<List<Schedule>> getPsikologSchedules(int psikologId) async {
    try {
      final response = await _dioClient.get('/psikologs/$psikologId/schedules');

      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        return dataList.map((json) => Schedule.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil jadwal');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }
}
