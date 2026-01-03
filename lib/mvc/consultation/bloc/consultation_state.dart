import 'package:equatable/equatable.dart';
import '../data/consultation_model.dart';

/// States untuk ConsultationBloc
abstract class ConsultationState extends Equatable {
  const ConsultationState();

  @override
  List<Object?> get props => [];
}

class ConsultationInitial extends ConsultationState {}

class ConsultationLoading extends ConsultationState {}

class ConsultationLoaded extends ConsultationState {
  final List<Consultation> consultations;

  const ConsultationLoaded({required this.consultations});

  @override
  List<Object?> get props => [consultations];
}

class ConsultationDetailLoaded extends ConsultationState {
  final Consultation consultation;

  const ConsultationDetailLoaded({required this.consultation});

  @override
  List<Object?> get props => [consultation];
}

class ChatLoaded extends ConsultationState {
  final int consultationId;
  final int? bookingId;
  final List<ChatMessage> messages;
  final int? lastMessageId;
  final Consultation? consultation;

  const ChatLoaded({
    required this.consultationId,
    required this.messages,
    this.bookingId,
    this.lastMessageId,
    this.consultation,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    int? lastMessageId,
    Consultation? consultation,
  }) {
    return ChatLoaded(
      consultationId: consultationId,
      bookingId: bookingId,
      messages: messages ?? this.messages,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      consultation: consultation ?? this.consultation,
    );
  }

  @override
  List<Object?> get props => [
    consultationId,
    bookingId,
    messages,
    lastMessageId,
    consultation,
  ];
}

class ChatSending extends ConsultationState {
  final List<ChatMessage> currentMessages;

  const ChatSending({required this.currentMessages});

  @override
  List<Object?> get props => [currentMessages];
}

class ConsultationOperationSuccess extends ConsultationState {
  final String message;

  const ConsultationOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ConsultationError extends ConsultationState {
  final String message;

  const ConsultationError({required this.message});

  @override
  List<Object?> get props => [message];
}
