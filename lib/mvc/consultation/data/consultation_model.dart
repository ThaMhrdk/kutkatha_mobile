import 'package:equatable/equatable.dart';
import '../../booking/data/booking_model.dart';

/// Model untuk Consultation
class Consultation extends Equatable {
  final int id;
  final int bookingId;
  final String status;
  final String? notes;
  final String? summary;
  final String? diagnosis;
  final String? recommendation;
  final String? followUpNotes;
  final Booking? booking;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? nextSessionDate;
  final DateTime? createdAt;
  final bool hasFeedback;
  final ConsultationFeedback? feedback;

  const Consultation({
    required this.id,
    required this.bookingId,
    required this.status,
    this.notes,
    this.summary,
    this.diagnosis,
    this.recommendation,
    this.followUpNotes,
    this.booking,
    this.startedAt,
    this.endedAt,
    this.nextSessionDate,
    this.createdAt,
    this.hasFeedback = false,
    this.feedback,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    // Check if feedback exists
    final feedbackData = json['feedback'];
    final hasFeedback =
        feedbackData != null && feedbackData is Map && feedbackData.isNotEmpty;

    return Consultation(
      id: _parseInt(json['id']) ?? 0,
      bookingId: _parseInt(json['booking_id']) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
      summary: json['summary']?.toString(),
      diagnosis: json['diagnosis']?.toString(),
      recommendation: json['recommendation']?.toString(),
      followUpNotes: json['follow_up_notes']?.toString(),
      booking:
          json['booking'] != null && json['booking'] is Map<String, dynamic>
          ? Booking.fromJson(json['booking'])
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      nextSessionDate: json['next_session_date'] != null
          ? DateTime.tryParse(json['next_session_date'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      hasFeedback: hasFeedback,
      feedback: hasFeedback
          ? ConsultationFeedback.fromJson(feedbackData as Map<String, dynamic>)
          : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
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

  bool get canChat => status == 'in_progress';

  /// Check if user can give feedback (completed and no feedback yet)
  bool get canGiveFeedback => status == 'completed' && !hasFeedback;

  @override
  List<Object?> get props => [id, bookingId, status, hasFeedback];
}

/// Model untuk Feedback Konsultasi
class ConsultationFeedback extends Equatable {
  final int id;
  final int consultationId;
  final int rating;
  final String? comment;
  final bool isAnonymous;
  final DateTime? createdAt;

  const ConsultationFeedback({
    required this.id,
    required this.consultationId,
    required this.rating,
    this.comment,
    this.isAnonymous = false,
    this.createdAt,
  });

  factory ConsultationFeedback.fromJson(Map<String, dynamic> json) {
    return ConsultationFeedback(
      id: json['id'] ?? 0,
      consultationId: json['consultation_id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment']?.toString(),
      isAnonymous: json['is_anonymous'] == true || json['is_anonymous'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [id, consultationId, rating];
}

/// Model untuk Chat Message
class ChatMessage extends Equatable {
  final int id;
  final int consultationId;
  final int senderId;
  final String? senderName;
  final String? senderPhoto;
  final String message;
  final String? attachment;
  final bool isRead;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.consultationId,
    required this.senderId,
    this.senderName,
    this.senderPhoto,
    required this.message,
    this.attachment,
    this.isRead = false,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    String? senderName;
    String? senderPhoto;

    if (json['sender'] != null && json['sender'] is Map) {
      senderName = json['sender']['name']?.toString();
      senderPhoto = json['sender']['photo']?.toString();
    }

    return ChatMessage(
      id: _parseInt(json['id']) ?? 0,
      consultationId: _parseInt(json['consultation_id']) ?? 0,
      senderId: _parseInt(json['sender_id']) ?? 0,
      senderName: senderName,
      senderPhoto: senderPhoto,
      message: json['message']?.toString() ?? '',
      attachment: json['attachment']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get formattedTime {
    if (createdAt == null) return '';
    return '${createdAt!.hour.toString().padLeft(2, '0')}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [id, consultationId, senderId, message];
}
