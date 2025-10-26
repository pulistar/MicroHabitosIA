import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_category_entity.dart';
import '../repositories/habits_repository.dart';

/// Use case para obtener todas las categorías de hábitos
class GetCategoriesUseCase implements UseCase<List<HabitCategoryEntity>, NoParams> {
  final HabitsRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<HabitCategoryEntity>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
