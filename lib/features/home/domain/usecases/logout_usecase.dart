import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/home_repository.dart';

/// Use case para cerrar sesión
class LogoutUseCase implements UseCase<void, NoParams> {
  final HomeRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
