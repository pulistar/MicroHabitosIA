import 'package:equatable/equatable.dart';

/// Estados del BLoC de notificaciones
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Notificaciones inicializadas
class NotificationInitialized extends NotificationState {
  final bool permissionGranted;

  const NotificationInitialized({required this.permissionGranted});

  @override
  List<Object?> get props => [permissionGranted];
}

/// Recordatorio programado
class ReminderScheduled extends NotificationState {
  final String message;

  const ReminderScheduled({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Notificación enviada
class NotificationSent extends NotificationState {
  final String message;

  const NotificationSent({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error
class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}
