import 'package:equatable/equatable.dart';

/// Events untuk AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check login status saat app start
class AuthCheckRequested extends AuthEvent {}

/// Login event
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Register event
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String? phone;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.phone,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    passwordConfirmation,
    phone,
  ];
}

/// Logout event
class AuthLogoutRequested extends AuthEvent {}

/// Update profile event
class AuthUpdateProfileRequested extends AuthEvent {
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? photoPath;

  const AuthUpdateProfileRequested({
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.photoPath,
  });

  @override
  List<Object?> get props => [name, email, phone, address, photoPath];
}
