import '../repositories/ai_coach_repository.dart';

/// Caso de uso para analizar el progreso del usuario
class AnalyzeProgressUseCase {
  final AiCoachRepository repository;

  AnalyzeProgressUseCase(this.repository);

  Future<String> call(Map<String, dynamic> userData) async {
    return await repository.analyzeUserProgress(userData);
  }
}
