import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger_service.dart';
import '../../domain/usecases/get_weekly_ranking_usecase.dart';
import 'ranking_event.dart';
import 'ranking_state.dart';

class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final GetWeeklyRankingUseCase getWeeklyRankingUseCase;

  RankingBloc({
    required this.getWeeklyRankingUseCase,
  }) : super(const RankingInitial()) {
    on<LoadWeeklyRankingEvent>(_onLoadWeeklyRanking);
    on<RefreshRankingEvent>(_onRefreshRanking);
  }

  Future<void> _onLoadWeeklyRanking(
    LoadWeeklyRankingEvent event,
    Emitter<RankingState> emit,
  ) async {
    emit(const RankingLoading());
    LoggerService.info('Cargando ranking semanal');

    final result = await getWeeklyRankingUseCase(event.limit);

    result.fold(
      (failure) {
        LoggerService.error('Error al cargar ranking: ${failure.message}');
        emit(RankingError(failure.message));
      },
      (ranking) {
        LoggerService.info('Ranking cargado: ${ranking.length} usuarios');
        
        // Buscar al usuario actual en el ranking
        final currentUser = Supabase.instance.client.auth.currentUser;
        var currentUserRanking = null;
        
        if (currentUser != null && ranking.isNotEmpty) {
          try {
            currentUserRanking = ranking.firstWhere(
              (user) => user.userId == currentUser.id,
            );
          } catch (e) {
            // Usuario no encontrado en el ranking
            currentUserRanking = null;
          }
        }

        emit(RankingLoaded(
          ranking: ranking,
          currentUserRanking: currentUserRanking,
        ));
      },
    );
  }

  Future<void> _onRefreshRanking(
    RefreshRankingEvent event,
    Emitter<RankingState> emit,
  ) async {
    // No mostrar loading si ya hay datos cargados
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    }

    LoggerService.info('Refrescando ranking semanal');

    final result = await getWeeklyRankingUseCase(event.limit);

    result.fold(
      (failure) {
        LoggerService.error('Error al refrescar ranking: ${failure.message}');
        emit(RankingError(failure.message));
      },
      (ranking) {
        LoggerService.info('Ranking refrescado: ${ranking.length} usuarios');
        
        // Buscar al usuario actual en el ranking
        final currentUser = Supabase.instance.client.auth.currentUser;
        var currentUserRanking = null;
        
        if (currentUser != null && ranking.isNotEmpty) {
          try {
            currentUserRanking = ranking.firstWhere(
              (user) => user.userId == currentUser.id,
            );
          } catch (e) {
            // Usuario no encontrado en el ranking
            currentUserRanking = null;
          }
        }

        emit(RankingLoaded(
          ranking: ranking,
          currentUserRanking: currentUserRanking,
        ));
      },
    );
  }
}
