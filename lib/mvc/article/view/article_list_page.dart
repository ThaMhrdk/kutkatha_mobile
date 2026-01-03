import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_router.dart';
import '../../../core/dio_client.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';
import '../data/article_model.dart';
import '../../_shared/widgets/common_widgets.dart';

/// Halaman Daftar Artikel
class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadArticles({String? search}) {
    context.read<ArticleBloc>().add(ArticleLoadRequested(search: search));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari artikel...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadArticles();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (value) {
                _loadArticles(search: value.isNotEmpty ? value : null);
              },
            ),
          ),
          // Article List
          Expanded(
            child: BlocBuilder<ArticleBloc, ArticleState>(
              builder: (context, state) {
                if (state is ArticleLoading) {
                  return const LoadingWidget(message: 'Memuat artikel...');
                }

                if (state is ArticleError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: () => _loadArticles(),
                  );
                }

                if (state is ArticleLoaded) {
                  if (state.articles.isEmpty) {
                    return const EmptyWidget(
                      message: 'Belum ada artikel',
                      icon: Icons.article_outlined,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadArticles(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.articles.length,
                      itemBuilder: (context, index) {
                        final article = state.articles[index];
                        return _ArticleCard(
                          article: article,
                          onReturn: () => _loadArticles(),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onReturn;

  const _ArticleCard({required this.article, this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.articleDetail,
            arguments: article.id,
          ).then((_) {
            if (onReturn != null) onReturn!();
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Image
            if (article.featuredImage != null &&
                article.featuredImage!.isNotEmpty)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: DecorationImage(
                    image: NetworkImage(
                      '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${article.featuredImage}',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 100,
                width: double.infinity,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.article,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
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
                      article.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Excerpt
                  if (article.excerpt != null)
                    Text(
                      article.excerpt!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  // Meta
                  Row(
                    children: [
                      _buildAuthorAvatar(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          article.authorName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${article.viewsCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorAvatar() {
    final author = article.author;
    if (author?.photo != null && author!.photo!.isNotEmpty) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: NetworkImage(
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${author.photo}',
        ),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 12,
      backgroundColor: Colors.purple.withValues(alpha: 0.2),
      child: Text(
        article.authorName[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }
}
