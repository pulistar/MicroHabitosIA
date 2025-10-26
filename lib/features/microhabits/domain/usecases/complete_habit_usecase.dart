import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_completion_entity.dart';
import '../repositories/habits_repository.dart';

/// Parámetros para completar un hábito
class CompleteHabitParams extends Equatable {
  final String habitId;
  final String? notes;

  const CompleteHabitParams({
    required this.habitId,
    this.notes,
  });

  @override
  List<Object?> get props => [habitId, notes];
}

/// Use case para marcar un hábito como completado
class CompleteHabitUseCase implements UseCase<HabitCompletionEntity, CompleteHabitParams> {
  final HabitsRepository repository;

  CompleteHabitUseCase(this.repository);

  @override
  Future<Either<Failure, HabitCompletionEntity>> call(CompleteHabitParams params) async {
    return await repository.completeHabit(
      habitId: params.habitId,
      notes: params.notes,
    );
  }
}
