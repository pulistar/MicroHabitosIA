import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/notifications/ai_notification_service.dart';
import '../../../home/domain/repositories/home_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC para manejar notificaciones
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService notificationService;
  final AiNotificationService aiNotificationService;
  final HomeRepository homeRepository;

  NotificationBloc({
    required this.notificationService,
    required this.aiNotificationService,
    required this.homeRepository,
  }) : super(const NotificationInitial()) {
    on<InitializeNotificationsEvent>(_onInitialize);
    on<ScheduleDailyReminderEvent>(_onScheduleDailyReminder);
    on<SendMotivationalNotificationEvent>(_onSendMotivationalNotification);
    on<ScheduleStreakReminderEvent>(_onScheduleStreakReminder);
    on<CancelAllNotificationsEvent>(_onCancelAll);
  }

  Future<void> _onInitialize(
    InitializeNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationService.initialize();
      final permissionGranted = await notificationService.requestPermissions();
      
      emit(NotificationInitialized(permissionGranted: permissionGranted));
    } catch (e) {
      emit(NotificationError(message: 'Error al inicializar notificaciones: $e'));
    }
  }

  Future<void> _onScheduleDailyReminder(
    ScheduleDailyReminderEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Obtener datos del usuario
      final dashboardResult = await homeRepository.getDashboardData();
      final dashboard = dashboardResult.fold(
        (failure) => null,
        (data) => data,
      );

      if (dashboard == null) {
        emit(const NotificationError(message: 'No se pudo obtener datos del usuario'));
        return;
      }

      // Generar mensaje con IA
      final message = await aiNotificationService.generateMotivationalMessage(
        userName: dashboard.userProfile.displayName ?? 'Campeón',
        totalHabits: dashboard.userProfile.totalHabits,
        currentStreak: dashboard.userProfile.currentStreak,
        completedToday: dashboard.userProfile.completedToday,
      );

      // Programar notificación diaria
      await notificationService.scheduleDailyNotification(
        id: 1,
        title: '🎯 MicroHabits',
        body: message,
        hour: event.hour,
        minute: event.minute,
      );

      emit(ReminderScheduled(
        message: 'Recordatorio programado para las ${event.hour}:${event.minute.toString().padLeft(2, '0')}',
      ));
    } catch (e) {
      emit(NotificationError(message: 'Error al programar recordatorio: $e'));
    }
  }

  Future<void> _onSendMotivationalNotification(
    SendMotivationalNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Obtener datos del usuario
      final dashboardResult = await homeRepository.getDashboardData();
      final dashboard = dashboardResult.fold(
        (failure) => null,
        (data) => data,
      );

      if (dashboard == null) {
        emit(const NotificationError(message: 'No se pudo obtener datos del usuario'));
        return;
      }

      // Generar mensaje con IA
      final message = await aiNotificationService.generateMotivationalMessage(
        userName: dashboard.userProfile.displayName ?? 'Campeón',
        totalHabits: dashboard.userProfile.totalHabits,
        currentStreak: dashboard.userProfile.currentStreak,
        completedToday: dashboard.userProfile.completedToday,
      );

      // Enviar notificación inmediata
      await notificationService.showNotification(
        id: 999,
        title: '💪 ¡Motivación MicroHabits!',
        body: message,
      );

      emit(NotificationSent(message: 'Notificación enviada'));
    } catch (e) {
      emit(NotificationError(message: 'Error al enviar notificación: $e'));
    }
  }

  Future<void> _onScheduleStreakReminder(
    ScheduleStreakReminderEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Obtener datos del usuario
      final dashboardResult = await homeRepository.getDashboardData();
      final dashboard = dashboardResult.fold(
        (failure) => null,
        (data) => data,
      );

      if (dashboard == null) {
        emit(const NotificationError(message: 'No se pudo obtener datos del usuario'));
        return;
      }

      // Si el usuario tiene racha y no ha completado hábitos hoy
      if (dashboard.userProfile.currentStreak > 0 && 
          dashboard.userProfile.completedToday == 0) {
        
        final message = await aiNotificationService.generateStreakWarning(
          userName: dashboard.userProfile.displayName ?? 'Campeón',
          currentStreak: dashboard.userProfile.currentStreak,
        );

        // Programar para las 8 PM
        await notificationService.scheduleDailyNotification(
          id: 2,
          title: '⚠️ ¡Racha en Peligro!',
          body: message,
          hour: 20,
          minute: 0,
        );

        emit(const ReminderScheduled(message: 'Recordatorio de racha programado'));
      }
    } catch (e) {
      emit(NotificationError(message: 'Error al programar recordatorio de racha: $e'));
    }
  }

  Future<void> _onCancelAll(
    CancelAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationService.cancelAllNotifications();
      emit(const NotificationSent(message: 'Todas las notificaciones canceladas'));
    } catch (e) {
      emit(NotificationError(message: 'Error al cancelar notificaciones: $e'));
    }
  }
}
