import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_router.dart';
import '../../../core/dio_client.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';
import '../data/forum_model.dart';
import '../../_shared/widgets/common_widgets.dart';

/// Halaman Daftar Forum
class ForumListPage extends StatefulWidget {
  const ForumListPage({super.key});

  @override
  State<ForumListPage> createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {
  String? _selectedCategory;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadTopics();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    }
  }

  void _loadTopics({bool refresh = false}) {
    context.read<ForumBloc>().add(
      ForumLoadRequested(refresh: refresh, category: _selectedCategory),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Diskusi'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
              _loadTopics(refresh: true);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Semua Kategori')),
              ...ForumCategory.categories.map(
                (cat) => PopupMenuItem(value: cat, child: Text(cat)),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ForumBloc, ForumState>(
        builder: (context, state) {
          if (state is ForumLoading) {
            return const LoadingWidget(message: 'Memuat forum...');
          }

          if (state is ForumError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () => _loadTopics(refresh: true),
            );
          }

          if (state is ForumLoaded) {
            if (state.topics.isEmpty) {
              return const EmptyWidget(
                message: 'Belum ada diskusi',
                icon: Icons.forum,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadTopics(refresh: true);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.topics.length,
                itemBuilder: (context, index) {
                  final topic = state.topics[index];
                  return _TopicCard(
                    topic: topic,
                    isOwner: topic.userId == _currentUserId,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.forumDetail,
                        arguments: topic,
                      ).then((_) {
                        // Refresh list saat kembali dari detail
                        _loadTopics(refresh: true);
                      });
                    },
                    onEdit: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.forumEdit,
                        arguments: topic,
                      ).then((_) {
                        _loadTopics(refresh: true);
                      });
                    },
                    onDelete: () => _showDeleteDialog(topic),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.forumCreate).then((_) {
            _loadTopics(refresh: true);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(ForumTopic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Topik'),
        content: const Text('Apakah Anda yakin ingin menghapus topik ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ForumBloc>().add(
                ForumDeleteRequested(topicId: topic.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final ForumTopic topic;
  final bool isOwner;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TopicCard({
    required this.topic,
    required this.isOwner,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                      topic.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isOwner)
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Hapus'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                topic.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                topic.content,
                style: TextStyle(color: Colors.grey[600], height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildUserAvatar(topic),
                  const SizedBox(width: 8),
                  Text(
                    topic.authorName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    topic.timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${topic.postsCount ?? 0}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(ForumTopic topic) {
    if (topic.isAnonymous) {
      return CircleAvatar(
        radius: 12,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, size: 14, color: Colors.grey),
      );
    }

    final user = topic.user;
    if (user?.photo != null && user!.photo!.isNotEmpty) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: NetworkImage(
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${user.photo}',
        ),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 12,
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      child: Text(
        topic.authorName[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
