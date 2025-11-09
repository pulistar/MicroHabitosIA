import 'package:equatable/equatable.dart';

/// Entidad que representa un usuario en el ranking
class RankingUserEntity extends Equatable {
  final String userId;
  final String displayName;
  final int weeklyCompletions;
  final int currentStreak;
  final int totalCompletions;
  final int position;

  const RankingUserEntity({
    required this.userId,
    required this.displayName,
    required this.weeklyCompletions,
    required this.currentStreak,
    required this.totalCompletions,
    required this.position,
  });

  @override
  List<Object?> get props => [
        userId,
        displayName,
        weeklyCompletions,
        currentStreak,
        totalCompletions,
        position,
      ];
}
