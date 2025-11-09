import 'package:equatable/equatable.dart';

abstract class RankingEvent extends Equatable {
  const RankingEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el ranking semanal
class LoadWeeklyRankingEvent extends RankingEvent {
  final int limit;

  const LoadWeeklyRankingEvent({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

/// Evento para refrescar el ranking
class RefreshRankingEvent extends RankingEvent {
  final int limit;

  const RefreshRankingEvent({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}
