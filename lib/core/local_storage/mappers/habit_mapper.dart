import '../../../features/microhabits/domain/entities/habit_entity.dart';
import '../models/cached_habit.dart';

/// Mapper para convertir entre HabitEntity y CachedHabit
class HabitMapper {
  /// Convierte HabitEntity a CachedHabit para guardar en caché
  static CachedHabit toCache(HabitEntity entity) {
    return CachedHabit(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      color: entity.color,
      icon: entity.icon,
      dailyGoal: entity.dailyGoal,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      totalCompletions: entity.totalCompletions,
      completedToday: entity.completedToday,
    );
  }

  /// Convierte CachedHabit a HabitEntity para usar en la app
  static HabitEntity fromCache(CachedHabit cached) {
    return HabitEntity(
      id: cached.id,
      userId: cached.userId,
      name: cached.name,
      description: cached.description,
      category: cached.category,
      color: cached.color,
      icon: cached.icon,
      dailyGoal: cached.dailyGoal,
      isActive: cached.isActive,
      createdAt: cached.createdAt,
      updatedAt: cached.updatedAt ?? cached.createdAt,
      currentStreak: cached.currentStreak,
      longestStreak: cached.longestStreak,
      totalCompletions: cached.totalCompletions,
      completedToday: cached.completedToday,
    );
  }

  /// Convierte lista de HabitEntity a lista de CachedHabit
  static List<CachedHabit> toCacheList(List<HabitEntity> entities) {
    return entities.map(toCache).toList();
  }

  /// Convierte lista de CachedHabit a lista de HabitEntity
  static List<HabitEntity> fromCacheList(List<CachedHabit> cached) {
    return cached.map(fromCache).toList();
  }
}
