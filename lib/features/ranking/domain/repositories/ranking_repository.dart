import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ranking_user_entity.dart';

abstract class RankingRepository {
  /// Obtiene el ranking de usuarios por completitudes semanales
  Future<Either<Failure, List<RankingUserEntity>>> getWeeklyRanking({int limit = 50});
  
  /// Obtiene la posición del usuario actual en el ranking
  Future<Either<Failure, RankingUserEntity?>> getCurrentUserRanking();
}
