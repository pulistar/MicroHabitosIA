import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailParams {
  final String email;
  final String password;

  LoginWithEmailParams({
    required this.email,
    required this.password,
  });
}

class LoginWithEmailUseCase
    implements UseCase<UserEntity, LoginWithEmailParams> {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginWithEmailParams params) async {
    return await repository.loginWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
