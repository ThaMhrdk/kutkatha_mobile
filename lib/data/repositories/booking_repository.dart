import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../models/booking.dart';
import '../providers/api_provider.dart';

/// Repository untuk Booking
class BookingRepository {
  final ApiProvider _apiProvider;

  BookingRepository({ApiProvider? apiProvider})
    : _apiProvider = apiProvider ?? ApiProvider();

  /// Get daftar booking user
  Future<List<Booking>> getBookings({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _apiProvider.get(
        ApiConfig.bookings,
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
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Get detail booking
  Future<Booking> getBookingDetail(int bookingId) async {
    try {
      final response = await _apiProvider.get(
        '${ApiConfig.bookings}/$bookingId',
      );

      if (response.data['success'] == true) {
        return Booking.fromJson(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil detail booking',
      );
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Create booking baru
  Future<Booking> createBooking({
    required int scheduleId,
    String? notes,
  }) async {
    try {
      final response = await _apiProvider.post(
        ApiConfig.bookings,
        data: {'schedule_id': scheduleId, 'notes': notes},
      );

      if (response.data['success'] == true) {
        return Booking.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal membuat booking');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Cancel booking
  Future<void> cancelBooking(int bookingId, {String? reason}) async {
    try {
      final response = await _apiProvider.post(
        '${ApiConfig.bookings}/$bookingId/cancel',
        data: {'reason': reason},
      );

      if (response.data['success'] != true) {
        throw Exception(
          response.data['message'] ?? 'Gagal membatalkan booking',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Process payment
  Future<Booking> processPayment(int bookingId, String paymentMethod) async {
    try {
      final response = await _apiProvider.post(
        '${ApiConfig.bookings}/$bookingId/payment',
        data: {'payment_method': paymentMethod},
      );

      if (response.data['success'] == true) {
        return Booking.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal memproses pembayaran');
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }
}
