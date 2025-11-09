import '../../domain/entities/ranking_user_entity.dart';

/// Modelo de datos para un usuario en el ranking
class RankingUserModel extends RankingUserEntity {
  const RankingUserModel({
    required super.userId,
    required super.displayName,
    required super.weeklyCompletions,
    required super.currentStreak,
    required super.totalCompletions,
    required super.position,
  });

  factory RankingUserModel.fromJson(Map<String, dynamic> json, int position) {
    return RankingUserModel(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String? ?? 'Usuario',
      weeklyCompletions: json['weekly_completions'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      totalCompletions: json['total_completions'] as int? ?? 0,
      position: position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'weekly_completions': weeklyCompletions,
      'current_streak': currentStreak,
      'total_completions': totalCompletions,
      'position': position,
    };
  }
}
