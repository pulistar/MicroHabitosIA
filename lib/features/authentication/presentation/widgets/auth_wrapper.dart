import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../pages/onboarding_page.dart';
import '../pages/login_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger_service.dart';

/// Widget que maneja la navegación automática basada en el estado de autenticación
class AuthWrapper extends StatelessWidget {
  final Widget authenticatedWidget;
  final bool showOnboarding;

  const AuthWrapper({
    super.key,
    required this.authenticatedWidget,
    this.showOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Log de cambios de estado para debugging
        if (state is AuthAuthenticated) {
          LoggerService.auth('AuthWrapper: Usuario autenticado - ${state.user.email}');
        } else if (state is AuthUnauthenticated) {
          LoggerService.auth('AuthWrapper: Usuario no autenticado');
        }
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const _LoadingScreen();
        }
        
        if (state is AuthAuthenticated) {
          LoggerService.auth('AuthWrapper: Mostrando pantalla autenticada');
          return authenticatedWidget;
        }
        
        // Estado no autenticado
        if (showOnboarding) {
          LoggerService.auth('AuthWrapper: Mostrando onboarding');
          return const OnboardingPage();
        } else {
          LoggerService.auth('AuthWrapper: Mostrando login');
          return const LoginPage();
        }
      },
    );
  }
}

/// Pantalla de carga mientras se verifica la autenticación
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              Text(
                'Verificando sesión...',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
