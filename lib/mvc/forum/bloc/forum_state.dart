import 'package:equatable/equatable.dart';
import '../data/forum_model.dart';

/// States untuk ForumBloc
abstract class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {}

class ForumLoading extends ForumState {}

class ForumLoaded extends ForumState {
  final List<ForumTopic> topics;
  final bool hasMore;
  final int currentPage;

  const ForumLoaded({
    required this.topics,
    this.hasMore = true,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [topics, hasMore, currentPage];
}

class ForumDetailLoaded extends ForumState {
  final ForumTopic topic;
  final List<ForumPost> posts;

  const ForumDetailLoaded({required this.topic, this.posts = const []});

  @override
  List<Object?> get props => [topic, posts];
}

class ForumOperationSuccess extends ForumState {
  final String message;

  const ForumOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForumError extends ForumState {
  final String message;

  const ForumError({required this.message});

  @override
  List<Object?> get props => [message];
}
