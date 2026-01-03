import 'package:equatable/equatable.dart';
import '../data/article_model.dart';

/// States untuk ArticleBloc
abstract class ArticleState extends Equatable {
  const ArticleState();

  @override
  List<Object?> get props => [];
}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;

  const ArticleLoaded({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class ArticleDetailLoaded extends ArticleState {
  final Article article;

  const ArticleDetailLoaded({required this.article});

  @override
  List<Object?> get props => [article];
}

class ArticleError extends ArticleState {
  final String message;

  const ArticleError({required this.message});

  @override
  List<Object?> get props => [message];
}
