import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/habit_entity.dart';
import '../entities/habit_completion_entity.dart';
import '../entities/habit_category_entity.dart';
import '../entities/temporary_progress_entity.dart';

/// Repository abstracto para la gestión de hábitos
abstract class HabitsRepository {
  // ==================== HABITS CRUD ====================
  
  /// Obtiene todos los hábitos del usuario actual
  Future<Either<Failure, List<HabitEntity>>> getUserHabits();

  /// Obtiene un hábito específico por ID
  Future<Either<Failure, HabitEntity>> getHabitById(String habitId);

  /// Crea un nuevo hábito
  Future<Either<Failure, HabitEntity>> createHabit({
    required String name,
    String? description,
    required String category,
    required String color,
    required String icon,
    int dailyGoal = 1,
  });

  /// Actualiza un hábito existente
  Future<Either<Failure, HabitEntity>> updateHabit({
    required String habitId,
    String? name,
    String? description,
    String? category,
    String? color,
    String? icon,
    bool? isActive,
    int? dailyGoal,
  });

  /// Elimina un hábito
  Future<Either<Failure, void>> deleteHabit(String habitId);

  // ==================== HABIT COMPLETIONS ====================

  /// Marca un hábito como completado para hoy
  Future<Either<Failure, HabitCompletionEntity>> completeHabit({
    required String habitId,
    String? notes,
  });

  /// Desmarca un hábito completado para hoy
  Future<Either<Failure, void>> uncompleteHabit(String habitId);

  /// Obtiene las completitudes de un hábito en un rango de fechas
  Future<Either<Failure, List<HabitCompletionEntity>>> getHabitCompletions({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Verifica si un hábito fue completado en una fecha específica
  Future<Either<Failure, bool>> isHabitCompletedOnDate({
    required String habitId,
    required DateTime date,
  });

  // ==================== CATEGORIES ====================

  /// Obtiene todas las categorías disponibles
  Future<Either<Failure, List<HabitCategoryEntity>>> getCategories();

  // ==================== STATISTICS ====================

  /// Obtiene estadísticas del usuario (total hábitos, completados hoy, etc.)
  Future<Either<Failure, Map<String, dynamic>>> getUserStatistics();

  /// Obtiene el progreso semanal del usuario
  Future<Either<Failure, List<int>>> getWeeklyProgress();

  // ==================== TEMPORARY PROGRESS ====================

  /// Obtiene el progreso temporal de todos los hábitos del usuario para hoy
  Future<Either<Failure, Map<String, int>>> getTemporaryProgress();

  /// Guarda o actualiza el progreso temporal de un hábito
  Future<Either<Failure, TemporaryProgressEntity>> saveTemporaryProgress({
    required String habitId,
    required int tempCount,
  });

  /// Elimina el progreso temporal de un hábito (cuando se completa)
  Future<Either<Failure, void>> clearTemporaryProgress(String habitId);

  /// Limpia todo el progreso temporal del día anterior
  Future<Either<Failure, void>> cleanupOldTemporaryProgress();
}
