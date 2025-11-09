import 'package:equatable/equatable.dart';
import '../../domain/entities/ranking_user_entity.dart';

abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class RankingInitial extends RankingState {
  const RankingInitial();
}

/// Estado de carga
class RankingLoading extends RankingState {
  const RankingLoading();
}

/// Estado de ranking cargado exitosamente
class RankingLoaded extends RankingState {
  final List<RankingUserEntity> ranking;
  final RankingUserEntity? currentUserRanking;

  const RankingLoaded({
    required this.ranking,
    this.currentUserRanking,
  });

  @override
  List<Object?> get props => [ranking, currentUserRanking];
}

/// Estado de error
class RankingError extends RankingState {
  final String message;

  const RankingError(this.message);

  @override
  List<Object?> get props => [message];
}
