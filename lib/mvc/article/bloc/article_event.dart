import 'package:equatable/equatable.dart';

/// Events untuk ArticleBloc
abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object?> get props => [];
}

/// Load daftar artikel
class ArticleLoadRequested extends ArticleEvent {
  final String? category;
  final String? search;

  const ArticleLoadRequested({this.category, this.search});

  @override
  List<Object?> get props => [category, search];
}

/// Load detail artikel
class ArticleDetailRequested extends ArticleEvent {
  final int articleId;

  const ArticleDetailRequested({required this.articleId});

  @override
  List<Object?> get props => [articleId];
}
