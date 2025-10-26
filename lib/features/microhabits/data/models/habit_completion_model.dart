import '../../domain/entities/habit_completion_entity.dart';

/// Modelo de datos para completitudes de hábitos
class HabitCompletionModel extends HabitCompletionEntity {
  const HabitCompletionModel({
    required super.id,
    required super.habitId,
    required super.userId,
    required super.completedAt,
    super.notes,
    required super.createdAt,
  });

  /// Crea un HabitCompletionModel desde JSON
  factory HabitCompletionModel.fromJson(Map<String, dynamic> json) {
    return HabitCompletionModel(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': completedAt.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
