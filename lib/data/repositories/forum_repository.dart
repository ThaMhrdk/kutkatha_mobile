import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../models/forum_topic.dart';
import '../providers/api_provider.dart';

/// Repository untuk mengelola Forum (CRUD Posts/Topics)
class ForumRepository {
  final ApiProvider _apiProvider;

  ForumRepository({ApiProvider? apiProvider})
    : _apiProvider = apiProvider ?? ApiProvider();

  /// Get daftar forum topics dengan pagination
  Future<ForumResponse> getTopics({
    int page = 1,
    int perPage = 15,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiProvider.get(
        ApiConfig.forumTopics,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final topics = dataList
            .map((json) => ForumTopic.fromJson(json))
            .toList();

        final meta = response.data['meta'];
        return ForumResponse(
          topics: topics,
          currentPage: meta?['current_page'] ?? 1,
          lastPage: meta?['last_page'] ?? 1,
          total: meta?['total'] ?? 0,
        );
      } else {
        throw Exception(
          response.data['message'] ?? 'Gagal mengambil data forum',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Get detail topic by ID
  Future<ForumTopic> getTopicDetail(int topicId) async {
    try {
      final response = await _apiProvider.get(
        '${ApiConfig.forumTopics}/$topicId',
      );

      if (response.data['success'] == true) {
        return ForumTopic.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Gagal mengambil detail topic',
        );
      }
    } on DioException catch (e) {
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Create topic baru (CREATE)
  Future<ForumTopic> createTopic({
    required String title,
    required String category,
    required String description,
    bool isAnonymous = false,
  }) async {
    try {
      final response = await _apiProvider.post(
        ApiConfig.forumTopics,
        data: {
          'title': title,
          'category': category,
          'description': description,
          'is_anonymous': isAnonymous,
        },
      );

      if (response.data['success'] == true) {
        return ForumTopic.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal membuat topic');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Update topic (UPDATE)
  Future<ForumTopic> updateTopic({
    required int topicId,
    required String title,
    required String category,
    required String description,
    bool isAnonymous = false,
  }) async {
    try {
      final response = await _apiProvider.put(
        '${ApiConfig.forumTopics}/$topicId',
        data: {
          'title': title,
          'category': category,
          'description': description,
          'is_anonymous': isAnonymous,
        },
      );

      if (response.data['success'] == true) {
        return ForumTopic.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengupdate topic');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception(ApiProvider.handleError(e));
    }
  }

  /// Delete topic (DELETE)
  Future<void> deleteTopic(int topicId) async {
    try {
      final response = await _apiProvider.delete(
        '${ApiConfig.forumTopics}/$topicId',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal menghapus topic');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception(ApiProvider.handleError(e));
    }
  }
}

/// Response wrapper untuk forum dengan pagination
class ForumResponse {
  final List<ForumTopic> topics;
  final int currentPage;
  final int lastPage;
  final int total;

  ForumResponse({
    required this.topics,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasNextPage => currentPage < lastPage;
}
