import '../../domain/entities/temporary_progress_entity.dart';

/// Modelo de datos para el progreso temporal de hábitos
class TemporaryProgressModel extends TemporaryProgressEntity {
  const TemporaryProgressModel({
    required super.id,
    required super.userId,
    required super.habitId,
    required super.tempCount,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crear desde JSON (respuesta de Supabase)
  factory TemporaryProgressModel.fromJson(Map<String, dynamic> json) {
    return TemporaryProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String,
      tempCount: json['temp_count'] as int,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convertir a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'habit_id': habitId,
      'temp_count': tempCount,
      'date': date.toIso8601String().split('T')[0], // Solo fecha YYYY-MM-DD
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convertir a JSON para insertar (sin id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'habit_id': habitId,
      'temp_count': tempCount,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  /// Convertir a JSON para actualizar (solo temp_count)
  Map<String, dynamic> toUpdateJson() {
    return {
      'temp_count': tempCount,
    };
  }

  /// Crear copia con nuevos valores
  TemporaryProgressModel copyWith({
    String? id,
    String? userId,
    String? habitId,
    int? tempCount,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TemporaryProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      tempCount: tempCount ?? this.tempCount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
