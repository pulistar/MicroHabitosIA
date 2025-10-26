import '../../domain/entities/habit_entity.dart';

/// Modelo de datos para hábitos con serialización JSON
class HabitModel extends HabitEntity {
  const HabitModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.category,
    required super.color,
    required super.icon,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.currentStreak,
    required super.longestStreak,
    required super.totalCompletions,
    required super.dailyGoal,
    required super.completedToday,
  });

  /// Crea un HabitModel desde JSON
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalCompletions: json['total_completions'] as int? ?? 0,
      dailyGoal: json['daily_goal'] as int? ?? 1,
      completedToday: json['completed_today'] as int? ?? 0,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'category': category,
      'color': color,
      'icon': icon,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_completions': totalCompletions,
      'daily_goal': dailyGoal,
      'completed_today': completedToday,
    };
  }

  /// Crea una copia con campos actualizados
  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? category,
    String? color,
    String? icon,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    int? dailyGoal,
    int? completedToday,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      completedToday: completedToday ?? this.completedToday,
    );
  }
}
