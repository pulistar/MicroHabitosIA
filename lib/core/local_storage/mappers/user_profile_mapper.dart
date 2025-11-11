import '../../../features/home/data/models/user_profile_model.dart';
import '../models/cached_user_profile.dart';

class UserProfileMapper {
  /// Convierte UserProfileModel a CachedUserProfile para guardar en caché
  static CachedUserProfile toCache(UserProfileModel model) {
    return CachedUserProfile(
      id: model.id,
      email: model.email,
      displayName: model.displayName,
      photoUrl: model.photoUrl,
      isEmailVerified: model.isEmailVerified,
      createdAt: model.createdAt,
      totalHabits: model.totalHabits,
      completedToday: model.completedToday,
      currentStreak: model.currentStreak,
      longestStreak: model.longestStreak,
      cachedAt: DateTime.now(),
    );
  }

  /// Convierte CachedUserProfile a UserProfileModel para usar en la app
  static UserProfileModel fromCache(CachedUserProfile cached) {
    return UserProfileModel(
      id: cached.id,
      email: cached.email,
      displayName: cached.displayName,
      photoUrl: cached.photoUrl,
      isEmailVerified: cached.isEmailVerified,
      createdAt: cached.createdAt,
      totalHabits: cached.totalHabits,
      completedToday: cached.completedToday,
      currentStreak: cached.currentStreak,
      longestStreak: cached.longestStreak,
    );
  }
}
