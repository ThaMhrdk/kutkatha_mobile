import 'package:equatable/equatable.dart';
import '../data/psikolog_model.dart';

/// States untuk PsikologBloc
abstract class PsikologState extends Equatable {
  const PsikologState();

  @override
  List<Object?> get props => [];
}

class PsikologInitial extends PsikologState {}

class PsikologLoading extends PsikologState {}

class PsikologLoaded extends PsikologState {
  final List<Psikolog> psikologs;

  const PsikologLoaded({required this.psikologs});

  @override
  List<Object?> get props => [psikologs];
}

class PsikologDetailLoaded extends PsikologState {
  final Psikolog psikolog;
  final List<Schedule> schedules;

  const PsikologDetailLoaded({
    required this.psikolog,
    this.schedules = const [],
  });

  @override
  List<Object?> get props => [psikolog, schedules];
}

class PsikologError extends PsikologState {
  final String message;

  const PsikologError({required this.message});

  @override
  List<Object?> get props => [message];
}
