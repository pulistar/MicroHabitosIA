import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger_service.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

/// Implementación del repository del Home
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      LoggerService.startOperation('getUserProfile');
      final userProfile = await remoteDataSource.getUserProfile();
      LoggerService.endOperation('getUserProfile');
      return Right(userProfile);
    } catch (e) {
      LoggerService.error('Error en getUserProfile: $e');
      return Left(ServerFailure('Error al obtener perfil del usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, DashboardEntity>> getDashboardData() async {
    try {
      LoggerService.startOperation('getDashboardData');
      
      // Obtener perfil del usuario
      final userProfileResult = await getUserProfile();
      if (userProfileResult.isLeft()) {
        return Left(ServerFailure('Error al obtener perfil del usuario'));
      }
      
      final userProfile = userProfileResult.getOrElse(() => throw Exception());
      
      // Obtener datos del dashboard
      final dashboardData = await remoteDataSource.getDashboardData();
      
      // Construir entidades
      final weeklyProgress = WeeklyProgressEntity(
        dailyCompletions: List<int>.from(dashboardData['weekly_progress']['daily_completions']),
        completionRate: dashboardData['weekly_progress']['completion_rate'].toDouble(),
        totalCompletions: dashboardData['weekly_progress']['total_completions'],
      );
      
      final recentHabits = (dashboardData['recent_habits'] as List)
          .map((habit) => HabitSummaryEntity(
                id: habit['id'],
                name: habit['name'],
                description: habit['description'],
                category: habit['category'],
                completedToday: habit['completed_today'],
                currentStreak: habit['current_streak'],
                lastCompleted: DateTime.parse(habit['last_completed']),
              ))
          .toList();
      
      final dashboard = DashboardEntity(
        userProfile: userProfile,
        weeklyProgress: weeklyProgress,
        recentHabits: recentHabits,
      );
      
      LoggerService.endOperation('getDashboardData');
      return Right(dashboard);
    } catch (e) {
      LoggerService.error('Error en getDashboardData: $e');
      return Left(ServerFailure('Error al obtener datos del dashboard: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      LoggerService.startOperation('updateUserProfile');
      final updatedProfile = await remoteDataSource.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      LoggerService.endOperation('updateUserProfile');
      return Right(updatedProfile);
    } catch (e) {
      LoggerService.error('Error en updateUserProfile: $e');
      return Left(ServerFailure('Error al actualizar perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      LoggerService.startOperation('logout');
      await remoteDataSource.logout();
      LoggerService.endOperation('logout');
      return const Right(null);
    } catch (e) {
      LoggerService.error('Error en logout: $e');
      return Left(ServerFailure('Error al cerrar sesión: $e'));
    }
  }
}
