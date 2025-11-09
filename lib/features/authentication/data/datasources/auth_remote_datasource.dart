import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger_service.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Login con email y contraseña
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  });

  /// Login con Google
  Future<UserModel> loginWithGoogle();

  /// Registrarse con email y contraseña
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Logout
  Future<void> logout();

  /// Obtener usuario actual
  Future<UserModel?> getCurrentUser();

  /// Verificar si el usuario está autenticado
  Future<bool> isUserAuthenticated();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.auth('Iniciando login con email: $email');
      
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const app_exceptions.UserNotFoundException();
      }

      LoggerService.auth('Login exitoso: $email');
      return UserModel.fromJson(response.user!.toJson());
    } on AuthApiException catch (e) {
      LoggerService.error('Error en login con email', e);
      throw app_exceptions.ExceptionMapper.mapSupabaseError(e.message ?? e.toString());
    } catch (e) {
      LoggerService.error('Error en login con email', e);
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Error al iniciar sesión', originalError: e);
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      LoggerService.auth('Iniciando login con Google');
      
      // Crear un Completer para manejar el resultado del OAuth
      final completer = Completer<UserModel>();
      
      // Escuchar cambios de sesión
      late StreamSubscription<AuthState> sessionSubscription;
      sessionSubscription = supabaseClient.auth.onAuthStateChange.listen((data) {
        LoggerService.auth('Auth state changed: ${data.event}');
        
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          // Login exitoso
          final user = data.session!.user;
          LoggerService.auth('Login con Google exitoso: ${user.email}');
          if (!completer.isCompleted) {
            completer.complete(UserModel.fromJson(user.toJson()));
          }
          sessionSubscription.cancel();
        }
      });

      try {
        await supabaseClient.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'com.micrero.app://auth-callback',
        );

        // Esperar hasta 30 segundos por el resultado
        final result = await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            sessionSubscription.cancel();
            throw const app_exceptions.TimeoutException();
          },
        );

        return result;
      } catch (e) {
        sessionSubscription.cancel();
        if (e is app_exceptions.AppException) rethrow;
        throw app_exceptions.AuthException('Error en login con Google', originalError: e);
      }
    } catch (e) {
      LoggerService.error('Error en login con Google', e);
      rethrow;
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      LoggerService.auth('Registrando nuevo usuario: $email');
      
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName ?? email.split('@')[0],
        },
      );

      if (response.user == null) {
        throw const app_exceptions.ServerException('Error al crear el usuario');
      }

      LoggerService.auth('Registro exitoso: $email');
      
      // Auto-login después del signup
      LoggerService.auth('Auto-login después del signup: $email');
      await Future.delayed(const Duration(milliseconds: 500));
      
      final loginResponse = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (loginResponse.user == null) {
        throw const app_exceptions.ServerException('Error al auto-loguear después del registro');
      }

      LoggerService.auth('Auto-login exitoso: $email');
      return UserModel.fromJson(loginResponse.user!.toJson());
    } on AuthApiException catch (e) {
      LoggerService.error('Error en registro', e);
      throw app_exceptions.ExceptionMapper.mapSupabaseError(e.message ?? e.toString());
    } catch (e) {
      LoggerService.error('Error en registro', e);
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Error al registrarse', originalError: e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      LoggerService.auth('Cerrando sesión');
      await supabaseClient.auth.signOut();
      LoggerService.auth('Sesión cerrada');
    } catch (e) {
      LoggerService.error('Error al cerrar sesión', e);
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.ServerException('Error al cerrar sesión', originalError: e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return null;
      }
      return UserModel.fromJson(user.toJson());
    } catch (e) {
      LoggerService.error('Error al obtener usuario actual', e);
      return null;
    }
  }

  @override
  Future<bool> isUserAuthenticated() async {
    try {
      final session = supabaseClient.auth.currentSession;
      return session != null;
    } catch (e) {
      LoggerService.error('Error al verificar autenticación', e);
      return false;
    }
  }


}
