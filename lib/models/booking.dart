import 'package:equatable/equatable.dart';
import 'schedule.dart';
import 'user.dart';

/// Model untuk Booking
class Booking extends Equatable {
  final int id;
  final int userId;
  final int scheduleId;
  final String status; // pending, confirmed, completed, cancelled
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
    this.notes,
    this.cancelReason,
    this.schedule,
    this.user,
    this.payment,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      scheduleId: json['schedule_id'] ?? 0,
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      cancelReason: json['cancel_reason'],
      schedule: json['schedule'] != null
          ? Schedule.fromJson(json['schedule'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
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
  bool get canPay =>
      status == 'confirmed' && (payment == null || payment?.status != 'paid');

  @override
  List<Object?> get props => [id, userId, scheduleId, status];
}

/// Model untuk Payment
class Payment extends Equatable {
  final int id;
  final int bookingId;
  final double amount;
  final String paymentMethod;
  final String status; // pending, paid, failed, refunded
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
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? 'pending',
      paymentCode: json['payment_code'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  String get formattedAmount {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  List<Object?> get props => [id, bookingId, amount, status];
}
