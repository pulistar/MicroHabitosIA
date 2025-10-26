import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Página Home temporal hasta que se implemente la feature completa
class HomePageTemp extends StatelessWidget {
  const HomePageTemp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MicroHabits AI'),
        actions: [
          IconButton(
            onPressed: () {
              // Mostrar diálogo de confirmación
              _showLogoutDialog(context);
            },
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
            colors: [
              AppColors.darkPurple,
              AppColors.mediumPurple,
              AppColors.purple,
              AppColors.purplePink,
              AppColors.lightPurple,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo al usuario
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      final displayName = state.user.displayName ?? 'Usuario';
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
                            'Bienvenido a tu dashboard de hábitos',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.white70,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Cards de funcionalidades
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.track_changes,
                        title: 'Mis Hábitos',
                        subtitle: 'Gestiona tus microhábitos',
                        onTap: () {
                          _showComingSoonDialog(context, 'Gestión de Hábitos');
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.analytics,
                        title: 'Progreso',
                        subtitle: 'Ve tu evolución',
                        onTap: () {
                          _showComingSoonDialog(context, 'Analytics de Progreso');
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.psychology,
                        title: 'AI Coach',
                        subtitle: 'Consejos personalizados',
                        onTap: () {
                          _showComingSoonDialog(context, 'AI Coaching');
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.settings,
                        title: 'Configuración',
                        subtitle: 'Ajusta tu perfil',
                        onTap: () {
                          _showComingSoonDialog(context, 'Configuración');
                        },
                      ),
                    ],
                  ),
                ),
                
                // Información de desarrollo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction,
                        color: AppColors.accentOrange,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dashboard en Desarrollo',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Esta es una versión temporal. Las funcionalidades completas estarán disponibles pronto.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
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
