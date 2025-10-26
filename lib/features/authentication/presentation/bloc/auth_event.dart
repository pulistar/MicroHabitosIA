part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para verificar el estado de autenticación
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento para cerrar sesión
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Evento cuando el usuario cambia (interno)
class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
