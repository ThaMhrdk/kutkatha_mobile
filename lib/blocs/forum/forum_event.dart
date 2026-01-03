import 'package:equatable/equatable.dart';
import '../../models/forum_topic.dart';

/// Events untuk ForumBloc
abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk load daftar topics
class ForumLoadRequested extends ForumEvent {
  final int page;
  final String? category;
  final String? search;
  final bool refresh;

  const ForumLoadRequested({
    this.page = 1,
    this.category,
    this.search,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, category, search, refresh];
}

/// Event untuk load detail topic
class ForumDetailRequested extends ForumEvent {
  final int topicId;

  const ForumDetailRequested({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

/// Event untuk create topic baru
class ForumCreateRequested extends ForumEvent {
  final String title;
  final String category;
  final String description;
  final bool isAnonymous;

  const ForumCreateRequested({
    required this.title,
    required this.category,
    required this.description,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [title, category, description, isAnonymous];
}

/// Event untuk update topic
class ForumUpdateRequested extends ForumEvent {
  final int topicId;
  final String title;
  final String category;
  final String description;
  final bool isAnonymous;

  const ForumUpdateRequested({
    required this.topicId,
    required this.title,
    required this.category,
    required this.description,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [
    topicId,
    title,
    category,
    description,
    isAnonymous,
  ];
}

/// Event untuk delete topic
class ForumDeleteRequested extends ForumEvent {
  final int topicId;

  const ForumDeleteRequested({required this.topicId});

  @override
  List<Object?> get props => [topicId];
}

/// Event untuk reset state (clear selected topic)
class ForumResetDetail extends ForumEvent {}
