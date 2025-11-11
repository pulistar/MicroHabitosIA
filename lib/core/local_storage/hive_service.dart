import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger_service.dart';
import 'models/cached_habit.dart';
import 'models/cached_completion.dart';
import 'models/sync_metadata.dart';
import 'models/cached_user_profile.dart';
import 'models/cached_dashboard.dart';
import 'models/cached_ranking.dart';

/// Servicio para gestionar caché local con Hive
class HiveService {
  static const String _habitsBox = 'habits';
  static const String _completionsBox = 'completions';
  static const String _metadataBox = 'metadata';
  static const String _userProfileBox = 'user_profile';
  static const String _dashboardBox = 'dashboard';
  static const String _rankingBox = 'ranking';

  // ==================== INITIALIZATION ====================

  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adapters
    Hive.registerAdapter(CachedHabitAdapter());
    Hive.registerAdapter(CachedCompletionAdapter());
    Hive.registerAdapter(SyncMetadataAdapter());
    Hive.registerAdapter(CachedUserProfileAdapter());
    Hive.registerAdapter(CachedDashboardAdapter());
    Hive.registerAdapter(CachedRecentHabitAdapter());
    Hive.registerAdapter(CachedRankingUserAdapter());

    // Abrir boxes
    await Hive.openBox<CachedHabit>(_habitsBox);
    await Hive.openBox<CachedCompletion>(_completionsBox);
    await Hive.openBox<SyncMetadata>(_metadataBox);
    await Hive.openBox<CachedUserProfile>(_userProfileBox);
    await Hive.openBox<CachedDashboard>(_dashboardBox);
    await Hive.openBox<CachedRankingUser>(_rankingBox);

    LoggerService.info('✅ Hive inicializado correctamente');
  }

  // ==================== HABITS ====================

  Box<CachedHabit> get _habitsBoxInstance => Hive.box<CachedHabit>(_habitsBox);

  Future<void> saveHabits(List<CachedHabit> habits) async {
    try {
      await _habitsBoxInstance.clear();
      for (final habit in habits) {
        await _habitsBoxInstance.put(habit.id, habit);
      }
      LoggerService.info('💾 ${habits.length} hábitos guardados en caché');
    } catch (e) {
      LoggerService.error('Error al guardar hábitos en caché: $e');
    }
  }

  Future<void> saveHabit(CachedHabit habit) async {
    try {
      await _habitsBoxInstance.put(habit.id, habit);
      LoggerService.info('💾 Hábito ${habit.name} guardado en caché');
    } catch (e) {
      LoggerService.error('Error al guardar hábito en caché: $e');
    }
  }

  List<CachedHabit> getHabits() {
    try {
      final habits = _habitsBoxInstance.values.toList();
      LoggerService.info('📦 ${habits.length} hábitos cargados de caché');
      return habits;
    } catch (e) {
      LoggerService.error('Error al cargar hábitos de caché: $e');
      return [];
    }
  }

  CachedHabit? getHabit(String habitId) {
    try {
      return _habitsBoxInstance.get(habitId);
    } catch (e) {
      LoggerService.error('Error al obtener hábito de caché: $e');
      return null;
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitsBoxInstance.delete(habitId);
      LoggerService.info('🗑️ Hábito eliminado de caché');
    } catch (e) {
      LoggerService.error('Error al eliminar hábito de caché: $e');
    }
  }

  bool hasHabits() {
    return _habitsBoxInstance.isNotEmpty;
  }

  // ==================== COMPLETIONS ====================

  Box<CachedCompletion> get _completionsBoxInstance =>
      Hive.box<CachedCompletion>(_completionsBox);

  Future<void> saveCompletion(CachedCompletion completion) async {
    try {
      await _completionsBoxInstance.put(completion.id, completion);
      LoggerService.info('💾 Completitud guardada en caché');
    } catch (e) {
      LoggerService.error('Error al guardar completitud en caché: $e');
    }
  }

  Future<void> saveCompletions(List<CachedCompletion> completions) async {
    try {
      for (final completion in completions) {
        await _completionsBoxInstance.put(completion.id, completion);
      }
      LoggerService.info('💾 ${completions.length} completitudes guardadas en caché');
    } catch (e) {
      LoggerService.error('Error al guardar completitudes en caché: $e');
    }
  }

  List<CachedCompletion> getCompletions({String? habitId}) {
    try {
      final completions = _completionsBoxInstance.values.toList();
      if (habitId != null) {
        return completions.where((c) => c.habitId == habitId).toList();
      }
      return completions;
    } catch (e) {
      LoggerService.error('Error al cargar completitudes de caché: $e');
      return [];
    }
  }

  List<CachedCompletion> getUnsyncedCompletions() {
    try {
      return _completionsBoxInstance.values
          .where((c) => !c.isSynced)
          .toList();
    } catch (e) {
      LoggerService.error('Error al obtener completitudes no sincronizadas: $e');
      return [];
    }
  }

  Future<void> deleteCompletion(String completionId) async {
    try {
      await _completionsBoxInstance.delete(completionId);
      LoggerService.info('🗑️ Completitud eliminada de caché');
    } catch (e) {
      LoggerService.error('Error al eliminar completitud de caché: $e');
    }
  }

  Future<void> clearOldCompletions({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final completions = _completionsBoxInstance.values.toList();
      
      for (final completion in completions) {
        if (completion.completedAt.isBefore(cutoffDate)) {
          await _completionsBoxInstance.delete(completion.id);
        }
      }
      
      LoggerService.info('🧹 Completitudes antiguas eliminadas');
    } catch (e) {
      LoggerService.error('Error al limpiar completitudes antiguas: $e');
    }
  }

  // ==================== METADATA ====================

  Box<SyncMetadata> get _metadataBoxInstance =>
      Hive.box<SyncMetadata>(_metadataBox);

  Future<void> saveSyncMetadata(SyncMetadata metadata) async {
    try {
      await _metadataBoxInstance.put(metadata.key, metadata);
      LoggerService.info('💾 Metadata de sincronización guardada');
    } catch (e) {
      LoggerService.error('Error al guardar metadata: $e');
    }
  }

  SyncMetadata? getSyncMetadata(String key) {
    try {
      return _metadataBoxInstance.get(key);
    } catch (e) {
      LoggerService.error('Error al obtener metadata: $e');
      return null;
    }
  }

  // ==================== CLEAR ALL ====================

  Future<void> clearAll() async {
    try {
      await _habitsBoxInstance.clear();
      await _completionsBoxInstance.clear();
      await _metadataBoxInstance.clear();
      await _userProfileBoxInstance.clear();
      await _dashboardBoxInstance.clear();
      await _rankingBoxInstance.clear();
      LoggerService.warning('🗑️ Toda la caché ha sido eliminada');
    } catch (e) {
      LoggerService.error('Error al limpiar caché: $e');
    }
  }

  Future<void> clearUserData() async {
    try {
      await _habitsBoxInstance.clear();
      await _completionsBoxInstance.clear();
      await _userProfileBoxInstance.clear();
      await _dashboardBoxInstance.clear();
      await _rankingBoxInstance.clear();
      LoggerService.info('🗑️ Datos de usuario eliminados de caché');
    } catch (e) {
      LoggerService.error('Error al limpiar datos de usuario: $e');
    }
  }

  Future<void> invalidateHabitsCache() async {
    try {
      await _habitsBoxInstance.clear();
      await _completionsBoxInstance.clear();
      // También invalidar dashboard y perfil porque dependen de los hábitos
      await _userProfileBoxInstance.clear();
      await _dashboardBoxInstance.clear();
      LoggerService.info('🔄 Caché de hábitos invalidado');
    } catch (e) {
      LoggerService.error('Error al invalidar caché de hábitos: $e');
    }
  }

  // ==================== STATS ====================

  Map<String, int> getCacheStats() {
    return {
      'habits': _habitsBoxInstance.length,
      'completions': _completionsBoxInstance.length,
      'unsyncedCompletions': getUnsyncedCompletions().length,
    };
  }

  // ==================== USER PROFILE ====================

  Box<CachedUserProfile> get _userProfileBoxInstance => Hive.box<CachedUserProfile>(_userProfileBox);

  Future<void> saveUserProfile(CachedUserProfile profile) async {
    try {
      await _userProfileBoxInstance.put('current', profile);
      LoggerService.info('💾 Perfil de usuario guardado en caché');
    } catch (e) {
      LoggerService.error('Error al guardar perfil en caché: $e');
    }
  }

  CachedUserProfile? getUserProfile() {
    try {
      return _userProfileBoxInstance.get('current');
    } catch (e) {
      LoggerService.error('Error al obtener perfil de caché: $e');
      return null;
    }
  }

  bool hasUserProfile() => _userProfileBoxInstance.containsKey('current');

  // ==================== DASHBOARD ====================

  Box<CachedDashboard> get _dashboardBoxInstance => Hive.box<CachedDashboard>(_dashboardBox);

  Future<void> saveDashboard(CachedDashboard dashboard) async {
    try {
      await _dashboardBoxInstance.put('current', dashboard);
      LoggerService.info('💾 Dashboard guardado en caché');
    } catch (e) {
      LoggerService.error('Error al guardar dashboard en caché: $e');
    }
  }

  CachedDashboard? getDashboard() {
    try {
      return _dashboardBoxInstance.get('current');
    } catch (e) {
      LoggerService.error('Error al obtener dashboard de caché: $e');
      return null;
    }
  }

  bool hasDashboard() => _dashboardBoxInstance.containsKey('current');

  // ==================== RANKING ====================

  Box<CachedRankingUser> get _rankingBoxInstance => Hive.box<CachedRankingUser>(_rankingBox);

  Future<void> saveRanking(List<CachedRankingUser> users) async {
    try {
      await _rankingBoxInstance.clear();
      for (int i = 0; i < users.length; i++) {
        await _rankingBoxInstance.put('user_$i', users[i]);
      }
      LoggerService.info('💾 ${users.length} usuarios del ranking guardados en caché');
    } catch (e) {
      LoggerService.error('Error al guardar ranking en caché: $e');
    }
  }

  List<CachedRankingUser> getRanking() {
    try {
      return _rankingBoxInstance.values.toList();
    } catch (e) {
      LoggerService.error('Error al obtener ranking de caché: $e');
      return [];
    }
  }

  bool hasRanking() => _rankingBoxInstance.isNotEmpty;
}
