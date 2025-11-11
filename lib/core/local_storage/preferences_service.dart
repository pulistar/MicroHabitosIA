import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger_service.dart';

/// Servicio para gestionar preferencias del usuario con SharedPreferences
class PreferencesService {
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyLastSyncTime = 'last_sync_time';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyReminderTime = 'reminder_time';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyLongestStreak = 'longest_streak';
  static const String _keyTotalCompletions = 'total_completions';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // ==================== FIRST LAUNCH ====================

  bool get isFirstLaunch => _prefs.getBool(_keyFirstLaunch) ?? true;

  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(_keyFirstLaunch, false);
    LoggerService.info('Primera apertura marcada como completada');
  }

  // ==================== ONBOARDING ====================

  bool get isOnboardingCompleted =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
    LoggerService.info('Onboarding completado');
  }

  // ==================== SYNC ====================

  DateTime? get lastSyncTime {
    final timestamp = _prefs.getString(_keyLastSyncTime);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setString(_keyLastSyncTime, time.toIso8601String());
    LoggerService.info('Última sincronización: ${time.toIso8601String()}');
  }

  // ==================== NOTIFICATIONS ====================

  bool get notificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? true;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
    LoggerService.info('Notificaciones: ${enabled ? "activadas" : "desactivadas"}');
  }

  // ==================== REMINDER TIME ====================

  String get reminderTime => _prefs.getString(_keyReminderTime) ?? '09:00';

  Future<void> setReminderTime(String time) async {
    await _prefs.setString(_keyReminderTime, time);
    LoggerService.info('Hora de recordatorio: $time');
  }

  // ==================== THEME ====================

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'dark';

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
    LoggerService.info('Tema: $mode');
  }

  // ==================== LANGUAGE ====================

  String get language => _prefs.getString(_keyLanguage) ?? 'es';

  Future<void> setLanguage(String lang) async {
    await _prefs.setString(_keyLanguage, lang);
    LoggerService.info('Idioma: $lang');
  }

  // ==================== STATISTICS ====================

  int get longestStreak => _prefs.getInt(_keyLongestStreak) ?? 0;

  Future<void> setLongestStreak(int streak) async {
    await _prefs.setInt(_keyLongestStreak, streak);
    LoggerService.info('Racha más larga: $streak días');
  }

  int get totalCompletions => _prefs.getInt(_keyTotalCompletions) ?? 0;

  Future<void> setTotalCompletions(int count) async {
    await _prefs.setInt(_keyTotalCompletions, count);
    LoggerService.info('Total de completitudes: $count');
  }

  Future<void> incrementTotalCompletions() async {
    final current = totalCompletions;
    await setTotalCompletions(current + 1);
  }

  // ==================== CLEAR ====================

  Future<void> clearAll() async {
    await _prefs.clear();
    LoggerService.warning('Todas las preferencias han sido eliminadas');
  }

  Future<void> clearUserData() async {
    // Mantener configuraciones de app, solo limpiar datos de usuario
    await _prefs.remove(_keyLongestStreak);
    await _prefs.remove(_keyTotalCompletions);
    await _prefs.remove(_keyLastSyncTime);
    LoggerService.info('Datos de usuario eliminados de preferencias');
  }
}
