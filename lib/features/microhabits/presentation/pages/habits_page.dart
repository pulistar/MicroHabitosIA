import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection/injection.dart';
import '../bloc/habits_bloc.dart';
import '../bloc/habits_event.dart';
import '../bloc/habits_state.dart';
import 'create_habit_page.dart';

/// Página principal para gestionar hábitos
class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  late final HabitsBloc _habitsBloc;

  @override
  void initState() {
    super.initState();
    _habitsBloc = sl<HabitsBloc>();
    _habitsBloc.add(const LoadHabitsEvent());
  }

  @override
  void dispose() {
    _habitsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _habitsBloc,
      child: const HabitsView(),
    );
  }
}

class HabitsView extends StatefulWidget {
  const HabitsView({super.key});

  @override
  State<HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<HabitsView> {
  // Método helper para obtener el progreso actual desde el estado del BLoC
  int _getCurrentProgress(HabitsLoaded state, habit) {
    return state.getCurrentProgress(habit.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HabitsBloc, HabitsState>(
      listener: (context, state) {
        if (state is HabitDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hábito eliminado exitosamente'),
              backgroundColor: AppColors.accentGreen,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is HabitUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hábito "${state.habit.name}" actualizado'),
              backgroundColor: AppColors.accentGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Hábitos'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<HabitsBloc>().add(const RefreshHabitsEvent());
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
            child: BlocBuilder<HabitsBloc, HabitsState>(
            builder: (context, state) {
              // Manejar TODOS los estados de loading/processing
              if (_isLoadingState(state)) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                );
              }

              if (state is HabitsError) {
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
                        'Error al cargar hábitos',
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
                          context.read<HabitsBloc>().add(const LoadHabitsEvent());
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              // Manejar estados que contienen datos de hábitos
              if (_hasHabitsData(state)) {
                final habits = _getHabitsFromState(state);
                final loadedState = _getLoadedStateFromState(state);
                
                if (habits.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HabitsBloc>().add(const RefreshHabitsEvent());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return _buildHabitCard(context, habit, loadedState);
                    },
                  ),
                );
              }

              // Estado no manejado - fallback
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateHabit(context),
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes,
              size: 80,
              color: AppColors.white54,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Crea tu primer hábito!',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Los microhábitos son pequeñas acciones que realizas diariamente para mejorar tu vida.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateHabit(context),
              icon: const Icon(Icons.add),
              label: const Text('Crear mi primer hábito'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, habit, HabitsLoaded loadedState) {
    // Convertir color hex a Color
    final habitColor = Color(int.parse(habit.color.replaceFirst('#', '0xFF')));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: habitColor.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () => _showHabitOptions(context, habit),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del hábito
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(habit.icon),
                  color: habitColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del hábito
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    if (habit.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.local_fire_department,
                          label: '${habit.currentStreak}',
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.check_circle,
                          label: '${habit.totalCompletions}',
                          color: AppColors.accentGreen,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryChip(habit.category),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Botón de completar con progreso
              GestureDetector(
                onTap: () => _toggleHabitCompletion(context, habit),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCurrentProgress(loadedState, habit) >= habit.dailyGoal 
                        ? AppColors.accentGreen.withOpacity(0.2)
                        : AppColors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getCurrentProgress(loadedState, habit) >= habit.dailyGoal 
                          ? AppColors.accentGreen 
                          : AppColors.white30,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getCurrentProgress(loadedState, habit) >= habit.dailyGoal 
                            ? Icons.check_circle 
                            : Icons.radio_button_unchecked,
                        color: _getCurrentProgress(loadedState, habit) >= habit.dailyGoal 
                            ? AppColors.accentGreen 
                            : AppColors.white70,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getCurrentProgress(loadedState, habit)}/${habit.dailyGoal}',
                        style: AppTypography.bodySmall.copyWith(
                          color: _getCurrentProgress(loadedState, habit) >= habit.dailyGoal 
                              ? AppColors.accentGreen 
                              : AppColors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white20,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.white70,
        ),
      ),
    );
  }

  void _navigateToCreateHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateHabitPage(),
      ),
    ).then((_) {
      // Refrescar la lista cuando regrese de crear hábito
      context.read<HabitsBloc>().add(const RefreshHabitsEvent());
    });
  }

  void _navigateToEditHabit(BuildContext context, habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateHabitPage(habitToEdit: habit),
      ),
    ).then((updated) {
      // Refrescar la lista si se actualizó el hábito
      if (updated == true) {
        context.read<HabitsBloc>().add(const RefreshHabitsEvent());
      }
    });
  }

  void _showHabitOptions(BuildContext context, habit) {
    // Capturar el BLoC ANTES del BottomSheet para evitar problemas de contexto
    final habitsBloc = context.read<HabitsBloc>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkPurple,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              habit.name,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.accentBlue),
              title: const Text('Editar', style: TextStyle(color: AppColors.white)),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _navigateToEditHabit(context, habit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Eliminar', style: TextStyle(color: AppColors.white)),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                // Pasar el BLoC capturado en lugar de usar context.read()
                _showDeleteConfirmationWithBloc(context, habit, habitsBloc);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, habit) {
    // Capturar el BLoC ANTES del diálogo para evitar widget desactivado
    final habitsBloc = context.read<HabitsBloc>();
    _showDeleteConfirmationWithBloc(context, habit, habitsBloc);
  }

  void _showDeleteConfirmationWithBloc(BuildContext context, habit, HabitsBloc habitsBloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Hábito'),
        content: Text('¿Estás seguro de que quieres eliminar "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Usar la referencia del BLoC pasada como parámetro
              habitsBloc.add(DeleteHabitEvent(habit.id));
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _toggleHabitCompletion(BuildContext context, habit) {
    final currentState = context.read<HabitsBloc>().state;
    final loadedState = _getLoadedStateFromState(currentState);
    
    // Verificar si ya está completado para hoy (considerando progreso temporal)
    if (_getCurrentProgress(loadedState, habit) >= habit.dailyGoal) {
      _showAlreadyCompletedDialog(context, habit);
      return;
    }

    // Obtener el bloc antes de mostrar el dialog
    final habitsBloc = context.read<HabitsBloc>();
    // Mostrar dialog de confirmación
    _showCompletionDialog(context, habit, habitsBloc);
  }

  void _showCompletionDialog(BuildContext context, habit, HabitsBloc habitsBloc) {
    final currentState = habitsBloc.state;
    final loadedState = _getLoadedStateFromState(currentState);
    
    // Obtener progreso actual (temporal o real)
    int localCompletedToday = _getCurrentProgress(loadedState, habit);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono de celebración
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.celebration,
                      color: AppColors.accentGreen,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Título
                  Text(
                    '¡Excelente!',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Mensaje motivacional
                  Text(
                    'Selecciona cuál repetición completaste:',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Información del hábito
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          habit.name,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Progreso: $localCompletedToday/${habit.dailyGoal}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Grid de repeticiones
                        _buildRepetitionsGridLocal(habit, localCompletedToday),
                      ],
                ),
              ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.white70,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Usar evento del BLoC para manejar el progreso
                    habitsBloc.add(IncrementTemporaryProgressEvent(habit.id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    localCompletedToday + 1 >= habit.dailyGoal 
                        ? '¡Completar!' 
                        : 'Continuar',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRepetitionsGridLocal(habit, int localCompletedToday) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(habit.dailyGoal, (index) {
        final repetitionNumber = index + 1;
        final isCompleted = repetitionNumber <= localCompletedToday;
        final isNext = repetitionNumber == localCompletedToday + 1;
        
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted 
                ? AppColors.accentGreen 
                : isNext 
                    ? AppColors.accentGreen.withOpacity(0.3)
                    : AppColors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCompleted 
                  ? AppColors.accentGreen 
                  : isNext 
                      ? AppColors.accentGreen
                      : AppColors.white30,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted 
                ? const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 20,
                  )
                : Text(
                    '$repetitionNumber',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isNext 
                          ? AppColors.accentGreen 
                          : AppColors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildRepetitionsGrid(habit) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(habit.dailyGoal, (index) {
        final repetitionNumber = index + 1;
        final isCompleted = repetitionNumber <= habit.completedToday;
        final isNext = repetitionNumber == habit.completedToday + 1;
        
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted 
                ? AppColors.accentGreen 
                : isNext 
                    ? AppColors.accentGreen.withOpacity(0.3)
                    : AppColors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCompleted 
                  ? AppColors.accentGreen 
                  : isNext 
                      ? AppColors.accentGreen
                      : AppColors.white30,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted 
                ? const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 20,
                  )
                : Text(
                    '$repetitionNumber',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isNext 
                          ? AppColors.accentGreen 
                          : AppColors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  void _showAlreadyCompletedDialog(BuildContext context, habit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.accentGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Ya completado!',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '¡Felicidades! Ya completaste "${habit.name}" por hoy. 🎉\n\nVuelve mañana para continuar con tu racha.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white70,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Entendido',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Métodos auxiliares
  bool _isLoadingState(HabitsState state) {
    return state is HabitsLoading ||
           state is HabitCompleting ||
           state is HabitUncompleting ||
           state is HabitCreating ||
           state is HabitUpdating ||
           state is HabitDeleting;
  }

  bool _hasHabitsData(HabitsState state) {
    return state is HabitsLoaded ||
           state is HabitCreated ||
           state is HabitUpdated ||
           state is HabitDeleted ||
           state is HabitCompleted ||
           state is HabitUncompleted;
  }

  List<dynamic> _getHabitsFromState(HabitsState state) {
    if (state is HabitsLoaded) return state.habits;
    if (state is HabitCreated) return state.allHabits;
    if (state is HabitUpdated) return state.allHabits;
    if (state is HabitDeleted) return state.allHabits;
    if (state is HabitCompleted) return state.allHabits;
    if (state is HabitUncompleted) return state.allHabits;
    return [];
  }

  HabitsLoaded _getLoadedStateFromState(HabitsState state) {
    if (state is HabitsLoaded) return state;
    // Para otros estados, crear un HabitsLoaded temporal
    if (state is HabitCreated) return HabitsLoaded(habits: state.allHabits, categories: state.categories, temporaryProgress: state.temporaryProgress);
    if (state is HabitUpdated) return HabitsLoaded(habits: state.allHabits, categories: state.categories, temporaryProgress: state.temporaryProgress);
    if (state is HabitDeleted) return HabitsLoaded(habits: state.allHabits, categories: state.categories, temporaryProgress: state.temporaryProgress);
    if (state is HabitCompleted) return HabitsLoaded(habits: state.allHabits, categories: state.categories);
    if (state is HabitUncompleted) return HabitsLoaded(habits: state.allHabits, categories: state.categories);
    return const HabitsLoaded(habits: [], categories: []);
  }

  IconData _getIconData(String iconName) {
    // Mapeo simple de nombres de iconos a IconData
    switch (iconName) {
      case 'favorite': return Icons.favorite;
      case 'fitness_center': return Icons.fitness_center;
      case 'work': return Icons.work;
      case 'school': return Icons.school;
      case 'self_improvement': return Icons.self_improvement;
      case 'people': return Icons.people;
      case 'water_drop': return Icons.water_drop;
      case 'book': return Icons.book;
      case 'directions_run': return Icons.directions_run;
      default: return Icons.track_changes;
    }
  }
}
