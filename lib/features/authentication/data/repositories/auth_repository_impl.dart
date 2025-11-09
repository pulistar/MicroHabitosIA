import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart' as app_exceptions;
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
    } on app_exceptions.AuthException catch (e) {
      LoggerService.error('loginWithEmail failed', e);
      return Left(AuthenticationFailure(e.message));
    } on app_exceptions.NetworkException catch (e) {
      LoggerService.error('loginWithEmail failed - network', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      LoggerService.error('loginWithEmail failed - unexpected', e);
      return Left(ServerFailure('Error inesperado al iniciar sesión'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      LoggerService.startOperation('loginWithGoogle');
      final user = await remoteDataSource.loginWithGoogle();
      LoggerService.endOperation('loginWithGoogle');
      return Right(user);
    } on app_exceptions.AuthException catch (e) {
      LoggerService.error('loginWithGoogle failed', e);
      return Left(AuthenticationFailure(e.message));
    } on app_exceptions.NetworkException catch (e) {
      LoggerService.error('loginWithGoogle failed - network', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      LoggerService.error('loginWithGoogle failed - unexpected', e);
      return Left(ServerFailure('Error inesperado en login con Google'));
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
    } on app_exceptions.AuthException catch (e) {
      LoggerService.error('signUp failed', e);
      return Left(AuthenticationFailure(e.message));
    } on app_exceptions.NetworkException catch (e) {
      LoggerService.error('signUp failed - network', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      LoggerService.error('signUp failed - unexpected', e);
      return Left(ServerFailure('Error inesperado al registrarse'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      LoggerService.startOperation('logout');
      await remoteDataSource.logout();
      LoggerService.endOperation('logout');
      return const Right(null);
    } on app_exceptions.AuthException catch (e) {
      LoggerService.error('logout failed', e);
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      LoggerService.error('logout failed - unexpected', e);
      return Left(ServerFailure('Error inesperado al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on app_exceptions.AuthException catch (e) {
      LoggerService.error('getCurrentUser failed', e);
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      LoggerService.error('getCurrentUser failed - unexpected', e);
      return Left(ServerFailure('Error al obtener usuario'));
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
