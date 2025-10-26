import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../../domain/usecases/get_onboarding_items.dart';
import '../../../../injection/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(
        getOnboardingItemsUseCase: sl<GetOnboardingItemsUseCase>(),
      )..add(LoadOnboardingItemsEvent()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
            stops: AppColors.primaryGradientStops,
          ),
        ),
        child: Stack(
          children: [
            // Efecto de partículas/estrellas de fondo
            Positioned.fill(
              child: CustomPaint(
                painter: StarsPainter(),
              ),
            ),
            // Contenido principal
            Scaffold(
              backgroundColor: Colors.transparent,
              body: BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  if (state is OnboardingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is OnboardingError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is OnboardingLoaded) {
                    return PageView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return OnboardingItemWidget(
                          title: item.title,
                          description: item.description,
                          imagePath: item.imagePath,
                          isLastPage: index == state.items.length - 1,
                          onPressed: () {
                            // Navegar a la siguiente pantalla (por ejemplo, login)
                            Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool isLastPage;
  final VoidCallback onPressed;

  const OnboardingItemWidget({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isLastPage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: AppConstants.imageWidth,
                    height: AppConstants.imageHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.purplePink,
                          AppColors.accentPink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius20),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: AppConstants.iconSize,
                      color: AppColors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: AppConstants.spacing30),
          // Título con efecto de sombra
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
              ),
              child: Text(
                title,
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: AppConstants.fontSizeGiant,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: AppConstants.spacing20),
          // Descripción mejorada
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                color: Colors.black.withOpacity(AppConstants.opacity10),
              ),
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: AppConstants.spacing12),
              child: Text(
                description,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: AppConstants.fontSizeBase,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: AppConstants.spacing40),
          // Botón (solo en última página)
          if (isLastPage)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing30),
              child: ElevatedButton(
                onPressed: onPressed,
                child: const Text('Comenzar'),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing30),
              child: Text(
                'Desliza para continuar →',
                style: AppTypography.bodySmall,
              ),
            ),
          SizedBox(height: AppConstants.spacing30),
        ],
      ),
    );
  }
}

// Pintor personalizado para las estrellas/partículas
class StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    final random = _seededRandom();

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => false;

  // Generador de números aleatorios con semilla para consistencia
  _Random _seededRandom() {
    return _Random(42);
  }
}

class _Random {
  int seed;

  _Random(this.seed);

  double nextDouble() {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed / 0x7fffffff;
  }
}
