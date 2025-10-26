import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger_service.dart';
import '../models/user_profile_model.dart';

/// Interfaz para el datasource remoto del Home
abstract class HomeRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<Map<String, dynamic>> getDashboardData();
  Future<UserProfileModel> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });
  Future<void> logout();
}

/// Implementación del datasource remoto usando Supabase
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;

  HomeRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      LoggerService.apiCall('GET', '/user/profile');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener estadísticas reales de Supabase
      
      // 1. Obtener total de hábitos
      final habitsResponse = await supabaseClient
          .from('habits')
          .select('id, current_streak, longest_streak')
          .eq('user_id', user.id)
          .eq('is_active', true);

      final habits = habitsResponse as List;
      final totalHabits = habits.length;
      
      // 2. Obtener completitudes de hoy
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayCompletionsResponse = await supabaseClient
          .from('habit_completions')
          .select('id')
          .eq('user_id', user.id)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', endOfDay.toIso8601String());

      final completedToday = (todayCompletionsResponse as List).length;
      
      // 3. Calcular rachas
      final currentStreak = habits.fold<int>(
        0, 
        (max, habit) => math.max(max, habit['current_streak'] as int? ?? 0)
      );
      
      final longestStreak = habits.fold<int>(
        0, 
        (max, habit) => math.max(max, habit['longest_streak'] as int? ?? 0)
      );

      LoggerService.info('🏠 USER PROFILE REAL: Total=$totalHabits, Completados=$completedToday');

      final realProfile = UserProfileModel(
        id: user.id,
        email: user.email ?? 'usuario@ejemplo.com',
        displayName: user.userMetadata?['display_name'] as String? ?? 
                    user.userMetadata?['full_name'] as String? ?? 
                    'Usuario',
        photoUrl: user.userMetadata?['avatar_url'] as String?,
        isEmailVerified: user.emailConfirmedAt != null,
        createdAt: DateTime.parse(user.createdAt),
        totalHabits: totalHabits, // Real data
        completedToday: completedToday, // Real data
        currentStreak: currentStreak, // Real data
        longestStreak: longestStreak, // Real data
      );

      LoggerService.info('Perfil de usuario obtenido: ${realProfile.email}');
      return realProfile;
    } catch (e) {
      LoggerService.error('Error al obtener perfil de usuario: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      LoggerService.apiCall('GET', '/dashboard/data');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener datos reales de Supabase
      
      // 1. Obtener hábitos del usuario
      final habitsResponse = await supabaseClient
          .from('habits')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final habits = habitsResponse as List;
      final totalHabits = habits.length;
      
      LoggerService.info('🏠 REAL DATA: Total hábitos encontrados: $totalHabits');

      // 2. Obtener completitudes de hoy
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayCompletionsResponse = await supabaseClient
          .from('habit_completions')
          .select('habit_id')
          .eq('user_id', user.id)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', endOfDay.toIso8601String());

      final todayCompletions = (todayCompletionsResponse as List);
      final completedToday = todayCompletions.length;
      
      LoggerService.info('🏠 REAL DATA: Completados hoy: $completedToday');

      // 3. Calcular progreso semanal
      final weeklyCompletions = <int>[];
      int totalWeekCompletions = 0;
      
      for (int i = 6; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final dayCompletionsResponse = await supabaseClient
            .from('habit_completions')
            .select('id')
            .eq('user_id', user.id)
            .gte('completed_at', dayStart.toIso8601String())
            .lt('completed_at', dayEnd.toIso8601String());

        final dayCount = (dayCompletionsResponse as List).length;
        weeklyCompletions.add(dayCount);
        totalWeekCompletions += dayCount;
      }

      // 4. Calcular estadísticas generales
      final allCompletionsResponse = await supabaseClient
          .from('habit_completions')
          .select('id')
          .eq('user_id', user.id);

      final totalCompletions = (allCompletionsResponse as List).length;
      
      final longestStreak = habits.fold<int>(
        0, 
        (max, habit) => math.max(max, habit['longest_streak'] as int? ?? 0)
      );

      final completionRate = totalHabits > 0 && weeklyCompletions.isNotEmpty 
          ? totalWeekCompletions / (totalHabits * 7) 
          : 0.0;

      // 5. Preparar hábitos recientes con estado de completitud
      final recentHabits = <Map<String, dynamic>>[];
      
      for (final habit in habits.take(3)) {
        final habitCompletedToday = todayCompletions.any(
          (completion) => completion['habit_id'] == habit['id']
        );

        recentHabits.add({
          'id': habit['id'],
          'name': habit['name'],
          'description': habit['description'] ?? '',
          'category': habit['category'],
          'completed_today': habitCompletedToday,
          'current_streak': habit['current_streak'] ?? 0,
          'last_completed': habitCompletedToday 
              ? DateTime.now().toIso8601String()
              : habit['updated_at'],
        });
      }

      final realDashboard = {
        'weekly_progress': {
          'daily_completions': weeklyCompletions,
          'completion_rate': completionRate.clamp(0.0, 1.0),
          'total_completions': totalWeekCompletions,
        },
        'recent_habits': recentHabits,
        'statistics': {
          'total_habits': totalHabits,
          'completed_today': completedToday,
          'total_completions': totalCompletions,
          'longest_streak': longestStreak,
        },
      };

      LoggerService.info('🏠 DASHBOARD FINAL: Total=$totalHabits, Completados=$completedToday');
      LoggerService.info('Datos del dashboard obtenidos');
      return realDashboard;
    } catch (e) {
      LoggerService.error('Error al obtener datos del dashboard: $e');
      rethrow;
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      LoggerService.apiCall('PUT', '/user/profile');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Actualizar metadatos del usuario en Supabase
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (photoUrl != null) updates['avatar_url'] = photoUrl;

      if (updates.isNotEmpty) {
        await supabaseClient.auth.updateUser(
          UserAttributes(data: updates),
        );
      }

      // Retornar perfil actualizado
      final updatedProfile = await getUserProfile();
      LoggerService.info('Perfil actualizado exitosamente');
      return updatedProfile;
    } catch (e) {
      LoggerService.error('Error al actualizar perfil: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      LoggerService.auth('Cerrando sesión desde Home');
      await supabaseClient.auth.signOut();
      LoggerService.auth('Sesión cerrada desde Home');
    } catch (e) {
      LoggerService.error('Error al cerrar sesión desde Home: $e');
      rethrow;
    }
  }
}
