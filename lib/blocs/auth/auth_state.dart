import 'package:equatable/equatable.dart';
import '../../models/user.dart';

/// States untuk AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// State awal saat cek status
class AuthInitial extends AuthState {}

/// State saat loading
class AuthLoading extends AuthState {}

/// State saat user sudah terotentikasi
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State saat user belum login
class AuthUnauthenticated extends AuthState {}

/// State saat terjadi error
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
