import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger_service.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';
import '../models/temporary_progress_model.dart';
import '../../domain/entities/habit_category_entity.dart';

/// Interfaz para el datasource remoto de hábitos
abstract class HabitsRemoteDataSource {
  Future<List<HabitModel>> getUserHabits();
  Future<HabitModel> getHabitById(String habitId);
  Future<HabitModel> createHabit({
    required String name,
    String? description,
    required String category,
    required String color,
    required String icon,
    int dailyGoal = 1,
  });
  Future<HabitModel> updateHabit({
    required String habitId,
    String? name,
    String? description,
    String? category,
    String? color,
    String? icon,
    bool? isActive,
    int? dailyGoal,
  });
  Future<void> deleteHabit(String habitId);
  Future<HabitCompletionModel> completeHabit({
    required String habitId,
    String? notes,
  });
  Future<void> uncompleteHabit(String habitId);
  Future<List<HabitCompletionModel>> getHabitCompletions({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<bool> isHabitCompletedOnDate({
    required String habitId,
    required DateTime date,
  });
  Future<List<HabitCategoryEntity>> getCategories();
  Future<Map<String, dynamic>> getUserStatistics();
  Future<List<int>> getWeeklyProgress();
  
  // Temporary progress methods
  Future<Map<String, int>> getTemporaryProgress();
  Future<TemporaryProgressModel> saveTemporaryProgress({
    required String habitId,
    required int tempCount,
  });
  Future<void> clearTemporaryProgress(String habitId);
  Future<void> cleanupOldTemporaryProgress();
}

/// Implementación del datasource remoto usando Supabase
class HabitsRemoteDataSourceImpl implements HabitsRemoteDataSource {
  final SupabaseClient supabaseClient;

  HabitsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<HabitModel>> getUserHabits() async {
    try {
      LoggerService.apiCall('GET', '/habits');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener hábitos desde Supabase
      final response = await supabaseClient
          .from('habits')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final habitsData = response as List;
      
      // Calcular completitudes de hoy para cada hábito
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final habits = <HabitModel>[];
      
      for (final habitJson in habitsData) {
        // Obtener completitudes de hoy para este hábito
        final completionsResponse = await supabaseClient
            .from('habit_completions')
            .select('id')
            .eq('habit_id', habitJson['id'])
            .eq('user_id', user.id)
            .gte('completed_at', startOfDay.toIso8601String())
            .lt('completed_at', endOfDay.toIso8601String());

        final completedToday = (completionsResponse as List).length;
        
        // Crear el modelo con las completitudes de hoy
        final habitWithCompletions = Map<String, dynamic>.from(habitJson);
        habitWithCompletions['completed_today'] = completedToday;
        
        habits.add(HabitModel.fromJson(habitWithCompletions));
      }
      
      LoggerService.info('Hábitos obtenidos: ${habits.length}');
      return habits;
    } catch (e) {
      LoggerService.error('Error al obtener hábitos: $e');
      rethrow;
    }
  }

  @override
  Future<HabitModel> getHabitById(String habitId) async {
    try {
      LoggerService.apiCall('GET', '/habits/$habitId');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await supabaseClient
          .from('habits')
          .select()
          .eq('id', habitId)
          .eq('user_id', user.id)
          .single();

      return HabitModel.fromJson(response);
    } catch (e) {
      LoggerService.error('Error al obtener hábito: $e');
      rethrow;
    }
  }

  @override
  Future<HabitModel> createHabit({
    required String name,
    String? description,
    required String category,
    required String color,
    required String icon,
    int dailyGoal = 1,
  }) async {
    try {
      LoggerService.apiCall('POST', '/habits');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Crear hábito en Supabase
      final response = await supabaseClient
          .from('habits')
          .insert({
            'user_id': user.id,
            'name': name,
            'description': description,
            'category': category,
            'color': color,
            'icon': icon,
            'is_active': true,
            'current_streak': 0,
            'longest_streak': 0,
            'total_completions': 0,
            'daily_goal': dailyGoal,
          })
          .select()
          .single();

      final newHabit = HabitModel.fromJson(response);
      
      LoggerService.info('Hábito creado: ${newHabit.name}');
      return newHabit;
    } catch (e) {
      LoggerService.error('Error al crear hábito: $e');
      rethrow;
    }
  }

  @override
  Future<HabitModel> updateHabit({
    required String habitId,
    String? name,
    String? description,
    String? category,
    String? color,
    String? icon,
    bool? isActive,
    int? dailyGoal,
  }) async {
    try {
      LoggerService.apiCall('PUT', '/habits/$habitId');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (color != null) updateData['color'] = color;
      if (icon != null) updateData['icon'] = icon;
      if (isActive != null) updateData['is_active'] = isActive;
      if (dailyGoal != null) updateData['daily_goal'] = dailyGoal;

      final response = await supabaseClient
          .from('habits')
          .update(updateData)
          .eq('id', habitId)
          .eq('user_id', user.id)
          .select()
          .single();

      return HabitModel.fromJson(response);
    } catch (e) {
      LoggerService.error('Error al actualizar hábito: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      LoggerService.apiCall('DELETE', '/habits/$habitId');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await supabaseClient
          .from('habits')
          .delete()
          .eq('id', habitId)
          .eq('user_id', user.id);

      LoggerService.info('Hábito eliminado: $habitId');
    } catch (e) {
      LoggerService.error('Error al eliminar hábito: $e');
      rethrow;
    }
  }

  @override
  Future<HabitCompletionModel> completeHabit({
    required String habitId,
    String? notes,
  }) async {
    try {
      LoggerService.apiCall('POST', '/habits/$habitId/complete');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Crear completitud
      final response = await supabaseClient
          .from('habit_completions')
          .insert({
            'habit_id': habitId,
            'user_id': user.id,
            'notes': notes,
          })
          .select()
          .single();

      // Actualizar estadísticas del hábito
      await _updateHabitStats(habitId);

      return HabitCompletionModel.fromJson(response);
    } catch (e) {
      LoggerService.error('Error al completar hábito: $e');
      rethrow;
    }
  }

  @override
  Future<void> uncompleteHabit(String habitId) async {
    try {
      LoggerService.apiCall('DELETE', '/habits/$habitId/complete');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Eliminar completitud de hoy
      await supabaseClient
          .from('habit_completions')
          .delete()
          .eq('habit_id', habitId)
          .eq('user_id', user.id)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', endOfDay.toIso8601String());

      // Actualizar estadísticas del hábito
      await _updateHabitStats(habitId);

      LoggerService.info('Hábito descompletado: $habitId');
    } catch (e) {
      LoggerService.error('Error al descompletar hábito: $e');
      rethrow;
    }
  }

  @override
  Future<List<HabitCompletionModel>> getHabitCompletions({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      LoggerService.apiCall('GET', '/habits/$habitId/completions');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await supabaseClient
          .from('habit_completions')
          .select()
          .eq('habit_id', habitId)
          .eq('user_id', user.id)
          .gte('completed_at', startDate.toIso8601String())
          .lte('completed_at', endDate.toIso8601String())
          .order('completed_at', ascending: false);

      return (response as List)
          .map((json) => HabitCompletionModel.fromJson(json))
          .toList();
    } catch (e) {
      LoggerService.error('Error al obtener completitudes: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isHabitCompletedOnDate({
    required String habitId,
    required DateTime date,
  }) async {
    try {
      LoggerService.apiCall('GET', '/habits/$habitId/completed');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await supabaseClient
          .from('habit_completions')
          .select('id')
          .eq('habit_id', habitId)
          .eq('user_id', user.id)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', endOfDay.toIso8601String())
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      LoggerService.error('Error al verificar completitud: $e');
      rethrow;
    }
  }

  @override
  Future<List<HabitCategoryEntity>> getCategories() async {
    try {
      LoggerService.apiCall('GET', '/categories');
      
      // Obtener categorías desde Supabase
      final response = await supabaseClient
          .from('habit_categories')
          .select()
          .order('name', ascending: true);

      final categories = (response as List)
          .map((json) => HabitCategoryEntity(
                id: json['id'] as String,
                name: json['name'] as String,
                color: json['color'] as String,
                icon: json['icon'] as String,
                isDefault: true, // Todas las categorías de la DB son por defecto
              ))
          .toList();
      
      LoggerService.info('Categorías obtenidas: ${categories.length}');
      return categories;
    } catch (e) {
      LoggerService.error('Error al obtener categorías: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      LoggerService.apiCall('GET', '/users/statistics');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener estadísticas básicas
      final habitsResponse = await supabaseClient
          .from('habits')
          .select('id, total_completions, current_streak, longest_streak')
          .eq('user_id', user.id)
          .eq('is_active', true);

      final habits = habitsResponse as List;
      final totalHabits = habits.length;
      final totalCompletions = habits.fold<int>(
        0, 
        (sum, habit) => sum + (habit['total_completions'] as int? ?? 0)
      );
      final maxStreak = habits.fold<int>(
        0, 
        (max, habit) => math.max(max, habit['longest_streak'] as int? ?? 0)
      );

      // Hábitos completados hoy
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayCompletionsResponse = await supabaseClient
          .from('habit_completions')
          .select('habit_id')
          .eq('user_id', user.id)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', endOfDay.toIso8601String());

      final completedToday = (todayCompletionsResponse as List).length;

      return {
        'totalHabits': totalHabits,
        'completedToday': completedToday,
        'totalCompletions': totalCompletions,
        'longestStreak': maxStreak,
      };
    } catch (e) {
      LoggerService.error('Error al obtener estadísticas: $e');
      rethrow;
    }
  }

  @override
  Future<List<int>> getWeeklyProgress() async {
    try {
      LoggerService.apiCall('GET', '/users/weekly-progress');
      
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final now = DateTime.now();
      final weekProgress = <int>[];

      // Obtener progreso de los últimos 7 días
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final response = await supabaseClient
            .from('habit_completions')
            .select('id')
            .eq('user_id', user.id)
            .gte('completed_at', startOfDay.toIso8601String())
            .lt('completed_at', endOfDay.toIso8601String());

        weekProgress.add((response as List).length);
      }

      return weekProgress;
    } catch (e) {
      LoggerService.error('Error al obtener progreso semanal: $e');
      rethrow;
    }
  }

  // Método auxiliar para actualizar estadísticas del hábito
  Future<void> _updateHabitStats(String habitId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return;

      // Obtener todas las completitudes del hábito
      final completionsResponse = await supabaseClient
          .from('habit_completions')
          .select('completed_at')
          .eq('habit_id', habitId)
          .eq('user_id', user.id)
          .order('completed_at', ascending: true);

      final completions = completionsResponse as List;
      final totalCompletions = completions.length;

      // Calcular racha actual y más larga
      int currentStreak = 0;
      int longestStreak = 0;
      int tempStreak = 0;

      if (completions.isNotEmpty) {
        DateTime? lastDate;
        
        for (final completion in completions.reversed) {
          final completedAt = DateTime.parse(completion['completed_at']);
          final completedDate = DateTime(completedAt.year, completedAt.month, completedAt.day);
          
          if (lastDate == null) {
            tempStreak = 1;
            final today = DateTime.now();
            final todayDate = DateTime(today.year, today.month, today.day);
            
            if (completedDate == todayDate || completedDate == todayDate.subtract(const Duration(days: 1))) {
              currentStreak = 1;
            }
          } else {
            final daysDiff = lastDate.difference(completedDate).inDays;
            if (daysDiff == 1) {
              tempStreak++;
              if (currentStreak > 0) currentStreak++;
            } else {
              longestStreak = math.max(longestStreak, tempStreak);
              tempStreak = 1;
              if (currentStreak > 0 && daysDiff > 1) currentStreak = 0;
            }
          }
          
          lastDate = completedDate;
        }
        
        longestStreak = math.max(longestStreak, tempStreak);
      }

      // Actualizar estadísticas en la base de datos
      await supabaseClient
          .from('habits')
          .update({
            'total_completions': totalCompletions,
            'current_streak': currentStreak,
            'longest_streak': longestStreak,
          })
          .eq('id', habitId)
          .eq('user_id', user.id);

    } catch (e) {
      LoggerService.error('Error al actualizar estadísticas del hábito: $e');
    }
  }

  // ==================== TEMPORARY PROGRESS ====================

  /// Obtiene el progreso temporal de todos los hábitos del usuario para hoy
  Future<Map<String, int>> getTemporaryProgress() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await supabaseClient
          .from('temporary_progress')
          .select('habit_id, temp_count')
          .eq('user_id', user.id)
          .eq('date', today);

      final Map<String, int> progressMap = {};
      for (final item in response as List) {
        progressMap[item['habit_id'] as String] = item['temp_count'] as int;
      }

      LoggerService.info('Progreso temporal cargado: ${progressMap.length} hábitos');
      return progressMap;
    } catch (e) {
      LoggerService.error('Error al obtener progreso temporal: $e');
      return {};
    }
  }

  /// Guarda o actualiza el progreso temporal de un hábito
  Future<TemporaryProgressModel> saveTemporaryProgress({
    required String habitId,
    required int tempCount,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Intentar actualizar primero
    final updateResponse = await supabaseClient
        .from('temporary_progress')
        .update({'temp_count': tempCount})
        .eq('user_id', user.id)
        .eq('habit_id', habitId)
        .eq('date', today)
        .select();

    if ((updateResponse as List).isNotEmpty) {
      // Actualización exitosa
      LoggerService.info('Progreso temporal actualizado: $habitId -> $tempCount');
      return TemporaryProgressModel.fromJson(updateResponse.first);
    } else {
      // Insertar nuevo registro
      final insertResponse = await supabaseClient
          .from('temporary_progress')
          .insert({
            'user_id': user.id,
            'habit_id': habitId,
            'temp_count': tempCount,
            'date': today,
          })
          .select()
          .single();

      LoggerService.info('Progreso temporal creado: $habitId -> $tempCount');
      return TemporaryProgressModel.fromJson(insertResponse);
    }
  }

  /// Elimina el progreso temporal de un hábito
  Future<void> clearTemporaryProgress(String habitId) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await supabaseClient
        .from('temporary_progress')
        .delete()
        .eq('user_id', user.id)
        .eq('habit_id', habitId)
        .eq('date', today);

    LoggerService.info('Progreso temporal limpiado: $habitId');
  }

  /// Limpia todo el progreso temporal del día anterior
  Future<void> cleanupOldTemporaryProgress() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr = yesterday.toIso8601String().split('T')[0];
    
    await supabaseClient
        .from('temporary_progress')
        .delete()
        .eq('user_id', user.id)
        .lt('date', yesterdayStr);

    LoggerService.info('Progreso temporal antiguo limpiado');
  }
}
