import 'package:hive/hive.dart';

part 'cached_ranking.g.dart';

@HiveType(typeId: 6)
class CachedRankingUser extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  final String? photoUrl;

  @HiveField(3)
  final int totalCompletions;

  @HiveField(4)
  final int currentStreak;

  @HiveField(5)
  final int rank;

  @HiveField(6)
  final DateTime cachedAt;

  CachedRankingUser({
    required this.id,
    required this.displayName,
    this.photoUrl,
    required this.totalCompletions,
    required this.currentStreak,
    required this.rank,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'photo_url': photoUrl,
        'total_completions': totalCompletions,
        'current_streak': currentStreak,
        'rank': rank,
      };
}
