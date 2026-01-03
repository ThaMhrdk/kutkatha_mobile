import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';
import 'consultation_model.dart';

/// Repository untuk Consultation
class ConsultationRepository {
  final DioClient _dioClient;

  ConsultationRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  /// Get daftar konsultasi
  Future<List<Consultation>> getConsultations({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dioClient.get(
        '/user/consultations',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        List<dynamic> dataList;
        if (data is List) {
          dataList = data;
        } else if (data is Map && data['data'] != null) {
          dataList = data['data'] as List;
        } else {
          dataList = [];
        }
        return dataList
            .map((json) => Consultation.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil data konsultasi',
      );
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Get detail konsultasi
  Future<Consultation> getConsultationDetail(int consultationId) async {
    try {
      final response = await _dioClient.get(
        '/user/consultations/$consultationId',
      );

      if (response.data['success'] == true) {
        return Consultation.fromJson(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil detail konsultasi',
      );
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Get chat messages by booking ID (auto-creates consultation)
  Future<Map<String, dynamic>> getChatByBooking(
    int bookingId, {
    int? afterId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (afterId != null) {
        queryParams['after_id'] = afterId;
      }

      final response = await _dioClient.get(
        '/user/bookings/$bookingId/chat',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Parse consultation
        Consultation? consultation;
        if (data['consultation'] != null) {
          consultation = Consultation.fromJson(
            data['consultation'] as Map<String, dynamic>,
          );
        }

        // Parse messages
        List<ChatMessage> messages = [];
        if (data['messages'] != null && data['messages'] is List) {
          messages = (data['messages'] as List)
              .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        return {
          'consultation': consultation,
          'messages': messages,
          'last_id': data['last_id'],
        };
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil pesan');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Send message by booking ID (auto-creates consultation)
  Future<ChatMessage> sendMessageByBooking(
    int bookingId,
    String message,
  ) async {
    try {
      final response = await _dioClient.post(
        '/user/bookings/$bookingId/chat',
        data: {'message': message},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data['message'] != null) {
          return ChatMessage.fromJson(data['message'] as Map<String, dynamic>);
        }
        throw Exception('Response tidak valid');
      }
      throw Exception(response.data['message'] ?? 'Gagal mengirim pesan');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Get chat messages (legacy - by consultation ID)
  Future<List<ChatMessage>> getChatMessages(
    int consultationId, {
    int? afterId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (afterId != null) {
        queryParams['after_id'] = afterId;
      }

      final response = await _dioClient.get(
        '/user/consultations/$consultationId/messages',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        List<dynamic> messagesList;
        if (data is Map && data['messages'] != null) {
          messagesList = data['messages'] as List;
        } else if (data is List) {
          messagesList = data;
        } else {
          messagesList = [];
        }
        return messagesList
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil pesan');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Send message (legacy - by consultation ID)
  Future<ChatMessage> sendMessage(int consultationId, String message) async {
    try {
      final response = await _dioClient.post(
        '/user/consultations/$consultationId/messages',
        data: {'message': message},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map && data['message'] != null) {
          return ChatMessage.fromJson(data['message'] as Map<String, dynamic>);
        }
        return ChatMessage.fromJson(data as Map<String, dynamic>);
      }
      throw Exception(response.data['message'] ?? 'Gagal mengirim pesan');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
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
      final response = await _dioClient.post(
        '/user/consultations/$consultationId/feedback',
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
      throw Exception(DioClient.handleError(e));
    }
  }
}
