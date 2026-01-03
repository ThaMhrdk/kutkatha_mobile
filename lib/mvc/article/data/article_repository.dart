import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';
import 'article_model.dart';

/// Repository untuk Article
class ArticleRepository {
  final DioClient _dioClient;

  ArticleRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  /// Get daftar artikel
  Future<List<Article>> getArticles({String? category, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) {
        queryParams['category'] = category;
      }
      if (search != null) {
        queryParams['search'] = search;
      }

      final response = await _dioClient.get(
        '/articles',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        // Handle both array and paginated response
        List<dynamic> dataList;
        if (data is List) {
          dataList = data;
        } else if (data is Map && data['data'] != null) {
          dataList = data['data'] as List;
        } else {
          dataList = [];
        }
        return dataList.map((json) {
          try {
            return Article.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing Article: $e, json: $json');
            rethrow;
          }
        }).toList();
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil data artikel',
      );
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }

  /// Get detail artikel
  Future<Article> getArticleDetail(int articleId) async {
    try {
      final response = await _dioClient.get('/articles/$articleId');

      if (response.data['success'] == true) {
        return Article.fromJson(response.data['data']);
      }
      throw Exception(
        response.data['message'] ?? 'Gagal mengambil detail artikel',
      );
    } on DioException catch (e) {
      throw Exception(DioClient.handleError(e));
    }
  }
}
