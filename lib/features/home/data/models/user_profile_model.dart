import '../../domain/entities/user_profile_entity.dart';

/// Modelo de datos para el perfil del usuario
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.isEmailVerified,
    required super.createdAt,
    required super.totalHabits,
    required super.completedToday,
    required super.currentStreak,
    required super.longestStreak,
  });

  /// Crea un UserProfileModel desde JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      isEmailVerified: json['email_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalHabits: json['total_habits'] as int? ?? 0,
      completedToday: json['completed_today'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'email_verified': isEmailVerified,
      'created_at': createdAt.toIso8601String(),
      'total_habits': totalHabits,
      'completed_today': completedToday,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }

  /// Crea una copia con campos actualizados
  UserProfileModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    int? totalHabits,
    int? completedToday,
    int? currentStreak,
    int? longestStreak,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      totalHabits: totalHabits ?? this.totalHabits,
      completedToday: completedToday ?? this.completedToday,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }
}
