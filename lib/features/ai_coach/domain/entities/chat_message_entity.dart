import 'package:equatable/equatable.dart';

/// Entidad que representa un mensaje en el chat con el Coach IA
class ChatMessageEntity extends Equatable {
  final String id;
  final String content;
  final bool isUser; // true = usuario, false = coach
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  @override
  List<Object?> get props => [id, content, isUser, timestamp, status];
}

/// Estado del mensaje
enum MessageStatus {
  sending,  // Enviando
  sent,     // Enviado
  error,    // Error al enviar
}
