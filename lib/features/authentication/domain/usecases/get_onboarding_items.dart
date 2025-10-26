import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/onboarding_entity.dart';

class GetOnboardingItemsUseCase implements UseCase<List<OnboardingItem>, NoParams> {
  @override
  Future<Either<Failure, List<OnboardingItem>>> call(NoParams params) async {
    try {
      final onboardingItems = [
        OnboardingItem(
          title: 'Bienvenido a MicroHabits AI',
          description: 'Mejora cada día con pequeños pasos guiados por inteligencia artificial',
          imagePath: 'assets/images/onboarding/welcome.png',
        ),
        OnboardingItem(
          title: 'Coaching Personalizado',
          description: 'IA que te guía y motiva para alcanzar tus metas',
          imagePath: 'assets/images/onboarding/coaching.png',
        ),
        OnboardingItem(
          title: 'Gamificación',
          description: 'Transforma tus hábitos en un viaje divertido y motivador',
          imagePath: 'assets/images/onboarding/gamification.png',
        ),
      ];
      
      return Right(onboardingItems);
    } catch (e) {
      return Left(ServerFailure('No se pudieron cargar los elementos de onboarding'));
    }
  }
}
