import 'package:equatable/equatable.dart';

/// Entidad que representa un microhábito
class HabitEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String category;
  final String color; // Color hex para identificación visual
  final String icon; // Nombre del icono
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final int dailyGoal; // Cuántas veces debe completarse por día
  final int completedToday; // Cuántas veces se completó hoy

  const HabitEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.category,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.dailyGoal,
    required this.completedToday,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        category,
        color,
        icon,
        isActive,
        createdAt,
        updatedAt,
        currentStreak,
        longestStreak,
        totalCompletions,
        dailyGoal,
        completedToday,
      ];
}
