import 'package:hive/hive.dart';

part 'cached_user_profile.g.dart';

@HiveType(typeId: 3)
class CachedUserProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final bool isEmailVerified;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final int totalHabits;

  @HiveField(7)
  final int completedToday;

  @HiveField(8)
  final int currentStreak;

  @HiveField(9)
  final int longestStreak;

  @HiveField(10)
  final DateTime cachedAt;

  CachedUserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.isEmailVerified,
    required this.createdAt,
    required this.totalHabits,
    required this.completedToday,
    required this.currentStreak,
    required this.longestStreak,
    required this.cachedAt,
  });
}
