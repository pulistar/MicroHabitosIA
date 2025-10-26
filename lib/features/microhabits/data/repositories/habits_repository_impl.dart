import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger_service.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/habit_completion_entity.dart';
import '../../domain/entities/habit_category_entity.dart';
import '../../domain/entities/temporary_progress_entity.dart';
import '../../domain/repositories/habits_repository.dart';
import '../datasources/habits_remote_datasource.dart';

/// Implementación del repository de hábitos
class HabitsRepositoryImpl implements HabitsRepository {
  final HabitsRemoteDataSource remoteDataSource;

  HabitsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HabitEntity>>> getUserHabits() async {
    try {
      LoggerService.startOperation('getUserHabits');
      final habits = await remoteDataSource.getUserHabits();
      LoggerService.endOperation('getUserHabits');
      return Right(habits);
    } catch (e) {
      LoggerService.error('Error en getUserHabits: $e');
      return Left(ServerFailure('Error al obtener hábitos: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> getHabitById(String habitId) async {
    try {
      LoggerService.startOperation('getHabitById');
      final habit = await remoteDataSource.getHabitById(habitId);
      LoggerService.endOperation('getHabitById');
      return Right(habit);
    } catch (e) {
      LoggerService.error('Error en getHabitById: $e');
      return Left(ServerFailure('Error al obtener hábito: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> createHabit({
    required String name,
    String? description,
    required String category,
    required String color,
    required String icon,
    int dailyGoal = 1,
  }) async {
    try {
      LoggerService.startOperation('createHabit');
      final habit = await remoteDataSource.createHabit(
        name: name,
        description: description,
        category: category,
        color: color,
        icon: icon,
        dailyGoal: dailyGoal,
      );
      LoggerService.endOperation('createHabit');
      return Right(habit);
    } catch (e) {
      LoggerService.error('Error en createHabit: $e');
      return Left(ServerFailure('Error al crear hábito: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntity>> updateHabit({
    required String habitId,
    String? name,
    String? description,
    String? category,
    String? color,
    String? icon,
    bool? isActive,
  }) async {
    try {
      LoggerService.startOperation('updateHabit');
      final habit = await remoteDataSource.updateHabit(
        habitId: habitId,
        name: name,
        description: description,
        category: category,
        color: color,
        icon: icon,
        isActive: isActive,
      );
      LoggerService.endOperation('updateHabit');
      return Right(habit);
    } catch (e) {
      LoggerService.error('Error en updateHabit: $e');
      return Left(ServerFailure('Error al actualizar hábito: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    try {
      LoggerService.startOperation('deleteHabit');
      await remoteDataSource.deleteHabit(habitId);
      LoggerService.endOperation('deleteHabit');
      return const Right(null);
    } catch (e) {
      LoggerService.error('Error en deleteHabit: $e');
      return Left(ServerFailure('Error al eliminar hábito: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitCompletionEntity>> completeHabit({
    required String habitId,
    String? notes,
  }) async {
    try {
      LoggerService.startOperation('completeHabit');
      final completion = await remoteDataSource.completeHabit(
        habitId: habitId,
        notes: notes,
      );
      LoggerService.endOperation('completeHabit');
      return Right(completion);
    } catch (e) {
      LoggerService.error('Error en completeHabit: $e');
      return Left(ServerFailure('Error al completar hábito: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> uncompleteHabit(String habitId) async {
    try {
      LoggerService.startOperation('uncompleteHabit');
      await remoteDataSource.uncompleteHabit(habitId);
      LoggerService.endOperation('uncompleteHabit');
      return const Right(null);
    } catch (e) {
      LoggerService.error('Error en uncompleteHabit: $e');
      return Left(ServerFailure('Error al descompletar hábito: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HabitCompletionEntity>>> getHabitCompletions({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      LoggerService.startOperation('getHabitCompletions');
      final completions = await remoteDataSource.getHabitCompletions(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );
      LoggerService.endOperation('getHabitCompletions');
      return Right(completions);
    } catch (e) {
      LoggerService.error('Error en getHabitCompletions: $e');
      return Left(ServerFailure('Error al obtener completitudes: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isHabitCompletedOnDate({
    required String habitId,
    required DateTime date,
  }) async {
    try {
      LoggerService.startOperation('isHabitCompletedOnDate');
      final isCompleted = await remoteDataSource.isHabitCompletedOnDate(
        habitId: habitId,
        date: date,
      );
      LoggerService.endOperation('isHabitCompletedOnDate');
      return Right(isCompleted);
    } catch (e) {
      LoggerService.error('Error en isHabitCompletedOnDate: $e');
      return Left(ServerFailure('Error al verificar completitud: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HabitCategoryEntity>>> getCategories() async {
    try {
      LoggerService.startOperation('getCategories');
      final categories = await remoteDataSource.getCategories();
      LoggerService.endOperation('getCategories');
      return Right(categories);
    } catch (e) {
      LoggerService.error('Error en getCategories: $e');
      return Left(ServerFailure('Error al obtener categorías: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserStatistics() async {
    try {
      LoggerService.startOperation('getUserStatistics');
      final stats = await remoteDataSource.getUserStatistics();
      LoggerService.endOperation('getUserStatistics');
      return Right(stats);
    } catch (e) {
      LoggerService.error('Error en getUserStatistics: $e');
      return Left(ServerFailure('Error al obtener estadísticas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getWeeklyProgress() async {
    try {
      LoggerService.startOperation('getWeeklyProgress');
      final progress = await remoteDataSource.getWeeklyProgress();
      LoggerService.endOperation('getWeeklyProgress');
      return Right(progress);
    } catch (e) {
      LoggerService.error('Error en getWeeklyProgress: $e');
      return Left(ServerFailure('Error al obtener progreso semanal: $e'));
    }
  }

  // ==================== TEMPORARY PROGRESS ====================

  @override
  Future<Either<Failure, Map<String, int>>> getTemporaryProgress() async {
    try {
      LoggerService.startOperation('getTemporaryProgress');
      final progress = await remoteDataSource.getTemporaryProgress();
      LoggerService.endOperation('getTemporaryProgress');
      return Right(progress);
    } catch (e) {
      LoggerService.error('Error en getTemporaryProgress: $e');
      return Left(ServerFailure('Error al obtener progreso temporal: $e'));
    }
  }

  @override
  Future<Either<Failure, TemporaryProgressEntity>> saveTemporaryProgress({
    required String habitId,
    required int tempCount,
  }) async {
    try {
      LoggerService.startOperation('saveTemporaryProgress');
      final result = await remoteDataSource.saveTemporaryProgress(
        habitId: habitId,
        tempCount: tempCount,
      );
      LoggerService.endOperation('saveTemporaryProgress');
      return Right(result);
    } catch (e) {
      LoggerService.error('Error en saveTemporaryProgress: $e');
      return Left(ServerFailure('Error al guardar progreso temporal: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearTemporaryProgress(String habitId) async {
    try {
      LoggerService.startOperation('clearTemporaryProgress');
      await remoteDataSource.clearTemporaryProgress(habitId);
      LoggerService.endOperation('clearTemporaryProgress');
      return const Right(null);
    } catch (e) {
      LoggerService.error('Error en clearTemporaryProgress: $e');
      return Left(ServerFailure('Error al limpiar progreso temporal: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cleanupOldTemporaryProgress() async {
    try {
      LoggerService.startOperation('cleanupOldTemporaryProgress');
      await remoteDataSource.cleanupOldTemporaryProgress();
      LoggerService.endOperation('cleanupOldTemporaryProgress');
      return const Right(null);
    } catch (e) {
      LoggerService.error('Error en cleanupOldTemporaryProgress: $e');
      return Left(ServerFailure('Error al limpiar progreso temporal antiguo: $e'));
    }
  }
}
