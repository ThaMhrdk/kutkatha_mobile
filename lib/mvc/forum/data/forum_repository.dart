import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';
import 'forum_model.dart';

/// Repository untuk Forum
class ForumRepository {
  final DioClient _dioClient;

  ForumRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  /// Get daftar topics
  Future<List<ForumTopic>> getTopics({String? category, int page = 1}) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (category != null) {
        queryParams['category'] = category;
      }

      final response = await _dioClient.get(
        '/forum/topics',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        // Handle both array and paginated response
        List<dynamic> topicsList;
        if (data is List) {
          topicsList = data;
        } else if (data is Map && data['data'] != null) {
          topicsList = data['data'] as List;
        } else {
          topicsList = [];
        }
        return topicsList.map((json) {
          try {
            return ForumTopic.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing ForumTopic: $e, json: $json');
            rethrow;
          }
        }).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil data');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Get detail topic
  Future<ForumTopic> getTopicDetail(int topicId) async {
    try {
      final response = await _dioClient.get('/forum/topics/$topicId');

      if (response.data['success'] == true) {
        return ForumTopic.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil detail');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Create topic baru
  Future<ForumTopic> createTopic({
    required String title,
    required String content,
    required String category,
    bool isAnonymous = false,
  }) async {
    try {
      final response = await _dioClient.post(
        '/forum/topics',
        data: {
          'title': title,
          'description': content, // Laravel expects 'description' not 'content'
          'category': category,
          'is_anonymous': isAnonymous,
        },
      );

      if (response.data['success'] == true) {
        return ForumTopic.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal membuat topik');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Update topic
  Future<ForumTopic> updateTopic(
    int topicId, {
    required String title,
    required String content,
    required String category,
  }) async {
    try {
      final response = await _dioClient.put(
        '/forum/topics/$topicId',
        data: {
          'title': title,
          'description': content, // Laravel expects 'description' not 'content'
          'category': category,
        },
      );

      if (response.data['success'] == true) {
        return ForumTopic.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal mengupdate topik');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Delete topic
  Future<void> deleteTopic(int topicId) async {
    try {
      final response = await _dioClient.delete('/forum/topics/$topicId');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal menghapus topik');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Get posts (komentar) dari topic
  Future<List<ForumPost>> getPosts(int topicId) async {
    try {
      final response = await _dioClient.get('/forum/topics/$topicId/posts');

      if (response.data['success'] == true) {
        final List<dynamic> postsList = response.data['data'] ?? [];
        return postsList.map((json) => ForumPost.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil komentar');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Create post (komentar)
  Future<ForumPost> createPost(
    int topicId, {
    required String content,
    bool isAnonymous = false,
  }) async {
    try {
      final response = await _dioClient.post(
        '/forum/topics/$topicId/posts',
        data: {'content': content, 'is_anonymous': isAnonymous},
      );

      if (response.data['success'] == true) {
        return ForumPost.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Gagal membuat komentar');
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }
}
