import '../repositories/ai_coach_repository.dart';

/// Caso de uso para obtener sugerencias de preguntas
class GetSuggestionsUseCase {
  final AiCoachRepository repository;

  GetSuggestionsUseCase(this.repository);

  Future<List<String>> call() async {
    return await repository.getSuggestions();
  }
}
