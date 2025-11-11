import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger_service.dart';
import 'hive_service.dart';
import 'preferences_service.dart';
import 'models/sync_metadata.dart';

/// Servicio para sincronizar datos entre Hive y Supabase
class SyncService {
  final HiveService _hiveService;
  final PreferencesService _preferencesService;
  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = true;

  SyncService(this._hiveService, this._preferencesService);

  // ==================== CONNECTIVITY ====================

  bool get isOnline => _isOnline;

  Future<void> init() async {
    // Verificar conectividad inicial
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    
    // Escuchar cambios de conectividad
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;
        
        if (!wasOnline && _isOnline) {
          LoggerService.info('🌐 Conexión restaurada - iniciando sincronización');
          syncPendingData();
        } else if (wasOnline && !_isOnline) {
          LoggerService.warning('📡 Sin conexión - modo offline activado');
        }
      },
    );

    LoggerService.info('✅ SyncService inicializado - Estado: ${_isOnline ? "Online" : "Offline"}');
  }

  // ==================== SYNC ====================

  Future<void> syncPendingData() async {
    if (!_isOnline) {
      LoggerService.warning('No hay conexión - sincronización pospuesta');
      return;
    }

    try {
      LoggerService.info('🔄 Iniciando sincronización...');

      // Obtener completitudes pendientes de sincronizar
      final unsyncedCompletions = _hiveService.getUnsyncedCompletions();
      
      if (unsyncedCompletions.isEmpty) {
        LoggerService.info('✅ No hay datos pendientes de sincronizar');
        return;
      }

      LoggerService.info('📤 ${unsyncedCompletions.length} completitudes pendientes de sincronizar');

      // Aquí se sincronizarían con Supabase
      // Por ahora solo actualizamos el metadata
      await _updateSyncMetadata(unsyncedCompletions.length);

      LoggerService.info('✅ Sincronización completada');
    } catch (e) {
      LoggerService.error('Error en sincronización: $e');
    }
  }

  Future<void> _updateSyncMetadata(int pendingCount) async {
    final metadata = SyncMetadata(
      key: 'last_sync',
      lastSyncTime: DateTime.now(),
      isOnline: _isOnline,
      pendingSyncCount: pendingCount,
    );

    await _hiveService.saveSyncMetadata(metadata);
    await _preferencesService.setLastSyncTime(DateTime.now());
  }

  // ==================== CACHE MANAGEMENT ====================

  Future<bool> shouldRefreshCache() async {
    final lastSync = _preferencesService.lastSyncTime;
    
    if (lastSync == null) {
      return true; // Primera vez
    }

    // Refrescar si han pasado más de 5 minutos
    final difference = DateTime.now().difference(lastSync);
    return difference.inMinutes > 5;
  }

  Future<void> markCacheAsRefreshed() async {
    await _preferencesService.setLastSyncTime(DateTime.now());
  }

  // ==================== CLEANUP ====================

  Future<void> cleanupOldData() async {
    try {
      // Limpiar completitudes de más de 30 días
      await _hiveService.clearOldCompletions(daysToKeep: 30);
      LoggerService.info('🧹 Limpieza de datos antiguos completada');
    } catch (e) {
      LoggerService.error('Error en limpieza de datos: $e');
    }
  }

  // ==================== STATS ====================

  Map<String, dynamic> getSyncStats() {
    final cacheStats = _hiveService.getCacheStats();
    final lastSync = _preferencesService.lastSyncTime;
    final metadata = _hiveService.getSyncMetadata('last_sync');

    return {
      'isOnline': _isOnline,
      'lastSyncTime': lastSync?.toIso8601String(),
      'cacheStats': cacheStats,
      'pendingSyncCount': metadata?.pendingSyncCount ?? 0,
    };
  }

  // ==================== DISPOSE ====================

  void dispose() {
    _connectivitySubscription?.cancel();
    LoggerService.info('SyncService disposed');
  }
}
