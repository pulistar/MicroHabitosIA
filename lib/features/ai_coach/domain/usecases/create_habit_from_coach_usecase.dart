import 'package:dartz/dartz.dart';
import '../../../microhabits/domain/repositories/habits_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case para crear un hábito desde el Coach IA
class CreateHabitFromCoachUseCase {
  final HabitsRepository habitsRepository;

  CreateHabitFromCoachUseCase(this.habitsRepository);

  Future<Either<Failure, void>> call({
    required String name,
    required String category,
    String? description,
  }) async {
    return await habitsRepository.createHabit(
      name: name,
      description: description ?? 'Sugerido por el Coach IA',
      category: category,
      color: _getCategoryColor(category),
      icon: _getCategoryIcon(category),
      dailyGoal: 1,
    );
  }

  String _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'salud':
        return '#4CAF50';
      case 'productividad':
        return '#2196F3';
      case 'bienestar':
        return '#9C27B0';
      case 'ejercicio':
        return '#FF5722';
      case 'alimentación':
        return '#FF9800';
      default:
        return '#607D8B';
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salud':
        return 'favorite';
      case 'productividad':
        return 'work';
      case 'bienestar':
        return 'self_improvement';
      case 'ejercicio':
        return 'fitness_center';
      case 'alimentación':
        return 'restaurant';
      default:
        return 'check_circle';
    }
  }
}
