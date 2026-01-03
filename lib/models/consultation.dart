import 'package:equatable/equatable.dart';
import 'booking.dart';
import 'user.dart';

/// Model untuk Consultation
class Consultation extends Equatable {
  final int id;
  final int bookingId;
  final String status; // pending, in_progress, completed
  final String? notes;
  final String? diagnosis;
  final String? recommendation;
  final Booking? booking;
  final List<ChatMessage>? chatMessages;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const Consultation({
    required this.id,
    required this.bookingId,
    required this.status,
    this.notes,
    this.diagnosis,
    this.recommendation,
    this.booking,
    this.chatMessages,
    this.startedAt,
    this.completedAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      diagnosis: json['diagnosis'],
      recommendation: json['recommendation'],
      booking: json['booking'] != null
          ? Booking.fromJson(json['booking'])
          : null,
      chatMessages: json['chat_messages'] != null
          ? (json['chat_messages'] as List)
                .map((e) => ChatMessage.fromJson(e))
                .toList()
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Berlangsung';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  bool get canChat => status == 'in_progress' || status == 'pending';

  @override
  List<Object?> get props => [id, bookingId, status];
}

/// Model untuk Chat Message
class ChatMessage extends Equatable {
  final int id;
  final int consultationId;
  final int senderId;
  final String message;
  final String? attachment;
  final bool isRead;
  final User? sender;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.consultationId,
    required this.senderId,
    required this.message,
    this.attachment,
    this.isRead = false,
    this.sender,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      consultationId: json['consultation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      message: json['message'] ?? '',
      attachment: json['attachment'],
      isRead: json['is_read'] ?? false,
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  @override
  List<Object?> get props => [id, consultationId, senderId, message];
}
