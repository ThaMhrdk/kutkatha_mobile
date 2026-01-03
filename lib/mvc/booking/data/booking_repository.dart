import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';
import 'booking_model.dart';

/// Repository untuk Booking
class BookingRepository {
  final DioClient _dioClient;

  BookingRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  /// Get daftar booking user
  Future<List<Booking>> getBookings({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dioClient.get(
        '/user/bookings',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        return dataList.map((json) => Booking.fromJson(json)).toList();
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil data booking',
      );
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Get detail booking
  Future<Booking> getBookingDetail(int bookingId) async {
    try {
      final response = await _dioClient.get('/user/bookings/$bookingId');

      if (response.data['success'] == true) {
        return Booking.fromJson(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil detail booking',
      );
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Create booking baru
  Future<Booking> createBooking({
    required int scheduleId,
    required String complaint,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post(
        '/user/bookings',
        data: {
          'schedule_id': scheduleId,
          'complaint': complaint,
          'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        return Booking.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal membuat booking');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Cancel booking
  Future<void> cancelBooking(int bookingId, {String? reason}) async {
    try {
      final response = await _dioClient.post(
        '/user/bookings/$bookingId/cancel',
        data: {'reason': reason},
      );

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Gagal membatalkan booking',
        );
      }
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Process payment dengan upload bukti
  Future<Booking> processPayment({
    required int bookingId,
    required String paymentMethod,
    required String proofImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'payment_method': paymentMethod,
        'proof_of_payment': await MultipartFile.fromFile(
          proofImagePath,
          filename: 'payment_proof.jpg',
        ),
      });

      final response = await _dioClient.post(
        '/user/bookings/$bookingId/payment',
        data: formData,
      );

      if (response.data['success'] == true) {
        return Booking.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal memproses pembayaran');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception(DioClient.handleError(e));
    }
  }
}
