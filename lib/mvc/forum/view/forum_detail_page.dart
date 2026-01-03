import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/dio_client.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';
import '../data/forum_model.dart';
import '../../_shared/widgets/common_widgets.dart';

/// Halaman Detail Forum
class ForumDetailPage extends StatefulWidget {
  final ForumTopic topic;

  const ForumDetailPage({super.key, required this.topic});

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final _commentController = TextEditingController();
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    context.read<ForumBloc>().add(
      ForumDetailRequested(topicId: widget.topic.id),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final content = _commentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (content.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar minimal 10 karakter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<ForumBloc>().add(
      ForumPostCreateRequested(
        topicId: widget.topic.id,
        content: content,
        isAnonymous: _isAnonymous,
      ),
    );
    _commentController.clear();
    setState(() {
      _isAnonymous = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diskusi')),
      body: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          if (state is ForumLoading) {
            return const LoadingWidget();
          }

          if (state is ForumError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                context.read<ForumBloc>().add(
                  ForumDetailRequested(topicId: widget.topic.id),
                );
              },
            );
          }

          if (state is ForumDetailLoaded) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Topic Content
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            state.topic.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.topic.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              child: Text(
                                state.topic.authorName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.topic.authorName,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Spacer(),
                            Text(
                              state.topic.timeAgo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          state.topic.content,
                          style: const TextStyle(fontSize: 15, height: 1.6),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Komentar (${state.posts.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (state.posts.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Belum ada komentar',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                          )
                        else
                          ...state.posts.map(
                            (post) => _CommentCard(post: post),
                          ),
                      ],
                    ),
                  ),
                ),
                // Comment Input
                Container(
                  padding: const EdgeInsets.all(12),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _isAnonymous,
                              onChanged: (value) {
                                setState(() {
                                  _isAnonymous = value ?? false;
                                });
                              },
                            ),
                            const Text('Kirim sebagai anonim'),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Tulis komentar...',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _submitComment,
                              icon: const Icon(Icons.send),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final ForumPost post;

  const _CommentCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCommentAvatar(),
              const SizedBox(width: 8),
              Text(
                post.authorName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                _formatDate(post.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(post.content, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCommentAvatar() {
    if (post.isAnonymous) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, size: 16, color: Colors.grey),
      );
    }

    final user = post.user;
    if (user?.photo != null && user!.photo!.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${user.photo}',
        ),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 14,
      backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.3),
      child: Text(
        post.authorName[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}h lalu';
    if (diff.inHours > 0) return '${diff.inHours}j lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m lalu';
    return 'Baru saja';
  }
}
