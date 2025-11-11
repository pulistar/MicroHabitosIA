import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger_service.dart';
import '../models/ranking_user_model.dart';

abstract class RankingRemoteDataSource {
  /// Obtiene el ranking de usuarios por completitudes semanales
  Future<List<RankingUserModel>> getWeeklyRanking({int limit = 50});
  
  /// Obtiene la posición del usuario actual en el ranking
  Future<RankingUserModel?> getCurrentUserRanking();
}

class RankingRemoteDataSourceImpl implements RankingRemoteDataSource {
  final SupabaseClient supabaseClient;

  RankingRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<RankingUserModel>> getWeeklyRanking({int limit = 50}) async {
    try {
      LoggerService.apiCall('GET', '/ranking/weekly');

      // Calcular el inicio de la semana (Lunes)
      final now = DateTime.now();
      final currentWeekday = now.weekday; // 1 = Lunes, 7 = Domingo
      final daysFromMonday = currentWeekday - 1;
      final monday = now.subtract(Duration(days: daysFromMonday));
      final mondayStart = DateTime(monday.year, monday.month, monday.day);

      // Obtener usuario actual
      final currentUser = supabaseClient.auth.currentUser;
      LoggerService.info('👤 Usuario actual: ${currentUser?.id.substring(0, 8)}... (${currentUser?.email})');
      
      // Obtener TODOS los usuarios que tienen hábitos
      final allHabitsResponse = await supabaseClient
          .from('habits')
          .select('user_id');

      LoggerService.info('🔍 Total de hábitos en BD: ${(allHabitsResponse as List).length}');

      // Obtener IDs únicos de usuarios
      final Set<String> allUserIds = {};
      for (var habit in allHabitsResponse) {
        allUserIds.add(habit['user_id'] as String);
      }

      LoggerService.info('👥 Usuarios únicos con hábitos: ${allUserIds.length}');
      for (var userId in allUserIds) {
        LoggerService.info('  - Usuario ID: ${userId.substring(0, 8)}...');
      }

      if (allUserIds.isEmpty) {
        return [];
      }

      // Obtener completitudes de la semana actual para cada usuario
      final completionsResponse = await supabaseClient
          .from('habit_completions')
          .select('user_id')
          .gte('completed_at', mondayStart.toIso8601String());

      // Contar completitudes por usuario
      final Map<String, int> userCompletions = {};
      for (var userId in allUserIds) {
        userCompletions[userId] = 0; // Inicializar en 0
      }
      
      for (var completion in completionsResponse as List) {
        final userId = completion['user_id'] as String;
        if (userCompletions.containsKey(userId)) {
          userCompletions[userId] = (userCompletions[userId] ?? 0) + 1;
        }
      }

      // Obtener información adicional de cada usuario (racha, total y nombre)
      final Map<String, Map<String, dynamic>> userStats = {};
      for (var userId in userCompletions.keys) {
        // Obtener hábitos del usuario para calcular estadísticas
        final habitsResponse = await supabaseClient
            .from('habits')
            .select('current_streak, total_completions')
            .eq('user_id', userId);

        int maxStreak = 0;
        int totalCompletions = 0;
        
        for (var habit in habitsResponse as List) {
          final streak = habit['current_streak'] as int? ?? 0;
          final completions = habit['total_completions'] as int? ?? 0;
          if (streak > maxStreak) maxStreak = streak;
          totalCompletions += completions;
        }

        // Obtener el nombre del usuario desde user_profiles
        String displayName = 'Usuario ${userId.substring(0, 8)}';
        try {
          final profileResponse = await supabaseClient
              .from('user_profiles')
              .select('display_name, email')
              .eq('id', userId)
              .maybeSingle();
          
          if (profileResponse != null) {
            // Prioridad: display_name > email (sin @dominio) > ID
            if (profileResponse['display_name'] != null && 
                (profileResponse['display_name'] as String).trim().isNotEmpty) {
              displayName = profileResponse['display_name'] as String;
            } else if (profileResponse['email'] != null) {
              // Usar la parte antes del @ del email
              final email = profileResponse['email'] as String;
              final username = email.split('@').first;
              displayName = username;
            }
          }
        } catch (e) {
          // Si no existe el perfil, usar el ID corto
          displayName = 'Usuario ${userId.substring(0, 8)}';
        }

        userStats[userId] = {
          'current_streak': maxStreak,
          'total_completions': totalCompletions,
          'display_name': displayName,
        };
        
        LoggerService.info('👤 Usuario ${userId.substring(0, 8)}: "$displayName"');
      }

      // Crear lista de usuarios con sus completitudes semanales
      final List<Map<String, dynamic>> rankingData = [];
      final currentUserId = supabaseClient.auth.currentUser?.id;
      
      for (var entry in userCompletions.entries) {
        final userId = entry.key;
        final weeklyCompletions = entry.value;
        final stats = userStats[userId] ?? {
          'current_streak': 0, 
          'total_completions': 0,
          'display_name': 'Usuario ${userId.substring(0, 8)}'
        };

        // Usar "Tú" para el usuario actual, o el nombre real del perfil
        final displayName = userId == currentUserId 
            ? 'Tú' 
            : (stats['display_name'] as String);

        rankingData.add({
          'user_id': userId,
          'display_name': displayName,
          'weekly_completions': weeklyCompletions,
          'current_streak': stats['current_streak'],
          'total_completions': stats['total_completions'],
        });
      }

      // Ordenar por completitudes semanales (descendente)
      rankingData.sort((a, b) => 
        (b['weekly_completions'] as int).compareTo(a['weekly_completions'] as int)
      );

      // Limitar resultados
      final limitedData = rankingData.take(limit).toList();

      // Convertir a modelos con posición
      final ranking = limitedData.asMap().entries.map((entry) {
        return RankingUserModel.fromJson(entry.value, entry.key + 1);
      }).toList();

      LoggerService.info('Ranking obtenido: ${ranking.length} usuarios');
      return ranking;
    } catch (e) {
      LoggerService.error('Error al obtener ranking', e);
      rethrow;
    }
  }

  @override
  Future<RankingUserModel?> getCurrentUserRanking() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el ranking completo
      final ranking = await getWeeklyRanking(limit: 1000);

      // Buscar al usuario actual
      final currentUserRanking = ranking.firstWhere(
        (r) => r.userId == user.id,
        orElse: () => RankingUserModel(
          userId: user.id,
          displayName: user.userMetadata?['display_name'] ?? 'Tú',
          weeklyCompletions: 0,
          currentStreak: 0,
          totalCompletions: 0,
          position: ranking.length + 1,
        ),
      );

      return currentUserRanking;
    } catch (e) {
      LoggerService.error('Error al obtener ranking del usuario actual', e);
      return null;
    }
  }
}
