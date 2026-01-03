import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../models/psikolog.dart';
import '../../models/schedule.dart';
import '../providers/api_provider.dart';

/// Repository untuk Psikolog
class PsikologRepository {
  final ApiProvider _apiProvider;

  PsikologRepository({ApiProvider? apiProvider})
    : _apiProvider = apiProvider ?? ApiProvider();

  /// Get daftar psikolog
  Future<List<Psikolog>> getPsikologs({
    String? specialization,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (specialization != null)
        queryParams['specialization'] = specialization;
      if (search != null) queryParams['search'] = search;

      final response = await _apiProvider.get(
        ApiConfig.psikologs,
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
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Get detail psikolog
  Future<Psikolog> getPsikologDetail(int psikologId) async {
    try {
      final response = await _apiProvider.get(
        '${ApiConfig.psikologs}/$psikologId',
      );

      if (response.data['success'] == true) {
        return Psikolog.fromJson(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil detail psikolog',
      );
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Get jadwal psikolog
  Future<List<Schedule>> getPsikologSchedules(int psikologId) async {
    try {
      final response = await _apiProvider.get(
        '${ApiConfig.psikologs}/$psikologId/schedules',
      );

      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        return dataList.map((json) => Schedule.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil jadwal');
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }
}
