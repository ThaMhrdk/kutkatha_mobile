import 'package:equatable/equatable.dart';
import '../../auth/data/user_model.dart';

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
      id: _parseInt(json['id']) ?? 0,
      consultationId: _parseInt(json['consultation_id']) ?? 0,
      senderId: _parseInt(json['sender_id']) ?? 0,
      message: json['message']?.toString() ?? '',
      attachment: json['attachment']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      sender: json['sender'] != null && json['sender'] is Map<String, dynamic>
          ? User.fromJson(json['sender'])
          : null,
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
