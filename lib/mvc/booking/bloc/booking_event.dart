import 'package:equatable/equatable.dart';

/// Events untuk BookingBloc
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Load daftar booking
class BookingLoadRequested extends BookingEvent {
  final String? status;

  const BookingLoadRequested({this.status});

  @override
  List<Object?> get props => [status];
}

/// Load detail booking
class BookingDetailRequested extends BookingEvent {
  final int bookingId;

  const BookingDetailRequested({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

/// Create booking baru
class BookingCreateRequested extends BookingEvent {
  final int scheduleId;
  final String complaint;
  final String? notes;

  const BookingCreateRequested({
    required this.scheduleId,
    required this.complaint,
    this.notes,
  });

  @override
  List<Object?> get props => [scheduleId, complaint, notes];
}

/// Cancel booking
class BookingCancelRequested extends BookingEvent {
  final int bookingId;
  final String? reason;

  const BookingCancelRequested({required this.bookingId, this.reason});

  @override
  List<Object?> get props => [bookingId, reason];
}

/// Process payment dengan bukti transfer
class BookingPaymentRequested extends BookingEvent {
  final int bookingId;
  final String paymentMethod;
  final String proofImagePath;

  const BookingPaymentRequested({
    required this.bookingId,
    required this.paymentMethod,
    required this.proofImagePath,
  });

  @override
  List<Object?> get props => [bookingId, paymentMethod, proofImagePath];
}
