import '../models/cached_dashboard.dart';

class DashboardMapper {
  /// Convierte Map<String, dynamic> a CachedDashboard para guardar en caché
  static CachedDashboard toCache(Map<String, dynamic> data) {
    final weeklyProgress = data['weekly_progress'] as Map<String, dynamic>;
    final statistics = data['statistics'] as Map<String, dynamic>;
    final recentHabitsData = data['recent_habits'] as List;

    return CachedDashboard(
      weeklyCompletions: List<int>.from(weeklyProgress['daily_completions']),
      completionRate: (weeklyProgress['completion_rate'] as num).toDouble(),
      totalWeekCompletions: weeklyProgress['total_completions'] as int,
      recentHabits: recentHabitsData
          .map((h) => CachedRecentHabit.fromJson(h as Map<String, dynamic>))
          .toList(),
      totalHabits: statistics['total_habits'] as int,
      completedToday: statistics['completed_today'] as int,
      totalCompletions: statistics['total_completions'] as int,
      longestStreak: statistics['longest_streak'] as int,
      cachedAt: DateTime.now(),
    );
  }

  /// Convierte CachedDashboard a Map<String, dynamic> para usar en la app
  static Map<String, dynamic> fromCache(CachedDashboard cached) {
    return cached.toJson();
  }
}
