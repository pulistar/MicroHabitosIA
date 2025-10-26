import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_entity.dart';
import '../repositories/habits_repository.dart';

/// Parámetros para crear un hábito
class CreateHabitParams extends Equatable {
  final String name;
  final String? description;
  final String category;
  final String color;
  final String icon;
  final int dailyGoal;

  const CreateHabitParams({
    required this.name,
    this.description,
    required this.category,
    required this.color,
    required this.icon,
    this.dailyGoal = 1,
  });

  @override
  List<Object?> get props => [name, description, category, color, icon, dailyGoal];
}

/// Use case para crear un nuevo hábito
class CreateHabitUseCase implements UseCase<HabitEntity, CreateHabitParams> {
  final HabitsRepository repository;

  CreateHabitUseCase(this.repository);

  @override
  Future<Either<Failure, HabitEntity>> call(CreateHabitParams params) async {
    return await repository.createHabit(
      name: params.name,
      description: params.description,
      category: params.category,
      color: params.color,
      icon: params.icon,
      dailyGoal: params.dailyGoal,
    );
  }
}
