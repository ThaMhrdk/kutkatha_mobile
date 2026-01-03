import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/dio_client.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';
import '../data/article_model.dart';
import '../../_shared/widgets/common_widgets.dart';

/// Halaman Detail Artikel
class ArticleDetailPage extends StatefulWidget {
  final int articleId;

  const ArticleDetailPage({super.key, required this.articleId});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ArticleBloc>().add(
      ArticleDetailRequested(articleId: widget.articleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state is ArticleLoading) {
            return const Scaffold(
              appBar: null,
              body: LoadingWidget(message: 'Memuat artikel...'),
            );
          }

          if (state is ArticleError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Artikel')),
              body: ErrorDisplayWidget(
                message: state.message,
                onRetry: () {
                  context.read<ArticleBloc>().add(
                    ArticleDetailRequested(articleId: widget.articleId),
                  );
                },
              ),
            );
          }

          if (state is ArticleDetailLoaded) {
            final article = state.article;

            return CustomScrollView(
              slivers: [
                // App Bar with Image
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        article.featuredImage != null &&
                            article.featuredImage!.isNotEmpty
                        ? Image.network(
                            '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${article.featuredImage}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Icon(
                                    Icons.article,
                                    size: 64,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                          )
                        : Container(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.article,
                              size: 64,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                  ),
                ),
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
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
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Author & Meta
                        Row(
                          children: [
                            _buildAuthorAvatar(article),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    article.formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.visibility,
                                  size: 16,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${article.viewsCount} views',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        // Content
                        Text(
                          article.content,
                          style: const TextStyle(fontSize: 16, height: 1.8),
                        ),
                        const SizedBox(height: 32),
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

  Widget _buildAuthorAvatar(Article article) {
    final author = article.author;
    if (author?.photo != null && author!.photo!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(
          '${DioClient.baseUrl.replaceAll('/api', '')}/storage/${author.photo}',
        ),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: AppTheme.primaryColor,
      child: Text(
        article.authorName[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
