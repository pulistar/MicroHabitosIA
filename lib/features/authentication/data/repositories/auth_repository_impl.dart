import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.startOperation('loginWithEmail');
      final user = await remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );
      LoggerService.endOperation('loginWithEmail');
      return Right(user);
    } catch (e) {
      LoggerService.error('loginWithEmail failed', e);
      // Pasar el mensaje real del error
      String mensajeError = e.toString().replaceFirst('Exception: ', '');
      return Left(AuthenticationFailure(mensajeError));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      LoggerService.startOperation('loginWithGoogle');
      final user = await remoteDataSource.loginWithGoogle();
      LoggerService.endOperation('loginWithGoogle');
      return Right(user);
    } catch (e) {
      LoggerService.error('loginWithGoogle failed', e);
      // Pasar el mensaje real del error
      String mensajeError = e.toString().replaceFirst('Exception: ', '');
      return Left(AuthenticationFailure(mensajeError));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      LoggerService.startOperation('signUp');
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      LoggerService.endOperation('signUp');
      return Right(user);
    } catch (e) {
      LoggerService.error('signUp failed', e);
      // Pasar el mensaje real del error
      String mensajeError = e.toString().replaceFirst('Exception: ', '');
      return Left(AuthenticationFailure(mensajeError));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      LoggerService.startOperation('logout');
      await remoteDataSource.logout();
      LoggerService.endOperation('logout');
      return const Right(null);
    } catch (e) {
      LoggerService.error('logout failed', e);
      return Left(AuthenticationFailure('Error al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      LoggerService.error('getCurrentUser failed', e);
      return Left(AuthenticationFailure('Error al obtener usuario'));
    }
  }

  @override
  Future<bool> isUserAuthenticated() async {
    try {
      return await remoteDataSource.isUserAuthenticated();
    } catch (e) {
      LoggerService.error('isUserAuthenticated failed', e);
      return false;
    }
  }
}
