import 'package:equatable/equatable.dart';
import '../../models/consultation.dart';

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
  final List<ChatMessage> messages;
  final int? lastMessageId;

  const ChatLoaded({
    required this.consultationId,
    required this.messages,
    this.lastMessageId,
  });

  ChatLoaded copyWith({List<ChatMessage>? messages, int? lastMessageId}) {
    return ChatLoaded(
      consultationId: consultationId,
      messages: messages ?? this.messages,
      lastMessageId: lastMessageId ?? this.lastMessageId,
    );
  }

  @override
  List<Object?> get props => [consultationId, messages, lastMessageId];
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
