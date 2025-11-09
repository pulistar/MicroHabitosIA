import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger_service.dart';
import '../../domain/entities/ranking_user_entity.dart';
import '../../domain/repositories/ranking_repository.dart';
import '../datasources/ranking_remote_datasource.dart';

class RankingRepositoryImpl implements RankingRepository {
  final RankingRemoteDataSource remoteDataSource;

  RankingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<RankingUserEntity>>> getWeeklyRanking({int limit = 50}) async {
    try {
      LoggerService.startOperation('getWeeklyRanking');
      final ranking = await remoteDataSource.getWeeklyRanking(limit: limit);
      LoggerService.endOperation('getWeeklyRanking');
      return Right(ranking);
    } catch (e) {
      LoggerService.error('Error en getWeeklyRanking: $e');
      return Left(ServerFailure('Error al obtener el ranking: $e'));
    }
  }

  @override
  Future<Either<Failure, RankingUserEntity?>> getCurrentUserRanking() async {
    try {
      LoggerService.startOperation('getCurrentUserRanking');
      final userRanking = await remoteDataSource.getCurrentUserRanking();
      LoggerService.endOperation('getCurrentUserRanking');
      return Right(userRanking);
    } catch (e) {
      LoggerService.error('Error en getCurrentUserRanking: $e');
      return Left(ServerFailure('Error al obtener tu posición: $e'));
    }
  }
}
