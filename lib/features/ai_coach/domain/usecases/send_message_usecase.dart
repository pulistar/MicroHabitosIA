import '../entities/chat_message_entity.dart';
import '../repositories/ai_coach_repository.dart';

/// Caso de uso para enviar un mensaje al Coach IA
class SendMessageUseCase {
  final AiCoachRepository repository;

  SendMessageUseCase(this.repository);

  Future<ChatMessageEntity> call(
    String message,
    List<ChatMessageEntity> conversationHistory,
  ) async {
    return await repository.sendMessage(message, conversationHistory);
  }
}
