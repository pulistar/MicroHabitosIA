import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ranking_user_entity.dart';
import '../repositories/ranking_repository.dart';

class GetWeeklyRankingUseCase implements UseCase<List<RankingUserEntity>, int> {
  final RankingRepository repository;

  GetWeeklyRankingUseCase(this.repository);

  @override
  Future<Either<Failure, List<RankingUserEntity>>> call(int limit) async {
    return await repository.getWeeklyRanking(limit: limit);
  }
}
