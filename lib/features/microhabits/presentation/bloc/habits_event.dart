import 'package:equatable/equatable.dart';

/// Eventos del Habits BLoC
abstract class HabitsEvent extends Equatable {
  const HabitsEvent();

  @override
  List<Object?> get props => [];
}

// ==================== HABITS CRUD EVENTS ====================

/// Evento para cargar todos los hábitos del usuario
class LoadHabitsEvent extends HabitsEvent {
  const LoadHabitsEvent();
}

/// Evento para refrescar la lista de hábitos
class RefreshHabitsEvent extends HabitsEvent {
  const RefreshHabitsEvent();
}

/// Evento para crear un nuevo hábito
class CreateHabitEvent extends HabitsEvent {
  final String name;
  final String? description;
  final String category;
  final String color;
  final String icon;
  final int dailyGoal;

  const CreateHabitEvent({
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

/// Evento para actualizar un hábito existente
class UpdateHabitEvent extends HabitsEvent {
  final String habitId;
  final String? name;
  final String? description;
  final String? category;
  final String? color;
  final String? icon;
  final bool? isActive;

  const UpdateHabitEvent({
    required this.habitId,
    this.name,
    this.description,
    this.category,
    this.color,
    this.icon,
    this.isActive,
  });

  @override
  List<Object?> get props => [habitId, name, description, category, color, icon, isActive];
}

/// Evento para eliminar un hábito
class DeleteHabitEvent extends HabitsEvent {
  final String habitId;

  const DeleteHabitEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

// ==================== HABIT COMPLETION EVENTS ====================

/// Evento para marcar un hábito como completado
class CompleteHabitEvent extends HabitsEvent {
  final String habitId;
  final String? notes;

  const CompleteHabitEvent({
    required this.habitId,
    this.notes,
  });

  @override
  List<Object?> get props => [habitId, notes];
}

/// Evento para desmarcar un hábito completado
class UncompleteHabitEvent extends HabitsEvent {
  final String habitId;

  const UncompleteHabitEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

/// Evento para incrementar progreso temporal de un hábito
class IncrementTemporaryProgressEvent extends HabitsEvent {
  final String habitId;

  const IncrementTemporaryProgressEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

/// Evento para limpiar progreso temporal de un hábito
class ClearTemporaryProgressEvent extends HabitsEvent {
  final String habitId;

  const ClearTemporaryProgressEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

// ==================== CATEGORIES EVENTS ====================

/// Evento para cargar las categorías disponibles
class LoadCategoriesEvent extends HabitsEvent {
  const LoadCategoriesEvent();
}
