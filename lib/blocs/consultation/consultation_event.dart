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

/// Load chat messages
class ChatLoadRequested extends ConsultationEvent {
  final int consultationId;
  final int? afterId;

  const ChatLoadRequested({required this.consultationId, this.afterId});

  @override
  List<Object?> get props => [consultationId, afterId];
}

/// Send chat message
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
