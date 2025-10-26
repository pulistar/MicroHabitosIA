import '../repositories/auth_repository.dart';

/// Use case para verificar si el usuario está autenticado
class IsUserAuthenticatedUseCase {
  final AuthRepository repository;

  IsUserAuthenticatedUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isUserAuthenticated();
  }
}
