import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection/injection.dart';
import '../bloc/ranking_bloc.dart';
import '../bloc/ranking_event.dart';
import '../bloc/ranking_state.dart';

/// Página de Ranking de usuarios
class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RankingBloc>()..add(const LoadWeeklyRankingEvent()),
      child: const RankingView(),
    );
  }
}

class RankingView extends StatelessWidget {
  const RankingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Ranking'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<RankingBloc>().add(const RefreshRankingEvent());
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<RankingBloc, RankingState>(
            builder: (context, state) {
              if (state is RankingLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                );
              }

              if (state is RankingError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar ranking',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<RankingBloc>().add(const RefreshRankingEvent());
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (state is RankingLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<RankingBloc>().add(const RefreshRankingEvent());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Text(
                          'Clasificación Semanal',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Top usuarios por hábitos completados esta semana',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.white70,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Lista de ranking
                        Expanded(
                          child: _buildRankingList(state.ranking, state.currentUserRanking),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRankingList(ranking, currentUserRanking) {
    if (ranking.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos de ranking',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completa hábitos para aparecer en el ranking',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white30,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return ListView.builder(
      itemCount: ranking.length,
      itemBuilder: (context, index) {
        final user = ranking[index];
        final isCurrentUser = user.userId == currentUserId;
        
        return _buildRankingCard(
          position: user.position,
          name: user.displayName,
          points: user.weeklyCompletions,
          streak: user.currentStreak,
          isCurrentUser: isCurrentUser,
        );
      },
    );
  }

  Widget _buildRankingCard({
    required int position,
    required String name,
    required int points,
    required int streak,
    required bool isCurrentUser,
  }) {
    // Determinar el color del medal según la posición
    Color medalColor;
    IconData medalIcon;
    
    if (position == 1) {
      medalColor = const Color(0xFFFFD700); // Oro
      medalIcon = Icons.emoji_events;
    } else if (position == 2) {
      medalColor = const Color(0xFFC0C0C0); // Plata
      medalIcon = Icons.emoji_events;
    } else if (position == 3) {
      medalColor = const Color(0xFFCD7F32); // Bronce
      medalIcon = Icons.emoji_events;
    } else {
      medalColor = AppColors.white70;
      medalIcon = Icons.person;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.accentBlue.withOpacity(0.2) : AppColors.white10,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser 
            ? Border.all(color: AppColors.accentBlue, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Posición y medalla
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: medalColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  medalIcon,
                  color: medalColor,
                  size: 24,
                ),
                if (position <= 3)
                  Text(
                    '#$position',
                    style: AppTypography.bodySmall.copyWith(
                      color: medalColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$points pts',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak días',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Indicador de posición para posiciones > 3
          if (position > 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#$position',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
