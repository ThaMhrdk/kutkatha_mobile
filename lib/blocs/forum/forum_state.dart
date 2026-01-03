import 'package:equatable/equatable.dart';
import '../../models/forum_topic.dart';

/// States untuk ForumBloc
abstract class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object?> get props => [];
}

/// State awal
class ForumInitial extends ForumState {}

/// State saat loading list
class ForumLoading extends ForumState {}

/// State saat load more (pagination)
class ForumLoadingMore extends ForumState {
  final List<ForumTopic> currentTopics;

  const ForumLoadingMore({required this.currentTopics});

  @override
  List<Object?> get props => [currentTopics];
}

/// State saat berhasil load daftar topics
class ForumLoaded extends ForumState {
  final List<ForumTopic> topics;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasReachedMax;

  const ForumLoaded({
    required this.topics,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.hasReachedMax = false,
  });

  ForumLoaded copyWith({
    List<ForumTopic>? topics,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasReachedMax,
  }) {
    return ForumLoaded(
      topics: topics ?? this.topics,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
    topics,
    currentPage,
    lastPage,
    total,
    hasReachedMax,
  ];
}

/// State saat berhasil load detail topic
class ForumDetailLoaded extends ForumState {
  final ForumTopic topic;

  const ForumDetailLoaded({required this.topic});

  @override
  List<Object?> get props => [topic];
}

/// State saat berhasil create/update topic
class ForumOperationSuccess extends ForumState {
  final String message;
  final ForumTopic? topic;

  const ForumOperationSuccess({required this.message, this.topic});

  @override
  List<Object?> get props => [message, topic];
}

/// State saat terjadi error
class ForumError extends ForumState {
  final String message;

  const ForumError({required this.message});

  @override
  List<Object?> get props => [message];
}
