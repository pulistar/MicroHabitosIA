import 'package:hive/hive.dart';

part 'cached_dashboard.g.dart';

@HiveType(typeId: 4)
class CachedDashboard extends HiveObject {
  @HiveField(0)
  final List<int> weeklyCompletions;

  @HiveField(1)
  final double completionRate;

  @HiveField(2)
  final int totalWeekCompletions;

  @HiveField(3)
  final List<CachedRecentHabit> recentHabits;

  @HiveField(4)
  final int totalHabits;

  @HiveField(5)
  final int completedToday;

  @HiveField(6)
  final int totalCompletions;

  @HiveField(7)
  final int longestStreak;

  @HiveField(8)
  final DateTime cachedAt;

  CachedDashboard({
    required this.weeklyCompletions,
    required this.completionRate,
    required this.totalWeekCompletions,
    required this.recentHabits,
    required this.totalHabits,
    required this.completedToday,
    required this.totalCompletions,
    required this.longestStreak,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
        'weekly_progress': {
          'daily_completions': weeklyCompletions,
          'completion_rate': completionRate,
          'total_completions': totalWeekCompletions,
        },
        'recent_habits': recentHabits.map((h) => h.toJson()).toList(),
        'statistics': {
          'total_habits': totalHabits,
          'completed_today': completedToday,
          'total_completions': totalCompletions,
          'longest_streak': longestStreak,
        },
      };
}

@HiveType(typeId: 5)
class CachedRecentHabit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final bool completedToday;

  @HiveField(5)
  final int currentStreak;

  @HiveField(6)
  final String? lastCompleted;

  CachedRecentHabit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.completedToday,
    required this.currentStreak,
    this.lastCompleted,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'completed_today': completedToday,
        'current_streak': currentStreak,
        'last_completed': lastCompleted,
      };

  factory CachedRecentHabit.fromJson(Map<String, dynamic> json) {
    return CachedRecentHabit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      completedToday: json['completed_today'] as bool,
      currentStreak: json['current_streak'] as int,
      lastCompleted: json['last_completed'] as String?,
    );
  }
}
