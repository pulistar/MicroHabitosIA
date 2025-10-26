import 'package:equatable/equatable.dart';
import 'user_profile_entity.dart';

/// Entidad que representa los datos del dashboard
class DashboardEntity extends Equatable {
  final UserProfileEntity userProfile;
  final WeeklyProgressEntity weeklyProgress;
  final List<HabitSummaryEntity> recentHabits;

  const DashboardEntity({
    required this.userProfile,
    required this.weeklyProgress,
    required this.recentHabits,
  });

  @override
  List<Object?> get props => [userProfile, weeklyProgress, recentHabits];
}

/// Entidad que representa el progreso semanal
class WeeklyProgressEntity extends Equatable {
  final List<int> dailyCompletions; // 7 días
  final double completionRate;
  final int totalCompletions;

  const WeeklyProgressEntity({
    required this.dailyCompletions,
    required this.completionRate,
    required this.totalCompletions,
  });

  @override
  List<Object?> get props => [dailyCompletions, completionRate, totalCompletions];
}

/// Entidad que representa un resumen de hábito
class HabitSummaryEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String category;
  final bool completedToday;
  final int currentStreak;
  final DateTime lastCompleted;

  const HabitSummaryEntity({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.completedToday,
    required this.currentStreak,
    required this.lastCompleted,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        completedToday,
        currentStreak,
        lastCompleted,
      ];
}

