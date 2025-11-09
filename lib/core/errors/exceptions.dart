/// Excepciones personalizadas para manejo de errores

/// Excepción base para todas las excepciones de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Excepciones de autenticación
class AuthException extends AppException {
  const AuthException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Credenciales inválidas', code: 'invalid_credentials');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('Usuario no encontrado', code: 'user_not_found');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('El correo electrónico ya está en uso', code: 'email_in_use');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super('La contraseña es muy débil', code: 'weak_password');
}

class UserNotAuthenticatedException extends AuthException {
  const UserNotAuthenticatedException()
      : super('Usuario no autenticado', code: 'not_authenticated');
}

/// Excepciones de servidor
class ServerException extends AppException {
  const ServerException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class NetworkException extends AppException {
  const NetworkException()
      : super('Error de conexión. Verifica tu internet.', code: 'network_error');
}

class TimeoutException extends AppException {
  const TimeoutException()
      : super('La solicitud tardó demasiado tiempo', code: 'timeout');
}

/// Excepciones de caché/almacenamiento
class CacheException extends AppException {
  const CacheException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// Excepciones de validación
class ValidationException extends AppException {
  const ValidationException(String message, {String? code})
      : super(message, code: code);
}

/// Excepciones de datos
class DataNotFoundException extends AppException {
  const DataNotFoundException(String message)
      : super(message, code: 'data_not_found');
}

class DataParsingException extends AppException {
  const DataParsingException(String message, {dynamic originalError})
      : super(message, code: 'parsing_error', originalError: originalError);
}

/// Helper para convertir errores de Supabase a excepciones personalizadas
class ExceptionMapper {
  static AppException mapSupabaseError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    // Errores de autenticación
    if (errorMessage.contains('invalid login credentials') ||
        errorMessage.contains('invalid_credentials')) {
      return const InvalidCredentialsException();
    }
    
    if (errorMessage.contains('user not found') ||
        errorMessage.contains('user_not_found')) {
      return const UserNotFoundException();
    }
    
    if (errorMessage.contains('email already registered') ||
        errorMessage.contains('user_already_registered') ||
        errorMessage.contains('already been registered')) {
      return const EmailAlreadyInUseException();
    }
    
    if (errorMessage.contains('password') && 
        (errorMessage.contains('weak') || errorMessage.contains('short'))) {
      return const WeakPasswordException();
    }

    // Errores de red
    if (errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('unreachable')) {
      return const NetworkException();
    }

    if (errorMessage.contains('timeout')) {
      return const TimeoutException();
    }

    // Error genérico del servidor
    return ServerException(
      _cleanErrorMessage(error.toString()),
      originalError: error,
    );
  }

  /// Limpia el mensaje de error removiendo prefijos comunes
  static String _cleanErrorMessage(String error) {
    return error
        .replaceFirst('Exception: ', '')
        .replaceFirst('Error: ', '')
        .replaceFirst('AuthException: ', '')
        .trim();
  }
}
