import 'package:equatable/equatable.dart';

/// Eventos para el BLoC de notificaciones
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializar notificaciones
class InitializeNotificationsEvent extends NotificationEvent {
  const InitializeNotificationsEvent();
}

/// Programar recordatorio diario
class ScheduleDailyReminderEvent extends NotificationEvent {
  final int hour;
  final int minute;

  const ScheduleDailyReminderEvent({
    required this.hour,
    required this.minute,
  });

  @override
  List<Object?> get props => [hour, minute];
}

/// Enviar notificación motivacional ahora
class SendMotivationalNotificationEvent extends NotificationEvent {
  const SendMotivationalNotificationEvent();
}

/// Programar recordatorio de racha
class ScheduleStreakReminderEvent extends NotificationEvent {
  const ScheduleStreakReminderEvent();
}

/// Cancelar todas las notificaciones
class CancelAllNotificationsEvent extends NotificationEvent {
  const CancelAllNotificationsEvent();
}
