import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger_service.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

/// BLoC para manejar el estado del Home
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final LogoutUseCase logoutUseCase;

  HomeBloc({
    required this.getDashboardDataUseCase,
    required this.getUserProfileUseCase,
    required this.logoutUseCase,
  }) : super(const HomeInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    LoggerService.info('Cargando dashboard del usuario');

    final result = await getDashboardDataUseCase(NoParams());

    result.fold(
      (failure) {
        LoggerService.error('Error al cargar dashboard: ${failure.message}');
        emit(HomeError(failure.message));
      },
      (dashboard) {
        LoggerService.info('Dashboard cargado exitosamente');
        emit(HomeLoaded(dashboard));
      },
    );
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    // No mostrar loading si ya hay datos cargados
    if (state is! HomeLoaded) {
      emit(const HomeLoading());
    }

    LoggerService.info('Refrescando dashboard del usuario');

    final result = await getDashboardDataUseCase(NoParams());

    result.fold(
      (failure) {
        LoggerService.error('Error al refrescar dashboard: ${failure.message}');
        emit(HomeError(failure.message));
      },
      (dashboard) {
        LoggerService.info('Dashboard refrescado exitosamente');
        emit(HomeLoaded(dashboard));
      },
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const ProfileUpdating());
    LoggerService.info('Actualizando perfil del usuario');

    // TODO: Implementar UpdateUserProfileUseCase cuando sea necesario
    // Por ahora, simplemente recargamos el dashboard
    await Future.delayed(const Duration(seconds: 1)); // Simular actualización

    final result = await getDashboardDataUseCase(NoParams());

    result.fold(
      (failure) {
        LoggerService.error('Error al actualizar perfil: ${failure.message}');
        emit(HomeError(failure.message));
      },
      (dashboard) {
        LoggerService.info('Perfil actualizado exitosamente');
        emit(ProfileUpdated(dashboard));
      },
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const LogoutInProgress());
    LoggerService.auth('Iniciando logout desde HomeBloc');

    final result = await logoutUseCase(NoParams());

    result.fold(
      (failure) {
        LoggerService.error('Error en logout desde HomeBloc: ${failure.message}');
        emit(HomeError(failure.message));
      },
      (_) {
        LoggerService.auth('Logout exitoso desde HomeBloc');
        emit(const LogoutSuccess());
      },
    );
  }
}
