import 'package:equatable/equatable.dart';
import '../../auth/data/user_model.dart';

/// Model untuk Forum Topic
class ForumTopic extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String category;
  final bool isAnonymous;
  final int viewCount;
  final User? user;
  final int? postsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ForumTopic({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    this.isAnonymous = false,
    this.viewCount = 0,
    this.user,
    this.postsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory ForumTopic.fromJson(Map<String, dynamic> json) {
    User? user;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      try {
        user = User.fromJson(json['user']);
      } catch (e) {
        print('Error parsing user in ForumTopic: $e');
      }
    }

    return ForumTopic(
      id: _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']) ?? 0,
      title: _parseString(json['title']) ?? '',
      content:
          _parseString(json['description']) ??
          _parseString(json['content']) ??
          '', // Laravel uses 'description'
      category: _parseString(json['category']) ?? '',
      isAnonymous: json['is_anonymous'] == true || json['is_anonymous'] == 1,
      viewCount:
          _parseInt(json['views_count']) ?? _parseInt(json['view_count']) ?? 0,
      user: user,
      postsCount: _parseInt(json['posts_count']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'is_anonymous': isAnonymous,
    };
  }

  String get authorName {
    if (isAnonymous) return 'Anonim';
    return user?.name ?? 'Unknown';
  }

  String get timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
    return 'Baru saja';
  }

  @override
  List<Object?> get props => [id, userId, title, content, category];
}

/// Model untuk Forum Post (Komentar)
class ForumPost extends Equatable {
  final int id;
  final int topicId;
  final int userId;
  final String content;
  final bool isAnonymous;
  final User? user;
  final DateTime? createdAt;

  const ForumPost({
    required this.id,
    required this.topicId,
    required this.userId,
    required this.content,
    this.isAnonymous = false,
    this.user,
    this.createdAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    User? user;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      try {
        user = User.fromJson(json['user']);
      } catch (e) {
        print('Error parsing user in ForumPost: $e');
      }
    }

    return ForumPost(
      id: _parseIntForPost(json['id']) ?? 0,
      topicId: _parseIntForPost(json['topic_id']) ?? 0,
      userId: _parseIntForPost(json['user_id']) ?? 0,
      content: json['content']?.toString() ?? '',
      isAnonymous: json['is_anonymous'] == true || json['is_anonymous'] == 1,
      user: user,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static int? _parseIntForPost(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  String get authorName {
    if (isAnonymous) return 'Anonim';
    return user?.name ?? 'Unknown';
  }

  @override
  List<Object?> get props => [id, topicId, userId, content];
}

/// Kategori forum
class ForumCategory {
  static const List<String> categories = [
    'Umum',
    'Kecemasan',
    'Depresi',
    'Stress',
    'Hubungan',
    'Keluarga',
    'Pekerjaan',
    'Lainnya',
  ];
}
