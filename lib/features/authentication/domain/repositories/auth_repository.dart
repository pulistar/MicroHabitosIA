import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Login con email y contraseña
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Login con Google
  Future<Either<Failure, UserEntity>> loginWithGoogle();

  /// Registrarse con email y contraseña
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Obtener usuario actual
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Verificar si el usuario está autenticado
  Future<bool> isUserAuthenticated();
}
