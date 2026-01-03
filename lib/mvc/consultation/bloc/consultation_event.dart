import 'package:equatable/equatable.dart';

/// Events untuk ConsultationBloc
abstract class ConsultationEvent extends Equatable {
  const ConsultationEvent();

  @override
  List<Object?> get props => [];
}

/// Load daftar konsultasi
class ConsultationLoadRequested extends ConsultationEvent {
  final String? status;

  const ConsultationLoadRequested({this.status});

  @override
  List<Object?> get props => [status];
}

/// Load detail konsultasi
class ConsultationDetailRequested extends ConsultationEvent {
  final int consultationId;

  const ConsultationDetailRequested({required this.consultationId});

  @override
  List<Object?> get props => [consultationId];
}

/// Load chat messages (by consultation ID - legacy)
class ChatLoadRequested extends ConsultationEvent {
  final int consultationId;
  final int? afterId;

  const ChatLoadRequested({required this.consultationId, this.afterId});

  @override
  List<Object?> get props => [consultationId, afterId];
}

/// Load chat messages by booking ID (auto-creates consultation)
class ChatByBookingLoadRequested extends ConsultationEvent {
  final int bookingId;
  final int? afterId;

  const ChatByBookingLoadRequested({required this.bookingId, this.afterId});

  @override
  List<Object?> get props => [bookingId, afterId];
}

/// Send chat message (by consultation ID - legacy)
class ChatSendRequested extends ConsultationEvent {
  final int consultationId;
  final String message;

  const ChatSendRequested({
    required this.consultationId,
    required this.message,
  });

  @override
  List<Object?> get props => [consultationId, message];
}

/// Send chat message by booking ID (auto-creates consultation)
class ChatByBookingSendRequested extends ConsultationEvent {
  final int bookingId;
  final String message;

  const ChatByBookingSendRequested({
    required this.bookingId,
    required this.message,
  });

  @override
  List<Object?> get props => [bookingId, message];
}

/// Submit feedback
class FeedbackSubmitRequested extends ConsultationEvent {
  final int consultationId;
  final int rating;
  final String? comment;
  final bool isAnonymous;

  const FeedbackSubmitRequested({
    required this.consultationId,
    required this.rating,
    this.comment,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [consultationId, rating, comment, isAnonymous];
}
