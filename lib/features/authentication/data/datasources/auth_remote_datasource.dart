import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger_service.dart';
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
        throw Exception('Usuario no encontrado');
      }

      LoggerService.auth('Login exitoso: $email');
      return UserModel.fromJson(response.user!.toJson());
    } on AuthApiException catch (e) {
      String mensajeError = _obtenerMensajeError(e.message);
      LoggerService.error('Error en login con email: $mensajeError', e);
      throw Exception(mensajeError);
    } catch (e) {
      LoggerService.error('Error en login con email', e);
      rethrow;
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
            throw Exception('❌ Tiempo de espera agotado. Intenta de nuevo.');
          },
        );

        return result;
      } catch (e) {
        sessionSubscription.cancel();
        if (e.toString().contains('Tiempo de espera agotado')) {
          rethrow;
        }
        throw Exception('❌ Cancelaste el login con Google. Intenta de nuevo.');
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
        throw Exception('Error al crear el usuario');
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
        throw Exception('Error al auto-loguear después del registro');
      }

      LoggerService.auth('Auto-login exitoso: $email');
      return UserModel.fromJson(loginResponse.user!.toJson());
    } catch (e) {
      LoggerService.error('Error en registro', e);
      rethrow;
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
      rethrow;
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

  /// Obtiene un mensaje de error amigable basado en el error de Supabase
  String _obtenerMensajeError(String? mensaje) {
    if (mensaje == null) return 'Error desconocido. Intenta de nuevo.';

    // Errores de autenticación
    if (mensaje.contains('Invalid login credentials')) {
      return '❌ Contraseña incorrecta. Verifica tus credenciales.';
    }
    if (mensaje.contains('Email not confirmed')) {
      return '📧 Por favor confirma tu email antes de iniciar sesión.';
    }
    if (mensaje.contains('User not found')) {
      return '👤 Esta cuenta no existe. ¿Quieres registrarte?';
    }
    if (mensaje.contains('Email already exists')) {
      return '📧 Este email ya está registrado. Intenta iniciar sesión.';
    }
    if (mensaje.contains('Password should be at least')) {
      return '🔐 La contraseña debe tener al menos 8 caracteres.';
    }
    if (mensaje.contains('Invalid email')) {
      return '✉️ El formato del email no es válido.';
    }
    if (mensaje.contains('over_email_send_rate_limit')) {
      return '⏱️ Demasiados intentos. Espera unos minutos e intenta de nuevo.';
    }
    if (mensaje.contains('Network error')) {
      return '🌐 Error de conexión. Verifica tu internet.';
    }

    // Error genérico
    return '⚠️ Error: ${mensaje.substring(0, mensaje.length > 50 ? 50 : mensaje.length)}';
  }

}
