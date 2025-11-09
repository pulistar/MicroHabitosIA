import 'package:equatable/equatable.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/habit_category_entity.dart';

/// Estados del Habits BLoC
abstract class HabitsState extends Equatable {
  const HabitsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class HabitsInitial extends HabitsState {
  const HabitsInitial();
}

/// Estado de carga
class HabitsLoading extends HabitsState {
  const HabitsLoading();
}

/// Estado de hábitos cargados exitosamente
class HabitsLoaded extends HabitsState {
  final List<HabitEntity> habits;
  final List<HabitCategoryEntity> categories;
  final Map<String, int> temporaryProgress; // Progreso temporal por habitId

  const HabitsLoaded({
    required this.habits,
    required this.categories,
    this.temporaryProgress = const {},
  });

  @override
  List<Object?> get props => [habits, categories, temporaryProgress];

  /// Obtiene el progreso actual de un hábito (temporal o real)
  int getCurrentProgress(String habitId) {
    // Si hay progreso temporal, usarlo (progreso interno del hábito)
    // Si no, verificar si ya está completado hoy (mostrar dailyGoal si está completo)
    if (temporaryProgress.containsKey(habitId)) {
      return temporaryProgress[habitId]!;
    }
    
    final habit = habits.firstWhere((h) => h.id == habitId);
    // Si ya completó el hábito hoy, mostrar el objetivo completo
    return habit.completedToday > 0 ? habit.dailyGoal : 0;
  }

  /// Crea una copia con nuevos valores
  HabitsLoaded copyWith({
    List<HabitEntity>? habits,
    List<HabitCategoryEntity>? categories,
    Map<String, int>? temporaryProgress,
  }) {
    return HabitsLoaded(
      habits: habits ?? this.habits,
      categories: categories ?? this.categories,
      temporaryProgress: temporaryProgress ?? this.temporaryProgress,
    );
  }
}

/// Estado de error
class HabitsError extends HabitsState {
  final String message;

  const HabitsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== OPERATION STATES ====================

/// Estado de creación de hábito en progreso
class HabitCreating extends HabitsState {
  const HabitCreating();
}

/// Estado de hábito creado exitosamente
class HabitCreated extends HabitsState {
  final HabitEntity habit;
  final List<HabitEntity> allHabits;
  final List<HabitCategoryEntity> categories;
  final Map<String, int> temporaryProgress;

  const HabitCreated({
    required this.habit,
    required this.allHabits,
    required this.categories,
    this.temporaryProgress = const {},
  });

  @override
  List<Object?> get props => [habit, allHabits, categories, temporaryProgress];
}

/// Estado de actualización de hábito en progreso
class HabitUpdating extends HabitsState {
  const HabitUpdating();
}

/// Estado de hábito actualizado exitosamente
class HabitUpdated extends HabitsState {
  final HabitEntity habit;
  final List<HabitEntity> allHabits;
  final List<HabitCategoryEntity> categories;
  final Map<String, int> temporaryProgress;

  const HabitUpdated({
    required this.habit,
    required this.allHabits,
    required this.categories,
    this.temporaryProgress = const {},
  });

  @override
  List<Object?> get props => [habit, allHabits, categories, temporaryProgress];
}

/// Estado de eliminación de hábito en progreso
class HabitDeleting extends HabitsState {
  const HabitDeleting();
}

/// Estado de hábito eliminado exitosamente
class HabitDeleted extends HabitsState {
  final String habitId;
  final List<HabitEntity> allHabits;
  final List<HabitCategoryEntity> categories;
  final Map<String, int> temporaryProgress;

  const HabitDeleted({
    required this.habitId,
    required this.allHabits,
    required this.categories,
    this.temporaryProgress = const {},
  });

  @override
  List<Object?> get props => [habitId, allHabits, categories, temporaryProgress];
}

// ==================== COMPLETION STATES ====================

/// Estado de completar hábito en progreso
class HabitCompleting extends HabitsState {
  const HabitCompleting();
}

/// Estado de hábito completado exitosamente
class HabitCompleted extends HabitsState {
  final String habitId;
  final List<HabitEntity> allHabits;
  final List<HabitCategoryEntity> categories;

  const HabitCompleted({
    required this.habitId,
    required this.allHabits,
    required this.categories,
  });

  @override
  List<Object?> get props => [habitId, allHabits, categories];
}

/// Estado de descompletar hábito en progreso
class HabitUncompleting extends HabitsState {
  const HabitUncompleting();
}

/// Estado de hábito descompletado exitosamente
class HabitUncompleted extends HabitsState {
  final String habitId;
  final List<HabitEntity> allHabits;
  final List<HabitCategoryEntity> categories;

  const HabitUncompleted({
    required this.habitId,
    required this.allHabits,
    required this.categories,
  });

  @override
  List<Object?> get props => [habitId, allHabits, categories];
}
