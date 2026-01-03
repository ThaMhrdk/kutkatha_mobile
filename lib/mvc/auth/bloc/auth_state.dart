import 'package:equatable/equatable.dart';
import '../data/user_model.dart';

/// States untuk AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Authenticated (logged in)
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated (logged out)
class AuthUnauthenticated extends AuthState {}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Profile update success
class AuthProfileUpdated extends AuthState {
  final User user;
  final String message;

  const AuthProfileUpdated({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}
