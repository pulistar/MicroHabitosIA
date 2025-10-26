import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_entity.dart';
import '../repositories/home_repository.dart';

/// Use case para obtener los datos del dashboard
class GetDashboardDataUseCase implements UseCase<DashboardEntity, NoParams> {
  final HomeRepository repository;

  GetDashboardDataUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardEntity>> call(NoParams params) async {
    return await repository.getDashboardData();
  }
}
