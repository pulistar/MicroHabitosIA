import '../../../features/microhabits/domain/entities/habit_completion_entity.dart';
import '../models/cached_completion.dart';

/// Mapper para convertir entre HabitCompletionEntity y CachedCompletion
class CompletionMapper {
  /// Convierte HabitCompletionEntity a CachedCompletion para guardar en caché
  static CachedCompletion toCache(HabitCompletionEntity entity, {bool isSynced = true}) {
    return CachedCompletion(
      id: entity.id,
      habitId: entity.habitId,
      userId: entity.userId,
      completedAt: entity.completedAt,
      notes: entity.notes,
      createdAt: entity.createdAt,
      isSynced: isSynced,
    );
  }

  /// Convierte CachedCompletion a HabitCompletionEntity para usar en la app
  static HabitCompletionEntity fromCache(CachedCompletion cached) {
    return HabitCompletionEntity(
      id: cached.id,
      habitId: cached.habitId,
      userId: cached.userId,
      completedAt: cached.completedAt,
      notes: cached.notes,
      createdAt: cached.createdAt,
    );
  }

  /// Convierte lista de HabitCompletionEntity a lista de CachedCompletion
  static List<CachedCompletion> toCacheList(List<HabitCompletionEntity> entities, {bool isSynced = true}) {
    return entities.map((e) => toCache(e, isSynced: isSynced)).toList();
  }

  /// Convierte lista de CachedCompletion a lista de HabitCompletionEntity
  static List<HabitCompletionEntity> fromCacheList(List<CachedCompletion> cached) {
    return cached.map(fromCache).toList();
  }
}
