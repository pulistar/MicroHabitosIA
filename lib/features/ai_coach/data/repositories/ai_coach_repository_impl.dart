import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import '../datasources/ai_coach_remote_datasource.dart';
import '../models/chat_message_model.dart';

/// Implementación del repositorio del Coach IA
class AiCoachRepositoryImpl implements AiCoachRepository {
  final AiCoachRemoteDataSource remoteDataSource;

  AiCoachRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ChatMessageEntity> sendMessage(
    String message,
    List<ChatMessageEntity> conversationHistory,
  ) async {
    // Convertir entidades a modelos
    final historyModels = conversationHistory
        .map((entity) => ChatMessageModel.fromEntity(entity))
        .toList();

    // Enviar mensaje
    final response = await remoteDataSource.sendMessage(message, historyModels);
    
    return response;
  }

  @override
  Future<String> analyzeUserProgress(Map<String, dynamic> userData) async {
    return await remoteDataSource.analyzeUserProgress(userData);
  }

  @override
  Future<List<String>> getSuggestions() async {
    return await remoteDataSource.getSuggestions();
  }
}
