import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../microhabits/presentation/pages/create_habit_page.dart';
import '../../../microhabits/presentation/pages/habits_page.dart';
import '../../../ranking/presentation/pages/ranking_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection/injection.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Página principal del Home con dashboard completo
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeBloc>()..add(const LoadDashboardEvent()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
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
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is LogoutSuccess) {
                // El AuthWrapper manejará la navegación automáticamente
                context.read<AuthBloc>().add(const AuthCheckRequested());
              }
            },
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                );
              }

              if (state is HomeError) {
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
                        'Error al cargar datos',
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
                          context.read<HomeBloc>().add(const RefreshDashboardEvent());
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (state is HomeLoaded || state is ProfileUpdated) {
                final dashboard = state is HomeLoaded 
                    ? state.dashboard 
                    : (state as ProfileUpdated).dashboard;
                
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const RefreshDashboardEvent());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Saludo al usuario
                          _buildUserGreeting(dashboard.userProfile.displayName ?? 'Usuario'),
                          
                          const SizedBox(height: 32),
                          
                          // Estadísticas principales
                          _buildStatsCards(dashboard.userProfile),
                          
                          const SizedBox(height: 32),
                          
                          // Progreso semanal
                          _buildWeeklyProgress(dashboard.weeklyProgress),
                          
                          const SizedBox(height: 32),
                          
                          // Hábitos recientes
                          _buildRecentHabits(dashboard.recentHabits),
                          
                          const SizedBox(height: 32),
                          
                          // Cards de funcionalidades
                          _buildFeatureCards(context),
                        ],
                      ),
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

  Widget _buildUserGreeting(String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola, $displayName! 👋',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aquí tienes tu progreso de hábitos',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(userProfile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.track_changes,
            title: 'Total Hábitos',
            value: '${userProfile.totalHabits}',
            color: AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.today,
            title: 'Completados Hoy',
            value: '${userProfile.completedToday}',
            color: AppColors.accentBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(weeklyProgress) {
    // Obtener el día actual (0 = Lunes, 6 = Domingo)
    final today = DateTime.now();
    final currentDayIndex = (today.weekday - 1) % 7; // Convertir a índice 0-6
    
    // Debug: Log del día actual
    final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    print('📅 Hoy es: ${dayNames[currentDayIndex]} (índice: $currentDayIndex, weekday: ${today.weekday})');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso Semanal',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
              final completions = weeklyProgress.dailyCompletions[index];
              final isToday = index == currentDayIndex;
              
              return Column(
                children: [
                  Text(
                    days[index],
                    style: AppTypography.bodySmall.copyWith(
                      color: isToday ? AppColors.accentOrange : AppColors.white70,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: completions > 0 ? AppColors.accentGreen : AppColors.white30,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday 
                          ? Border.all(color: AppColors.accentOrange, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$completions',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Tasa de completitud: ${(weeklyProgress.completionRate * 100).toInt()}%',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHabits(recentHabits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hábitos Recientes',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...recentHabits.map<Widget>((habit) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                habit.completedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                color: habit.completedToday ? AppColors.accentGreen : AppColors.white54,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${habit.category} • Racha: ${habit.currentStreak} días',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Funcionalidades',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              icon: Icons.add_circle,
              title: 'Nuevo Hábito',
              subtitle: 'Crea un microhábito',
              onTap: () => _navigateToCreateHabit(context),
            ),
            _buildFeatureCard(
              icon: Icons.list,
              title: 'Mis Hábitos',
              subtitle: 'Ver todos los hábitos',
              onTap: () => _navigateToHabits(context),
            ),
            _buildFeatureCard(
              icon: Icons.psychology,
              title: 'AI Coach',
              subtitle: 'Consejos IA',
              onTap: () => _showComingSoonDialog(context, 'AI Coach'),
            ),
            _buildFeatureCard(
              icon: Icons.emoji_events,
              title: 'Ranking',
              subtitle: 'Ver clasificación',
              onTap: () => _navigateToRanking(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: AppColors.purple,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final homeBloc = context.read<HomeBloc>(); // Capturar el bloc antes del diálogo
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCreateHabit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateHabitPage(),
      ),
    ).then((_) {
      // Refrescar el dashboard cuando regrese de crear hábito
      context.read<HomeBloc>().add(const RefreshDashboardEvent());
    });
  }

  void _navigateToHabits(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HabitsPage(),
      ),
    ).then((_) {
      // Refrescar el dashboard cuando regrese de la lista de hábitos
      context.read<HomeBloc>().add(const RefreshDashboardEvent());
    });
  }

  void _navigateToRanking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RankingPage(),
      ),
    ).then((_) {
      // Refrescar el dashboard cuando regrese del ranking
      context.read<HomeBloc>().add(const RefreshDashboardEvent());
    });
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$feature - Próximamente'),
          content: Text('La funcionalidad de $feature estará disponible en la próxima versión.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}
