import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/forum_repository.dart';
import 'forum_event.dart';
import 'forum_state.dart';

/// BLoC untuk mengelola state Forum (CRUD Posts)
class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final ForumRepository _forumRepository;

  ForumBloc({ForumRepository? forumRepository})
    : _forumRepository = forumRepository ?? ForumRepository(),
      super(ForumInitial()) {
    on<ForumLoadRequested>(_onForumLoadRequested);
    on<ForumDetailRequested>(_onForumDetailRequested);
    on<ForumCreateRequested>(_onForumCreateRequested);
    on<ForumUpdateRequested>(_onForumUpdateRequested);
    on<ForumDeleteRequested>(_onForumDeleteRequested);
    on<ForumResetDetail>(_onForumResetDetail);
  }

  /// Handle load daftar topics
  Future<void> _onForumLoadRequested(
    ForumLoadRequested event,
    Emitter<ForumState> emit,
  ) async {
    try {
      // Jika refresh atau halaman pertama
      if (event.refresh || event.page == 1) {
        emit(ForumLoading());
      } else if (state is ForumLoaded) {
        // Load more - tampilkan loading more
        emit(ForumLoadingMore(currentTopics: (state as ForumLoaded).topics));
      }

      final response = await _forumRepository.getTopics(
        page: event.page,
        category: event.category,
        search: event.search,
      );

      if (event.page == 1 || event.refresh) {
        emit(
          ForumLoaded(
            topics: response.topics,
            currentPage: response.currentPage,
            lastPage: response.lastPage,
            total: response.total,
            hasReachedMax: !response.hasNextPage,
          ),
        );
      } else {
        // Append ke existing list
        final currentState = state;
        if (currentState is ForumLoadingMore) {
          emit(
            ForumLoaded(
              topics: [...currentState.currentTopics, ...response.topics],
              currentPage: response.currentPage,
              lastPage: response.lastPage,
              total: response.total,
              hasReachedMax: !response.hasNextPage,
            ),
          );
        }
      }
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Handle load detail topic
  Future<void> _onForumDetailRequested(
    ForumDetailRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      final topic = await _forumRepository.getTopicDetail(event.topicId);
      emit(ForumDetailLoaded(topic: topic));
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Handle create topic baru
  Future<void> _onForumCreateRequested(
    ForumCreateRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      final topic = await _forumRepository.createTopic(
        title: event.title,
        category: event.category,
        description: event.description,
        isAnonymous: event.isAnonymous,
      );
      emit(
        ForumOperationSuccess(message: 'Post berhasil dibuat!', topic: topic),
      );
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Handle update topic
  Future<void> _onForumUpdateRequested(
    ForumUpdateRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      final topic = await _forumRepository.updateTopic(
        topicId: event.topicId,
        title: event.title,
        category: event.category,
        description: event.description,
        isAnonymous: event.isAnonymous,
      );
      emit(
        ForumOperationSuccess(message: 'Post berhasil diupdate!', topic: topic),
      );
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Handle delete topic
  Future<void> _onForumDeleteRequested(
    ForumDeleteRequested event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      await _forumRepository.deleteTopic(event.topicId);
      emit(const ForumOperationSuccess(message: 'Post berhasil dihapus!'));
    } catch (e) {
      emit(ForumError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Handle reset detail state
  void _onForumResetDetail(ForumResetDetail event, Emitter<ForumState> emit) {
    emit(ForumInitial());
  }
}
