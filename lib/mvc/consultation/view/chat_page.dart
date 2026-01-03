import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/dio_client.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../booking/data/booking_model.dart';
import '../bloc/consultation_bloc.dart';
import '../bloc/consultation_event.dart';
import '../bloc/consultation_state.dart';
import '../data/consultation_model.dart';
import '../../psikolog/data/psikolog_model.dart';

/// Halaman Chat Konsultasi - Bisa dari Consultation atau Booking
class ChatPage extends StatefulWidget {
  final Consultation? consultation;
  final Booking? booking;

  const ChatPage({super.key, this.consultation, this.booking})
    : assert(
        consultation != null || booking != null,
        'Either consultation or booking must be provided',
      );

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollingTimer;
  int? _currentUserId;
  Psikolog? _psikolog;
  int? _bookingId;
  bool _useBookingMode = false;
  bool _hasShownCompletedDialog = false;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    }

    // Determine which mode to use
    if (widget.booking != null) {
      _useBookingMode = true;
      _bookingId = widget.booking!.id;
      _psikolog = widget.booking!.schedule?.psikolog;
    } else if (widget.consultation != null) {
      _bookingId = widget.consultation!.bookingId;
      _psikolog = widget.consultation!.booking?.schedule?.psikolog;
      // Use booking mode if consultation ID is 0 or invalid
      _useBookingMode = widget.consultation!.id <= 0;
    }

    _loadMessages();
    _startPolling();
  }

  void _loadMessages() {
    if (_useBookingMode && _bookingId != null) {
      final state = context.read<ConsultationBloc>().state;
      int? afterId;
      if (state is ChatLoaded) {
        afterId = state.lastMessageId;
      }
      context.read<ConsultationBloc>().add(
        ChatByBookingLoadRequested(bookingId: _bookingId!, afterId: afterId),
      );
    } else if (widget.consultation != null && widget.consultation!.id > 0) {
      context.read<ConsultationBloc>().add(
        ChatLoadRequested(consultationId: widget.consultation!.id),
      );
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final state = context.read<ConsultationBloc>().state;
      if (state is ChatLoaded) {
        if (_useBookingMode && _bookingId != null) {
          context.read<ConsultationBloc>().add(
            ChatByBookingLoadRequested(
              bookingId: _bookingId!,
              afterId: state.lastMessageId,
            ),
          );
        } else if (widget.consultation != null && widget.consultation!.id > 0) {
          context.read<ConsultationBloc>().add(
            ChatLoadRequested(
              consultationId: widget.consultation!.id,
              afterId: state.lastMessageId,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    if (_useBookingMode && _bookingId != null) {
      // Send by booking ID
      context.read<ConsultationBloc>().add(
        ChatByBookingSendRequested(bookingId: _bookingId!, message: message),
      );
    } else if (widget.consultation != null && widget.consultation!.id > 0) {
      // Send by consultation ID
      context.read<ConsultationBloc>().add(
        ChatSendRequested(
          consultationId: widget.consultation!.id,
          message: message,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mengirim pesan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _messageController.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showConsultationCompletedDialog(Consultation consultation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Konsultasi Selesai', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Psikolog ${_psikolog?.name ?? ""} telah mengakhiri sesi konsultasi.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (consultation.summary != null &&
                consultation.summary!.isNotEmpty) ...[
              const Text(
                'Ringkasan:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  consultation.summary!,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Anda dapat memberikan feedback untuk konsultasi ini.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from chat
            },
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from chat
              // Navigate to consultation list to give feedback
            },
            child: const Text('Lihat Hasil'),
          ),
        ],
      ),
    );
  }

  Widget _buildPsikologAvatar({double radius = 18}) {
    final photoUrl = _psikolog?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/$photoUrl',
        ),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: Text(
        _psikolog?.name[0].toUpperCase() ?? 'P',
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _buildPsikologAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _psikolog?.name ?? 'Psikolog',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    _psikolog?.specialization ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: BlocConsumer<ConsultationBloc, ConsultationState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  // Check if consultation is completed
                  if (state.consultation?.status == 'completed' &&
                      !_hasShownCompletedDialog) {
                    _hasShownCompletedDialog = true;
                    _pollingTimer?.cancel(); // Stop polling
                    _showConsultationCompletedDialog(state.consultation!);
                  }
                }
                if (state is ConsultationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ConsultationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<ChatMessage> messages = [];

                if (state is ChatLoaded) {
                  messages = state.messages;
                } else if (state is ChatSending) {
                  messages = state.currentMessages;
                }

                if (messages.isEmpty && state is! ConsultationLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Mulai percakapan dengan psikolog',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;
                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                      psikolog: _psikolog,
                    );
                  },
                );
              },
            ),
          ),
          // Input Area - Selalu tampilkan untuk chat
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<ConsultationBloc, ConsultationState>(
                    builder: (context, state) {
                      return IconButton(
                        onPressed: state is ChatSending ? null : _sendMessage,
                        icon: state is ChatSending
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final Psikolog? psikolog;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.psikolog,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar psikolog (kiri)
          if (!isMe) ...[_buildPsikologAvatar(), const SizedBox(width: 8)],
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama pengirim untuk psikolog
                  if (!isMe && psikolog != null) ...[
                    Text(
                      psikolog!.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Spacer untuk user message
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPsikologAvatar() {
    final photoUrl = psikolog?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/$photoUrl',
        ),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppTheme.secondaryColor,
      child: Text(
        psikolog?.name[0].toUpperCase() ?? 'P',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
