import 'package:equatable/equatable.dart';

/// Entidad que representa la completitud de un hábito en una fecha específica
class HabitCompletionEntity extends Equatable {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final String? notes; // Notas opcionales del usuario
  final DateTime createdAt;

  const HabitCompletionEntity({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        habitId,
        userId,
        completedAt,
        notes,
        createdAt,
      ];
}
