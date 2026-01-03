import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/booking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

/// BLoC untuk Booking
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _repository;

  BookingBloc({BookingRepository? repository})
    : _repository = repository ?? BookingRepository(),
      super(BookingInitial()) {
    on<BookingLoadRequested>(_onLoadRequested);
    on<BookingDetailRequested>(_onDetailRequested);
    on<BookingCreateRequested>(_onCreateRequested);
    on<BookingCancelRequested>(_onCancelRequested);
    on<BookingPaymentRequested>(_onPaymentRequested);
  }

  Future<void> _onLoadRequested(
    BookingLoadRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final bookings = await _repository.getBookings(status: event.status);
      emit(BookingLoaded(bookings: bookings));
    } catch (e) {
      emit(BookingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDetailRequested(
    BookingDetailRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final booking = await _repository.getBookingDetail(event.bookingId);
      emit(BookingDetailLoaded(booking: booking));
    } catch (e) {
      emit(BookingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateRequested(
    BookingCreateRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final booking = await _repository.createBooking(
        scheduleId: event.scheduleId,
        complaint: event.complaint,
        notes: event.notes,
      );
      emit(
        BookingOperationSuccess(
          message: 'Booking berhasil dibuat!',
          booking: booking,
        ),
      );
    } catch (e) {
      emit(BookingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCancelRequested(
    BookingCancelRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      await _repository.cancelBooking(event.bookingId, reason: event.reason);
      emit(
        const BookingOperationSuccess(message: 'Booking berhasil dibatalkan'),
      );
    } catch (e) {
      emit(BookingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onPaymentRequested(
    BookingPaymentRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final booking = await _repository.processPayment(
        bookingId: event.bookingId,
        paymentMethod: event.paymentMethod,
        proofImagePath: event.proofImagePath,
      );
      emit(
        BookingOperationSuccess(
          message: 'Pembayaran berhasil! Menunggu konfirmasi psikolog.',
          booking: booking,
        ),
      );
    } catch (e) {
      emit(BookingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
