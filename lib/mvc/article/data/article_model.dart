import 'package:equatable/equatable.dart';
import '../../auth/data/user_model.dart';

/// Model untuk Article
class Article extends Equatable {
  final int id;
  final int authorId;
  final String title;
  final String? slug;
  final String? excerpt;
  final String content;
  final String? featuredImage;
  final String category;
  final String status;
  final int viewsCount;
  final User? author;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  const Article({
    required this.id,
    required this.authorId,
    required this.title,
    this.slug,
    this.excerpt,
    required this.content,
    this.featuredImage,
    required this.category,
    required this.status,
    this.viewsCount = 0,
    this.author,
    this.publishedAt,
    this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    User? author;
    if (json['author'] != null && json['author'] is Map<String, dynamic>) {
      try {
        author = User.fromJson(json['author']);
      } catch (e) {
        print('Error parsing author in Article: $e');
      }
    }

    return Article(
      id: _parseInt(json['id']) ?? 0,
      authorId: _parseInt(json['author_id']) ?? 0,
      title: _parseString(json['title']) ?? '',
      slug: _parseString(json['slug']),
      excerpt: _parseString(json['excerpt']),
      content: _parseString(json['content']) ?? '',
      featuredImage: _parseString(json['featured_image']),
      category: _parseString(json['category']) ?? '',
      status: _parseString(json['status']) ?? 'draft',
      viewsCount: _parseInt(json['views_count']) ?? 0,
      author: author,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'].toString())
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
    if (value is double) return value.toInt();
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  String get formattedDate {
    if (publishedAt == null) return '';
    return '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}';
  }

  String get authorName => author?.name ?? 'Anonim';

  @override
  List<Object?> get props => [id, authorId, title, status];
}
