import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/consultation_repository.dart';
import '../data/consultation_model.dart';
import 'consultation_event.dart';
import 'consultation_state.dart';

/// BLoC untuk Consultation dan Chat
class ConsultationBloc extends Bloc<ConsultationEvent, ConsultationState> {
  final ConsultationRepository _repository;

  ConsultationBloc({ConsultationRepository? repository})
    : _repository = repository ?? ConsultationRepository(),
      super(ConsultationInitial()) {
    on<ConsultationLoadRequested>(_onLoadRequested);
    on<ConsultationDetailRequested>(_onDetailRequested);
    on<ChatLoadRequested>(_onChatLoadRequested);
    on<ChatSendRequested>(_onChatSendRequested);
    on<ChatByBookingLoadRequested>(_onChatByBookingLoadRequested);
    on<ChatByBookingSendRequested>(_onChatByBookingSendRequested);
    on<FeedbackSubmitRequested>(_onFeedbackSubmitRequested);
  }

  Future<void> _onLoadRequested(
    ConsultationLoadRequested event,
    Emitter<ConsultationState> emit,
  ) async {
    emit(ConsultationLoading());
    try {
      final consultations = await _repository.getConsultations(
        status: event.status,
      );
      emit(ConsultationLoaded(consultations: consultations));
    } catch (e) {
      emit(
        ConsultationError(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onDetailRequested(
    ConsultationDetailRequested event,
    Emitter<ConsultationState> emit,
  ) async {
    emit(ConsultationLoading());
    try {
      final consultation = await _repository.getConsultationDetail(
        event.consultationId,
      );
      emit(ConsultationDetailLoaded(consultation: consultation));
    } catch (e) {
      emit(
        ConsultationError(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onChatLoadRequested(
    ChatLoadRequested event,
    Emitter<ConsultationState> emit,
  ) async {
    try {
      final messages = await _repository.getChatMessages(
        event.consultationId,
        afterId: event.afterId,
      );

      final currentState = state;
      if (currentState is ChatLoaded && event.afterId != null) {
        final allMessages = [...currentState.messages, ...messages];
        emit(
          ChatLoaded(
            consultationId: event.consultationId,
            messages: allMessages,
            lastMessageId: messages.isNotEmpty
                ? messages.last.id
                : currentState.lastMessageId,
          ),
        );
      } else {
        emit(
          ChatLoaded(
            consultationId: event.consultationId,
            messages: messages,
            lastMessageId: messages.isNotEmpty ? messages.last.id : null,
          ),
        );
      }
    } catch (e) {
      emit(
        ConsultationError(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onChatSendRequested(
    ChatSendRequested event,
    Emitter<ConsultationState> emit,
  ) async {
    final currentState = state;
    List<ChatMessage> currentMessages = [];

    if (currentState is ChatLoaded) {
      currentMessages = currentState.messages;
      emit(ChatSending(currentMessages: currentMessages));
    }

    try {
      final newMessage = await _repository.sendMessage(
        event.consultationId,
        event.message,
      );

      emit(
        ChatLoaded(
          consultationId: event.consultationId,
          messages: [...currentMessages, newMessage],
          lastMessageId: newMessage.id,
        ),
      );
    } catch (e) {
      emit(
        ChatLoaded(
          consultationId: event.consultationId,
          messages: currentMessages,
        ),
      );
      emit(
        ConsultationError(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  /// Handle chat by booking (auto-creates consultation)
  Future<void> _onChatByBookingLoadRequested(
    ChatByBookingLoadRequested event,
    Emitter<ConsultationState> emit,
  ) async {
    try {
      final result = await _repository.getChatByBooking(
        event.bookingId,
        afterId: event.afterId,
      );

      final consultation = result['consultation'] as Consultation?;
      final messages = result['messages'] as List<ChatMessage>;
      final lastId = result['last_id'];

      final currentState = state;
      if (currentState is ChatLoaded && event.afterId != null) {
        // Merge with existing messages
        final allMessages = [...currentState.messages, ...messages];
        emit(
          ChatLoaded(
            consultationId: consultation?.id ?? 0,
            bookingId: event.bookingId,
            messages: allMessages,
            lastMessageId: lastId ?? currentState.lastMessageId,
            consultation: consultation,
          ),
        );
      } else {
        emit(
          ChatLoaded(
            consultationId: consultation?.id ?? 0,
            bookingId: event.bookingId,
            messages: messages,
            lastMessageId: lastId,
            consultation: consultation,
          ),
        );
      }
    } catch (e) {
      emit(
        ConsultationError(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  /// Handle send message by booking
  Future<void> _onChatByBookingSendRequested(
    ChatByBookingSendRequested event,
    Emitter<ConsultationState> emit,
  ) async {
    final currentState = state;
    List<ChatMessage> currentMessages = [];
    int? consultationId;
    Consultation? consultation;

    if (currentState is ChatLoaded) {
      currentMessages = currentState.messages;
      consultationId = currentState.consultationId;
      consultation = currentState.consultation;
      emit(ChatSending(currentMessages: currentMessages));
    }

    try {
      final newMessage = await _repository.sendMessageByBooking(
        event.bookingId,
        event.message,
      );

      emit(
        ChatLoaded(
          consultationId: consultationId ?? 0,
          bookingId: event.bookingId,
          messages: [...currentMessages, newMessage],
          lastMessageId: newMessage.id,
          consultation: consultation,
        ),
      );
    } catch (e) {
      emit(
        ChatLoaded(
          consultationId: consultationId ?? 0,
          bookingId: event.bookingId,
          messages: currentMessages,
          consultation: consultation,
        ),
      );
      emit(
        ConsultationError(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onFeedbackSubmitRequested(
    FeedbackSubmitRequested event,
    Emitter<ConsultationState> emit,
  ) async {
    emit(ConsultationLoading());
    try {
      await _repository.submitFeedback(
        event.consultationId,
        rating: event.rating,
        comment: event.comment,
        isAnonymous: event.isAnonymous,
      );
      emit(
        const ConsultationOperationSuccess(
          message: 'Feedback berhasil dikirim!',
        ),
      );
    } catch (e) {
      emit(
        ConsultationError(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
