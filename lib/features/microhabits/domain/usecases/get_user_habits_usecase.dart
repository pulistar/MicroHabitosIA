import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_entity.dart';
import '../repositories/habits_repository.dart';

/// Use case para obtener todos los hábitos del usuario
class GetUserHabitsUseCase implements UseCase<List<HabitEntity>, NoParams> {
  final HabitsRepository repository;

  GetUserHabitsUseCase(this.repository);

  @override
  Future<Either<Failure, List<HabitEntity>>> call(NoParams params) async {
    return await repository.getUserHabits();
  }
}
