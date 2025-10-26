import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';
import '../entities/dashboard_entity.dart';

/// Repository abstracto para el Home feature
abstract class HomeRepository {
  /// Obtiene el perfil del usuario actual
  Future<Either<Failure, UserProfileEntity>> getUserProfile();

  /// Obtiene los datos del dashboard
  Future<Either<Failure, DashboardEntity>> getDashboardData();

  /// Actualiza el perfil del usuario
  Future<Either<Failure, UserProfileEntity>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Cierra la sesión del usuario
  Future<Either<Failure, void>> logout();
}
