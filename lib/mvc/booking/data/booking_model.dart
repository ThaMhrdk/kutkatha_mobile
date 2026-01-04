import 'package:equatable/equatable.dart';
import '../../psikolog/data/psikolog_model.dart';
import '../../auth/data/user_model.dart';

/// Model untuk Booking
class Booking extends Equatable {
  final int id;
  final int userId;
  final int scheduleId;
  final String status;
  final String? complaint;
  final String? notes;
  final String? cancelReason;
  final Schedule? schedule;
  final User? user;
  final Payment? payment;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.status,
    this.complaint,
    this.notes,
    this.cancelReason,
    this.schedule,
    this.user,
    this.payment,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']) ?? 0,
      scheduleId: _parseInt(json['schedule_id']) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      complaint: json['complaint']?.toString(),
      notes: json['notes']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      schedule: json['schedule'] != null
          ? Schedule.fromJson(json['schedule'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// Helper untuk parse int dengan aman
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  bool get canCancel => status == 'pending' || status == 'confirmed';

  // User bisa bayar jika pending/confirmed dan belum bayar
  bool get canPay =>
      (status == 'pending' || status == 'confirmed') &&
      (payment == null || payment?.status == 'pending');

  // Cek apakah sudah bayar
  bool get isPaid => payment?.status == 'paid';

  // Status pembayaran
  String get paymentStatusLabel {
    // Jika booking dibatalkan, tampilkan status dibatalkan
    if (status == 'cancelled') return 'Dibatalkan';
    if (payment == null) return 'Belum Bayar';
    switch (payment!.status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Sudah Dibayar';
      case 'failed':
        return 'Dibatalkan';
      case 'refunded':
        return 'Dikembalikan';
      default:
        return payment!.status;
    }
  }

  @override
  List<Object?> get props => [id, userId, scheduleId, status];
}

/// Model untuk Payment
class Payment extends Equatable {
  final int id;
  final int bookingId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? paymentCode;
  final DateTime? paidAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.paymentCode,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: _parsePaymentInt(json['id']) ?? 0,
      bookingId: _parsePaymentInt(json['booking_id']) ?? 0,
      amount: _parseDouble(json['amount']),
      paymentMethod: json['payment_method']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      paymentCode: json['payment_code']?.toString(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
    );
  }

  /// Helper untuk parse int dengan aman
  static int? _parsePaymentInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get formattedAmount {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  List<Object?> get props => [id, bookingId, amount, status];
}

// Helper function untuk parse double dari API
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
