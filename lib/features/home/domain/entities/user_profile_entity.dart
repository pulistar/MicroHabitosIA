import 'package:equatable/equatable.dart';

/// Entidad que representa el perfil del usuario con estadísticas de hábitos
class UserProfileEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime createdAt;
  final int totalHabits;
  final int completedToday;
  final int currentStreak;
  final int longestStreak;

  const UserProfileEntity({
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
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        isEmailVerified,
        createdAt,
        totalHabits,
        completedToday,
        currentStreak,
        longestStreak,
      ];
}
