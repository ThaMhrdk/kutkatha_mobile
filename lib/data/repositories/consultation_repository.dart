import 'dart:async';
import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../models/consultation.dart';
import '../providers/api_provider.dart';

/// Repository untuk Consultation dan Chat
class ConsultationRepository {
  final ApiProvider _apiProvider;

  ConsultationRepository({ApiProvider? apiProvider})
    : _apiProvider = apiProvider ?? ApiProvider();

  /// Get daftar konsultasi user
  Future<List<Consultation>> getConsultations({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _apiProvider.get(
        ApiConfig.consultations,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        return dataList.map((json) => Consultation.fromJson(json)).toList();
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil data konsultasi',
      );
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Get detail konsultasi
  Future<Consultation> getConsultationDetail(int consultationId) async {
    try {
      final response = await _apiProvider.get(
        '${ApiConfig.consultations}/$consultationId',
      );

      if (response.data['success'] == true) {
        return Consultation.fromJson(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil detail konsultasi',
      );
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Get chat messages (untuk polling)
  Future<List<ChatMessage>> getChatMessages(
    int consultationId, {
    int? afterId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (afterId != null) queryParams['after_id'] = afterId;

      final response = await _apiProvider.get(
        ApiConfig.chatMessages(consultationId),
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> messagesList = data['messages'] ?? [];
        return messagesList.map((json) => ChatMessage.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil pesan');
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Send chat message
  Future<ChatMessage> sendMessage(int consultationId, String message) async {
    try {
      final response = await _apiProvider.post(
        ApiConfig.chatMessages(consultationId),
        data: {'message': message},
      );

      if (response.data['success'] == true) {
        return ChatMessage.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal mengirim pesan');
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Submit feedback
  Future<void> submitFeedback(
    int consultationId, {
    required int rating,
    String? comment,
    bool isAnonymous = false,
  }) async {
    try {
      final response = await _apiProvider.post(
        '${ApiConfig.consultations}/$consultationId/feedback',
        data: {
          'rating': rating,
          'comment': comment,
          'is_anonymous': isAnonymous,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal mengirim feedback');
      }
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }
}
