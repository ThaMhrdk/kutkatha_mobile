import 'package:equatable/equatable.dart';
import 'user.dart';

/// Model untuk Forum Topic (Posts)
class ForumTopic extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String? slug;
  final String category;
  final String description;
  final bool isAnonymous;
  final bool isPinned;
  final bool isClosed;
  final int viewsCount;
  final int postsCount;
  final User? user;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ForumTopic({
    required this.id,
    required this.userId,
    required this.title,
    this.slug,
    required this.category,
    required this.description,
    this.isAnonymous = false,
    this.isPinned = false,
    this.isClosed = false,
    this.viewsCount = 0,
    this.postsCount = 0,
    this.user,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor dari JSON
  factory ForumTopic.fromJson(Map<String, dynamic> json) {
    return ForumTopic(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'],
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      isAnonymous: json['is_anonymous'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      isClosed: json['is_closed'] ?? false,
      viewsCount: json['views_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Konversi ke JSON untuk create/update
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'is_anonymous': isAnonymous,
    };
  }

  /// Copy with untuk update partial
  ForumTopic copyWith({
    int? id,
    int? userId,
    String? title,
    String? slug,
    String? category,
    String? description,
    bool? isAnonymous,
    bool? isPinned,
    bool? isClosed,
    int? viewsCount,
    int? postsCount,
    User? user,
  }) {
    return ForumTopic(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      category: category ?? this.category,
      description: description ?? this.description,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPinned: isPinned ?? this.isPinned,
      isClosed: isClosed ?? this.isClosed,
      viewsCount: viewsCount ?? this.viewsCount,
      postsCount: postsCount ?? this.postsCount,
      user: user ?? this.user,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Mendapatkan nama author (atau 'Anonim' jika anonymous)
  String get authorName {
    if (isAnonymous) return 'Anonim';
    return user?.name ?? 'Unknown';
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    slug,
    category,
    description,
    isAnonymous,
    isPinned,
    isClosed,
    viewsCount,
    postsCount,
  ];
}

/// Daftar kategori forum yang tersedia
class ForumCategories {
  static const List<String> categories = [
    'Kecemasan',
    'Depresi',
    'Stress',
    'Hubungan',
    'Karir',
    'Keluarga',
    'Tips & Motivasi',
    'Lainnya',
  ];
}
