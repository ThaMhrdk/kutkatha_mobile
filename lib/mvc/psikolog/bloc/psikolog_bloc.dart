import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/psikolog_repository.dart';
import 'psikolog_event.dart';
import 'psikolog_state.dart';

/// BLoC untuk Psikolog
class PsikologBloc extends Bloc<PsikologEvent, PsikologState> {
  final PsikologRepository _repository;

  PsikologBloc({PsikologRepository? repository})
    : _repository = repository ?? PsikologRepository(),
      super(PsikologInitial()) {
    on<PsikologLoadRequested>(_onLoadRequested);
    on<PsikologDetailRequested>(_onDetailRequested);
    on<PsikologSchedulesRequested>(_onSchedulesRequested);
  }

  Future<void> _onLoadRequested(
    PsikologLoadRequested event,
    Emitter<PsikologState> emit,
  ) async {
    emit(PsikologLoading());
    try {
      final psikologs = await _repository.getPsikologs(
        specialization: event.specialization,
        search: event.search,
      );
      emit(PsikologLoaded(psikologs: psikologs));
    } catch (e) {
      emit(PsikologError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDetailRequested(
    PsikologDetailRequested event,
    Emitter<PsikologState> emit,
  ) async {
    emit(PsikologLoading());
    try {
      final psikolog = await _repository.getPsikologDetail(event.psikologId);
      final schedules = await _repository.getPsikologSchedules(
        event.psikologId,
      );
      emit(PsikologDetailLoaded(psikolog: psikolog, schedules: schedules));
    } catch (e) {
      emit(PsikologError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSchedulesRequested(
    PsikologSchedulesRequested event,
    Emitter<PsikologState> emit,
  ) async {
    final currentState = state;
    if (currentState is PsikologDetailLoaded) {
      try {
        final schedules = await _repository.getPsikologSchedules(
          event.psikologId,
        );
        emit(
          PsikologDetailLoaded(
            psikolog: currentState.psikolog,
            schedules: schedules,
          ),
        );
      } catch (e) {
        emit(
          PsikologError(message: e.toString().replaceAll('Exception: ', '')),
        );
      }
    }
  }
}
