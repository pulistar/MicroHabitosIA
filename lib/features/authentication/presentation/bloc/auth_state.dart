part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {}

/// Estado de carga
class AuthLoading extends AuthState {}

/// Estado autenticado
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Estado no autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
