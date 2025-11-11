import '../entities/chat_message_entity.dart';

/// Repositorio para el Coach IA
abstract class AiCoachRepository {
  Future<ChatMessageEntity> sendMessage(String message, List<ChatMessageEntity> conversationHistory);
  Future<String> analyzeUserProgress(Map<String, dynamic> userData);
  Future<List<String>> getSuggestions();
}
