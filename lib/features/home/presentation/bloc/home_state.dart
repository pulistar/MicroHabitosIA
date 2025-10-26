import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_entity.dart';

/// Estados del Home BLoC
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Estado de carga
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Estado de datos cargados exitosamente
class HomeLoaded extends HomeState {
  final DashboardEntity dashboard;

  const HomeLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

/// Estado de error
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de actualización de perfil
class ProfileUpdating extends HomeState {
  const ProfileUpdating();
}

/// Estado de perfil actualizado
class ProfileUpdated extends HomeState {
  final DashboardEntity dashboard;

  const ProfileUpdated(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

/// Estado de logout
class LogoutInProgress extends HomeState {
  const LogoutInProgress();
}

/// Estado de logout exitoso
class LogoutSuccess extends HomeState {
  const LogoutSuccess();
}
