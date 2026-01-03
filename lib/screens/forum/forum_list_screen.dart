import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/forum/forum_bloc.dart';
import '../../blocs/forum/forum_event.dart';
import '../../blocs/forum/forum_state.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/forum_topic.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/custom_widgets.dart';

/// Screen Daftar Forum (READ - List)
class ForumListScreen extends StatefulWidget {
  const ForumListScreen({super.key});

  @override
  State<ForumListScreen> createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> {
  final _scrollController = ScrollController();
  String? _selectedCategory;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadTopics();
    _scrollController.addListener(_onScroll);

    // Get current user ID
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadTopics({bool refresh = false}) {
    context.read<ForumBloc>().add(
      ForumLoadRequested(refresh: refresh, category: _selectedCategory),
    );
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ForumBloc>().state;
      if (state is ForumLoaded && !state.hasReachedMax) {
        context.read<ForumBloc>().add(
          ForumLoadRequested(
            page: state.currentPage + 1,
            category: _selectedCategory,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Diskusi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: BlocConsumer<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state is ForumOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadTopics(refresh: true);
          } else if (state is ForumError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ForumLoading) {
            return const LoadingWidget(message: 'Memuat forum...');
          }

          if (state is ForumError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () => _loadTopics(refresh: true),
            );
          }

          if (state is ForumLoaded) {
            if (state.topics.isEmpty) {
              return EmptyWidget(
                message: 'Belum ada postingan.\nJadilah yang pertama!',
                icon: Icons.forum_outlined,
                action: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forumCreate);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Post'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadTopics(refresh: true);
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.hasReachedMax
                    ? state.topics.length
                    : state.topics.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.topics.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final topic = state.topics[index];
                  return ForumCard(
                    title: topic.title,
                    category: topic.category,
                    description: topic.description,
                    author: topic.authorName,
                    viewsCount: topic.viewsCount,
                    postsCount: topic.postsCount,
                    createdAt: topic.createdAt,
                    isOwner: topic.userId == _currentUserId,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.forumDetail,
                        arguments: topic,
                      );
                    },
                    onEdit: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.forumEdit,
                        arguments: topic,
                      );
                    },
                    onDelete: () {
                      _showDeleteDialog(topic);
                    },
                  );
                },
              ),
            );
          }

          return const LoadingWidget();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.forumCreate);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                    Navigator.pop(context);
                    _loadTopics(refresh: true);
                  },
                ),
                ...ForumCategories.categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                      Navigator.pop(context);
                      _loadTopics(refresh: true);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(ForumTopic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Post'),
        content: Text('Apakah Anda yakin ingin menghapus "${topic.title}"?'),
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
