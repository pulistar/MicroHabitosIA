import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

/// Estados del Coach IA
abstract class AiCoachState extends Equatable {
  const AiCoachState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AiCoachInitial extends AiCoachState {
  const AiCoachInitial();
}

/// Estado de carga
class AiCoachLoading extends AiCoachState {
  final List<ChatMessageEntity> messages;
  final List<String> suggestions;

  const AiCoachLoading({
    required this.messages,
    this.suggestions = const [],
  });

  @override
  List<Object?> get props => [messages, suggestions];
}

/// Estado con mensajes cargados
class AiCoachLoaded extends AiCoachState {
  final List<ChatMessageEntity> messages;
  final List<String> suggestions;

  const AiCoachLoaded({
    required this.messages,
    this.suggestions = const [],
  });

  @override
  List<Object?> get props => [messages, suggestions];
}

/// Estado de error
class AiCoachError extends AiCoachState {
  final String message;
  final List<ChatMessageEntity> messages;
  final List<String> suggestions;

  const AiCoachError({
    required this.message,
    required this.messages,
    this.suggestions = const [],
  });

  @override
  List<Object?> get props => [message, messages, suggestions];
}
