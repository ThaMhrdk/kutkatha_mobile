import 'package:equatable/equatable.dart';

/// Events untuk ForumBloc
abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

/// Load daftar topics
class ForumLoadRequested extends ForumEvent {
  final bool refresh;
  final String? category;

  const ForumLoadRequested({this.refresh = false, this.category});

  @override
  List<Object?> get props => [refresh, category];
}

/// Load detail topic
class ForumDetailRequested extends ForumEvent {
  final int topicId;

  const ForumDetailRequested({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

/// Create topic baru
class ForumCreateRequested extends ForumEvent {
  final String title;
  final String content;
  final String category;
  final bool isAnonymous;

  const ForumCreateRequested({
    required this.title,
    required this.content,
    required this.category,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [title, content, category, isAnonymous];
}

/// Update topic
class ForumUpdateRequested extends ForumEvent {
  final int topicId;
  final String title;
  final String content;
  final String category;

  const ForumUpdateRequested({
    required this.topicId,
    required this.title,
    required this.content,
    required this.category,
  });

  @override
  List<Object?> get props => [topicId, title, content, category];
}

/// Delete topic
class ForumDeleteRequested extends ForumEvent {
  final int topicId;

  const ForumDeleteRequested({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

/// Load posts (komentar)
class ForumPostsLoadRequested extends ForumEvent {
  final int topicId;

  const ForumPostsLoadRequested({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

/// Create post (komentar)
class ForumPostCreateRequested extends ForumEvent {
  final int topicId;
  final String content;
  final bool isAnonymous;

  const ForumPostCreateRequested({
    required this.topicId,
    required this.content,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [topicId, content, isAnonymous];
}
