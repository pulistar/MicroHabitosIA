import 'package:equatable/equatable.dart';

/// Eventos del Coach IA
abstract class AiCoachEvent extends Equatable {
  const AiCoachEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para enviar un mensaje
class SendMessageEvent extends AiCoachEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Evento para analizar el progreso del usuario
class AnalyzeProgressEvent extends AiCoachEvent {
  final Map<String, dynamic> userData;

  const AnalyzeProgressEvent(this.userData);

  @override
  List<Object?> get props => [userData];
}

/// Evento para cargar sugerencias
class LoadSuggestionsEvent extends AiCoachEvent {
  const LoadSuggestionsEvent();
}

/// Evento para limpiar el chat
class ClearChatEvent extends AiCoachEvent {
  const ClearChatEvent();
}
