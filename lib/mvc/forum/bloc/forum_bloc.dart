import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/forum_repository.dart';
import '../data/forum_model.dart';
import 'forum_event.dart';
import 'forum_state.dart';

/// BLoC untuk Forum
class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final ForumRepository _repository;

  ForumBloc({ForumRepository? repository})
    : _repository = repository ?? ForumRepository(),
      super(ForumInitial()) {
    on<ForumLoadRequested>(_onLoadRequested);
    on<ForumDetailRequested>(_onDetailRequested);
    on<ForumCreateRequested>(_onCreateRequested);
    on<ForumUpdateRequested>(_onUpdateRequested);
    on<ForumDeleteRequested>(_onDeleteRequested);
    on<ForumPostsLoadRequested>(_onPostsLoadRequested);
    on<ForumPostCreateRequested>(_onPostCreateRequested);
  }

  Future<void> _onLoadRequested(
    ForumLoadRequested event,
    Emitter<ForumState> emit,
  ) async {
    if (event.refresh) {
      emit(ForumLoading());
    }

    try {
      final topics = await _repository.getTopics(
        category: event.category,
        page: 1,
      );
      emit(ForumLoaded(topics: topics, currentPage: 1));
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDetailRequested(
    ForumDetailRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      final topic = await _repository.getTopicDetail(event.topicId);
      final posts = await _repository.getPosts(event.topicId);
      emit(ForumDetailLoaded(topic: topic, posts: posts));
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateRequested(
    ForumCreateRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      await _repository.createTopic(
        title: event.title,
        content: event.content,
        category: event.category,
        isAnonymous: event.isAnonymous,
      );
      emit(const ForumOperationSuccess(message: 'Topik berhasil dibuat'));
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateRequested(
    ForumUpdateRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      await _repository.updateTopic(
        event.topicId,
        title: event.title,
        content: event.content,
        category: event.category,
      );
      emit(const ForumOperationSuccess(message: 'Topik berhasil diupdate'));
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteRequested(
    ForumDeleteRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      await _repository.deleteTopic(event.topicId);
      emit(const ForumOperationSuccess(message: 'Topik berhasil dihapus'));
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onPostsLoadRequested(
    ForumPostsLoadRequested event,
    Emitter<ForumState> emit,
  ) async {
    final currentState = state;
    if (currentState is ForumDetailLoaded) {
      try {
        final posts = await _repository.getPosts(event.topicId);
        emit(ForumDetailLoaded(topic: currentState.topic, posts: posts));
      } catch (e) {
        emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> _onPostCreateRequested(
    ForumPostCreateRequested event,
    Emitter<ForumState> emit,
  ) async {
    final currentState = state;
    if (currentState is ForumDetailLoaded) {
      try {
        final newPost = await _repository.createPost(
          event.topicId,
          content: event.content,
          isAnonymous: event.isAnonymous,
        );
        final updatedPosts = [...currentState.posts, newPost];
        emit(ForumDetailLoaded(topic: currentState.topic, posts: updatedPosts));
      } catch (e) {
        emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }
}
