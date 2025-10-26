import 'package:equatable/equatable.dart';

/// Eventos del Home BLoC
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar los datos del dashboard
class LoadDashboardEvent extends HomeEvent {
  const LoadDashboardEvent();
}

/// Evento para refrescar los datos
class RefreshDashboardEvent extends HomeEvent {
  const RefreshDashboardEvent();
}

/// Evento para actualizar el perfil del usuario
class UpdateUserProfileEvent extends HomeEvent {
  final String? displayName;
  final String? photoUrl;

  const UpdateUserProfileEvent({
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [displayName, photoUrl];
}

/// Evento para cerrar sesión
class LogoutEvent extends HomeEvent {
  const LogoutEvent();
}
