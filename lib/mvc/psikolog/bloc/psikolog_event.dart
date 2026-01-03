import 'package:equatable/equatable.dart';

/// Events untuk PsikologBloc
abstract class PsikologEvent extends Equatable {
  const PsikologEvent();

  @override
  List<Object?> get props => [];
}

/// Load daftar psikolog
class PsikologLoadRequested extends PsikologEvent {
  final String? specialization;
  final String? search;

  const PsikologLoadRequested({this.specialization, this.search});

  @override
  List<Object?> get props => [specialization, search];
}

/// Load detail psikolog
class PsikologDetailRequested extends PsikologEvent {
  final int psikologId;

  const PsikologDetailRequested({required this.psikologId});

  @override
  List<Object?> get props => [psikologId];
}

/// Load jadwal psikolog
class PsikologSchedulesRequested extends PsikologEvent {
  final int psikologId;

  const PsikologSchedulesRequested({required this.psikologId});

  @override
  List<Object?> get props => [psikologId];
}
