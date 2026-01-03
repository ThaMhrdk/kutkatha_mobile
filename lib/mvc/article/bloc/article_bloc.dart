import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/article_repository.dart';
import 'article_event.dart';
import 'article_state.dart';

/// BLoC untuk Article
class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final ArticleRepository _repository;

  ArticleBloc({ArticleRepository? repository})
    : _repository = repository ?? ArticleRepository(),
      super(ArticleInitial()) {
    on<ArticleLoadRequested>(_onLoadRequested);
    on<ArticleDetailRequested>(_onDetailRequested);
  }

  Future<void> _onLoadRequested(
    ArticleLoadRequested event,
    Emitter<ArticleState> emit,
  ) async {
    emit(ArticleLoading());
    try {
      final articles = await _repository.getArticles(
        category: event.category,
        search: event.search,
      );
      emit(ArticleLoaded(articles: articles));
    } catch (e) {
      emit(ArticleError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDetailRequested(
    ArticleDetailRequested event,
    Emitter<ArticleState> emit,
  ) async {
    emit(ArticleLoading());
    try {
      final article = await _repository.getArticleDetail(event.articleId);
      emit(ArticleDetailLoaded(article: article));
    } catch (e) {
      emit(ArticleError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
