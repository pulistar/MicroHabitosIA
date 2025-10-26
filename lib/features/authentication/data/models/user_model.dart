import '../../../authentication/domain/entities/user_entity.dart';

/// Modelo de usuario para mapeo de datos
class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    required bool isEmailVerified,
    required DateTime createdAt,
  }) : super(
    id: id,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    isEmailVerified: isEmailVerified,
    createdAt: createdAt,
  );

  /// Convertir desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['user_metadata']?['display_name'] as String?,
      photoUrl: json['user_metadata']?['avatar_url'] as String?,
      isEmailVerified: json['email_confirmed_at'] != null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': photoUrl,
      'email_confirmed_at': isEmailVerified ? DateTime.now().toIso8601String() : null,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
