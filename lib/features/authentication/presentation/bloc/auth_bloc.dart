import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/is_user_authenticated_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC para manejar el estado de autenticación global
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final IsUserAuthenticatedUseCase isUserAuthenticatedUseCase;
  final LogoutUseCase logoutUseCase;
  
  late StreamSubscription<AuthState> _authSubscription;

  AuthBloc({
    required this.getCurrentUserUseCase,
    required this.isUserAuthenticatedUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    
    // Escuchar cambios de autenticación de Supabase
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      LoggerService.auth('Auth state changed: ${session != null ? 'authenticated' : 'unauthenticated'}');
      
      if (session != null) {
        add(AuthUserChanged(session.user));
      } else {
        add(const AuthUserChanged(null));
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final isAuthenticated = await isUserAuthenticatedUseCase();
      
      if (isAuthenticated) {
        final result = await getCurrentUserUseCase(NoParams());
        
        result.fold(
          (failure) {
            LoggerService.error('Error getting current user: ${failure.toString()}');
            emit(const AuthUnauthenticated());
          },
          (user) {
            if (user != null) {
              LoggerService.auth('User authenticated: ${user.email}');
              emit(AuthAuthenticated(user));
            } else {
              LoggerService.auth('No user found');
              emit(const AuthUnauthenticated());
            }
          },
        );
      } else {
        LoggerService.auth('User not authenticated');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      LoggerService.error('Error checking auth status', e);
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await logoutUseCase(NoParams());
      
      result.fold(
        (failure) {
          LoggerService.error('Error during logout: ${failure.toString()}');
          // Aún así, consideramos que el logout fue exitoso localmente
          emit(const AuthUnauthenticated());
        },
        (_) {
          LoggerService.auth('Logout successful');
          emit(const AuthUnauthenticated());
        },
      );
    } catch (e) {
      LoggerService.error('Error during logout', e);
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      try {
        final result = await getCurrentUserUseCase(NoParams());
        
        result.fold(
          (failure) {
            LoggerService.error('Error getting user after auth change: ${failure.toString()}');
            emit(const AuthUnauthenticated());
          },
          (user) {
            if (user != null) {
              LoggerService.auth('User changed: ${user.email}');
              emit(AuthAuthenticated(user));
            } else {
              emit(const AuthUnauthenticated());
            }
          },
        );
      } catch (e) {
        LoggerService.error('Error handling user change', e);
        emit(const AuthUnauthenticated());
      }
    } else {
      LoggerService.auth('User signed out');
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
