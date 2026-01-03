import 'package:equatable/equatable.dart';
import '../../models/booking.dart';

/// States untuk BookingBloc
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<Booking> bookings;

  const BookingLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class BookingDetailLoaded extends BookingState {
  final Booking booking;

  const BookingDetailLoaded({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingOperationSuccess extends BookingState {
  final String message;
  final Booking? booking;

  const BookingOperationSuccess({required this.message, this.booking});

  @override
  List<Object?> get props => [message, booking];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}
