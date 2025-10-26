import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/home_repository.dart';

/// Use case para obtener el perfil del usuario
class GetUserProfileUseCase implements UseCase<UserProfileEntity, NoParams> {
  final HomeRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}
