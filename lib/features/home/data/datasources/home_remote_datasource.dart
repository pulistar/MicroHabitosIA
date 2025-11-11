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

      // Obtener estadísticas reales de Supabase - OPTIMIZADO CON CONSULTAS PARALELAS
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      // Ejecutar consultas en paralelo
      final results = await Future.wait([
        // 0. Hábitos con rachas
        supabaseClient
            .from('habits')
            .select('id, current_streak, longest_streak')
            .eq('user_id', user.id)
            .eq('is_active', true),
        
        // 1. Completitudes de hoy
        supabaseClient
            .from('habit_completions')
            .select('id')
            .eq('user_id', user.id)
            .gte('completed_at', startOfDay.toIso8601String())
            .lt('completed_at', endOfDay.toIso8601String()),
      ]);
      
      final habits = results[0] as List;
      final todayCompletions = results[1] as List;
      
      final totalHabits = habits.length;
      final completedToday = todayCompletions.length;
      
      // Calcular rachas
      final currentStreak = habits.fold<int>(
        0, 
        (max, habit) => math.max(max, habit['current_streak'] as int? ?? 0)
      );
      
      final longestStreak = habits.fold<int>(
        0, 
        (max, habit) => math.max(max, habit['longest_streak'] as int? ?? 0)
      );

      LoggerService.info('✅ Perfil obtenido: Total=$totalHabits, Completados=$completedToday');

      return UserProfileModel(
        id: user.id,
        email: user.email ?? 'usuario@ejemplo.com',
        displayName: user.userMetadata?['display_name'] as String? ?? 
                    user.userMetadata?['full_name'] as String? ?? 
                    'Usuario',
        photoUrl: user.userMetadata?['avatar_url'] as String?,
        isEmailVerified: user.emailConfirmedAt != null,
        createdAt: DateTime.parse(user.createdAt),
        totalHabits: totalHabits,
        completedToday: completedToday,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );
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

      // Obtener datos reales de Supabase - OPTIMIZADO CON CONSULTAS PARALELAS
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    // Calcular el inicio de la semana (Lunes)
    final currentWeekday = today.weekday;
    final daysFromMonday = currentWeekday - 1;
    final monday = today.subtract(Duration(days: daysFromMonday));
    final mondayStart = DateTime(monday.year, monday.month, monday.day);
    final sundayEnd = mondayStart.add(const Duration(days: 7));
    
    // Ejecutar TODAS las consultas en PARALELO para máxima velocidad
    final results = await Future.wait([
      // 0. Hábitos del usuario
      supabaseClient
          .from('habits')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: false),
      
      // 1. Completitudes de hoy
      supabaseClient
          .from('habit_completions')
          .select('habit_id')
          .eq('user_id', user.id)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', endOfDay.toIso8601String()),
      
      // 2. Completitudes de la semana
      supabaseClient
          .from('habit_completions')
          .select('completed_at')
          .eq('user_id', user.id)
          .gte('completed_at', mondayStart.toIso8601String())
          .lt('completed_at', sundayEnd.toIso8601String()),
      
      // 3. Completitudes anteriores a esta semana
      supabaseClient
          .from('habit_completions')
          .select('id')
          .eq('user_id', user.id)
          .lt('completed_at', mondayStart.toIso8601String()),
    ]);
    
    // Procesar resultados
    final habits = results[0] as List;
    final todayCompletions = results[1] as List;
    final weekCompletions = results[2] as List;
    final previousCompletions = results[3] as List;
    
    final totalHabits = habits.length;
    final completedToday = todayCompletions.length;
    
    LoggerService.info('🏠 REAL DATA: Total hábitos=$totalHabits, Completados hoy=$completedToday');
    
    // Agrupar completitudes por día de la semana
    final weeklyCompletions = List<int>.filled(7, 0);
    int totalWeekCompletions = 0;
    
    for (final completion in weekCompletions) {
      final completedAt = DateTime.parse(completion['completed_at'] as String);
      final dayIndex = completedAt.difference(mondayStart).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        weeklyCompletions[dayIndex]++;
        totalWeekCompletions++;
      }
    }
    
    LoggerService.info('📅 Progreso semanal (L-D): $weeklyCompletions');
    
    final totalCompletions = previousCompletions.length + totalWeekCompletions;
      
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

      LoggerService.info('✅ Dashboard obtenido: Total=$totalHabits, Completados=$completedToday');
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
