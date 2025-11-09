import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger_service.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/habit_category_entity.dart';
import '../../domain/usecases/get_user_habits_usecase.dart';
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/complete_habit_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/repositories/habits_repository.dart';
import 'habits_event.dart';
import 'habits_state.dart';

/// BLoC para manejar el estado de los hábitos
class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
  final GetUserHabitsUseCase getUserHabitsUseCase;
  final CreateHabitUseCase createHabitUseCase;
  final CompleteHabitUseCase completeHabitUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final HabitsRepository habitsRepository;

  HabitsBloc({
    required this.getUserHabitsUseCase,
    required this.createHabitUseCase,
    required this.completeHabitUseCase,
    required this.getCategoriesUseCase,
    required this.habitsRepository,
  }) : super(const HabitsInitial()) {
    on<LoadHabitsEvent>(_onLoadHabits);
    on<RefreshHabitsEvent>(_onRefreshHabits);
    on<CreateHabitEvent>(_onCreateHabit);
    on<UpdateHabitEvent>(_onUpdateHabit);
    on<DeleteHabitEvent>(_onDeleteHabit);
    on<CompleteHabitEvent>(_onCompleteHabit);
    on<UncompleteHabitEvent>(_onUncompleteHabit);
    on<IncrementTemporaryProgressEvent>(_onIncrementTemporaryProgress);
    on<ClearTemporaryProgressEvent>(_onClearTemporaryProgress);
    on<LoadCategoriesEvent>(_onLoadCategories);
  }


  Future<void> _onRefreshHabits(
    RefreshHabitsEvent event,
    Emitter<HabitsState> emit,
  ) async {
    // No mostrar loading si ya hay datos cargados
    if (state is! HabitsLoaded) {
      emit(const HabitsLoading());
    }

    LoggerService.info('Refrescando hábitos del usuario');

    // 🔄 LIMPIAR PROGRESO TEMPORAL DEL DÍA ANTERIOR (si es un nuevo día)
    final cleanupResult = await habitsRepository.cleanupOldTemporaryProgress();
    cleanupResult.fold(
      (failure) => LoggerService.warning('⚠️ Error al limpiar progreso antiguo: ${failure.message}'),
      (_) => LoggerService.info('✅ Progreso temporal antiguo limpiado'),
    );

    final habitsResult = await getUserHabitsUseCase(NoParams());
    final categoriesResult = await getCategoriesUseCase(NoParams());

    if (habitsResult.isLeft() || categoriesResult.isLeft()) {
      final errorMessage = habitsResult.isLeft() 
          ? habitsResult.fold((l) => l.message, (r) => '')
          : categoriesResult.fold((l) => l.message, (r) => '');
      
      LoggerService.error('Error al refrescar hábitos: $errorMessage');
      emit(HabitsError(errorMessage));
      return;
    }

    final habits = habitsResult.getOrElse(() => []);
    final categories = categoriesResult.getOrElse(() => []);

    // Cargar progreso temporal (sin bloquear si falla)
    final temporaryProgressResult = await habitsRepository.getTemporaryProgress();
    final temporaryProgress = temporaryProgressResult.getOrElse(() => <String, int>{});

    LoggerService.info('Hábitos refrescados: ${habits.length}');
    emit(HabitsLoaded(
      habits: habits, 
      categories: categories,
      temporaryProgress: temporaryProgress,
    ));
  }

  Future<void> _onCreateHabit(
    CreateHabitEvent event,
    Emitter<HabitsState> emit,
  ) async {
    emit(const HabitCreating());
    LoggerService.info('Creando nuevo hábito: ${event.name}');

    final params = CreateHabitParams(
      name: event.name,
      description: event.description,
      category: event.category,
      color: event.color,
      icon: event.icon,
      dailyGoal: event.dailyGoal,
    );

    final result = await createHabitUseCase(params);

    await result.fold(
      (failure) async {
        LoggerService.error('Error al crear hábito: ${failure.message}');
        if (!emit.isDone) {
          emit(HabitsError(failure.message));
        }
      },
      (newHabit) async {
        LoggerService.info('Hábito creado exitosamente: ${newHabit.name}');
        
        // Recargar la lista completa de hábitos
        final habitsResult = await getUserHabitsUseCase(NoParams());
        final categoriesResult = await getCategoriesUseCase(NoParams());
        
        if (habitsResult.isRight() && categoriesResult.isRight()) {
          final habits = habitsResult.getOrElse(() => []);
          final categories = categoriesResult.getOrElse(() => []);
          
          // Cargar progreso temporal
          final temporaryProgressResult = await habitsRepository.getTemporaryProgress();
          final temporaryProgress = temporaryProgressResult.getOrElse(() => <String, int>{});
          
          if (!emit.isDone) {
            emit(HabitCreated(
              habit: newHabit,
              allHabits: habits,
              categories: categories,
              temporaryProgress: temporaryProgress,
            ));
          }
        } else {
          if (!emit.isDone) {
            emit(const HabitsError('Error al recargar hábitos después de crear'));
          }
        }
      },
    );
  }

  Future<void> _onUpdateHabit(
    UpdateHabitEvent event,
    Emitter<HabitsState> emit,
  ) async {
    final currentState = state;
    emit(const HabitUpdating());
    LoggerService.info('Actualizando hábito: ${event.habitId}');

    final result = await habitsRepository.updateHabit(
      habitId: event.habitId,
      name: event.name,
      description: event.description,
      category: event.category,
      color: event.color,
      icon: event.icon,
      isActive: event.isActive,
      dailyGoal: event.dailyGoal,
    );

    await result.fold(
      (failure) async {
        LoggerService.error('Error al actualizar hábito: ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (updatedHabit) async {
        LoggerService.info('Hábito actualizado exitosamente: ${updatedHabit.name}');
        
        // Obtener el estado actual para mantener las categorías y progreso temporal
        final categories = currentState is HabitsLoaded 
            ? currentState.categories 
            : <HabitCategoryEntity>[];
        final temporaryProgress = currentState is HabitsLoaded 
            ? currentState.temporaryProgress 
            : <String, int>{};
        
        // Recargar solo los hábitos (más rápido)
        final habitsResult = await getUserHabitsUseCase(NoParams());
        
        habitsResult.fold(
          (failure) {
            LoggerService.error('Error al recargar hábitos: ${failure.message}');
            emit(HabitsError(failure.message));
          },
          (habits) {
            LoggerService.info('🚀 Emitiendo HabitUpdated para: ${updatedHabit.name}');
            emit(HabitUpdated(
              habit: updatedHabit,
              allHabits: habits,
              categories: categories,
              temporaryProgress: temporaryProgress,
            ));
            LoggerService.info('✅ HabitUpdated emitido correctamente');
          },
        );
      },
    );
  }

  Future<void> _onDeleteHabit(
    DeleteHabitEvent event,
    Emitter<HabitsState> emit,
  ) async {
    final currentState = state;
    emit(const HabitDeleting());
    LoggerService.info('Eliminando hábito: ${event.habitId}');

    final result = await habitsRepository.deleteHabit(event.habitId);

    await result.fold(
      (failure) async {
        LoggerService.error('Error al eliminar hábito: ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (_) async {
        LoggerService.info('Hábito eliminado exitosamente: ${event.habitId}');
        
        // Obtener el estado actual para mantener las categorías y progreso temporal
        final categories = currentState is HabitsLoaded 
            ? currentState.categories 
            : <HabitCategoryEntity>[];
        final temporaryProgress = currentState is HabitsLoaded 
            ? currentState.temporaryProgress 
            : <String, int>{};
        
        // Recargar solo los hábitos (más rápido)
        final habitsResult = await getUserHabitsUseCase(NoParams());
        
        habitsResult.fold(
          (failure) {
            LoggerService.error('Error al recargar hábitos: ${failure.message}');
            emit(HabitsError(failure.message));
          },
          (habits) {
            LoggerService.info('🚀 Emitiendo HabitDeleted');
            emit(HabitDeleted(
              habitId: event.habitId,
              allHabits: habits,
              categories: categories,
              temporaryProgress: temporaryProgress,
            ));
            LoggerService.info('✅ HabitDeleted emitido correctamente');
          },
        );
      },
    );
  }

  Future<void> _onCompleteHabit(
    CompleteHabitEvent event,
    Emitter<HabitsState> emit,
  ) async {
    final currentState = state;
    emit(const HabitCompleting());
    LoggerService.info('Completando hábito: ${event.habitId}');

    final params = CompleteHabitParams(
      habitId: event.habitId,
      notes: event.notes,
    );

    final result = await completeHabitUseCase(params);

    await result.fold(
      (failure) async {
        LoggerService.error('Error al completar hábito: ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (_) async {
        LoggerService.info('Hábito completado exitosamente: ${event.habitId}');
        
        // Obtener el estado actual para mantener las categorías y progreso temporal
        final categories = currentState is HabitsLoaded 
            ? currentState.categories 
            : <HabitCategoryEntity>[];
        final temporaryProgress = currentState is HabitsLoaded 
            ? currentState.temporaryProgress 
            : <String, int>{};
        
        // Recargar solo los hábitos (más rápido)
        final habitsResult = await getUserHabitsUseCase(NoParams());
        
        habitsResult.fold(
          (failure) {
            LoggerService.error('Error al recargar hábitos: ${failure.message}');
            emit(HabitsError(failure.message));
          },
          (habits) {
            LoggerService.info('🚀 Emitiendo HabitCompleted');
            emit(HabitCompleted(
              habitId: event.habitId,
              allHabits: habits,
              categories: categories,
            ));
            LoggerService.info('✅ HabitCompleted emitido correctamente');
          },
        );
      },
    );
  }

  Future<void> _onUncompleteHabit(
    UncompleteHabitEvent event,
    Emitter<HabitsState> emit,
  ) async {
    final currentState = state;
    emit(const HabitUncompleting());
    LoggerService.info('Descompletando hábito: ${event.habitId}');

    final result = await habitsRepository.uncompleteHabit(event.habitId);

    await result.fold(
      (failure) async {
        LoggerService.error('Error al descompletar hábito: ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (_) async {
        LoggerService.info('Hábito descompletado exitosamente: ${event.habitId}');
        
        // Obtener el estado actual para mantener las categorías y progreso temporal
        final categories = currentState is HabitsLoaded 
            ? currentState.categories 
            : <HabitCategoryEntity>[];
        final temporaryProgress = currentState is HabitsLoaded 
            ? currentState.temporaryProgress 
            : <String, int>{};
        
        // Recargar solo los hábitos (más rápido)
        final habitsResult = await getUserHabitsUseCase(NoParams());
        
        habitsResult.fold(
          (failure) {
            LoggerService.error('Error al recargar hábitos: ${failure.message}');
            emit(HabitsError(failure.message));
          },
          (habits) {
            LoggerService.info('🚀 Emitiendo HabitUncompleted');
            emit(HabitUncompleted(
              habitId: event.habitId,
              allHabits: habits,
              categories: categories,
            ));
            LoggerService.info('✅ HabitUncompleted emitido correctamente');
          },
        );
      },
    );
  }

  Future<void> _onLoadHabits(
    LoadHabitsEvent event,
    Emitter<HabitsState> emit,
  ) async {
    emit(const HabitsLoading());
    LoggerService.info('Cargando hábitos del usuario');

    // 🔄 LIMPIAR PROGRESO TEMPORAL DEL DÍA ANTERIOR (si es un nuevo día)
    LoggerService.info('🧹 Limpiando progreso temporal antiguo...');
    final cleanupResult = await habitsRepository.cleanupOldTemporaryProgress();
    cleanupResult.fold(
      (failure) => LoggerService.warning('⚠️ Error al limpiar progreso antiguo: ${failure.message}'),
      (_) => LoggerService.info('✅ Progreso temporal antiguo limpiado correctamente'),
    );

    // Cargar hábitos y categorías en paralelo
    final habitsResult = await getUserHabitsUseCase(NoParams());
    final categoriesResult = await getCategoriesUseCase(NoParams());

    if (habitsResult.isLeft() || categoriesResult.isLeft()) {
      final errorMessage = habitsResult.isLeft() 
          ? habitsResult.fold((l) => l.message, (r) => '')
          : categoriesResult.fold((l) => l.message, (r) => '');
      
      LoggerService.error('Error al cargar hábitos: $errorMessage');
      emit(HabitsError(errorMessage));
      return;
    }

    final habits = habitsResult.getOrElse(() => []);
    final categories = categoriesResult.getOrElse(() => []);

    // Cargar progreso temporal (sin bloquear si falla)
    final temporaryProgressResult = await habitsRepository.getTemporaryProgress();
    final temporaryProgress = temporaryProgressResult.getOrElse(() => <String, int>{});

    LoggerService.info('Hábitos cargados: ${habits.length}');
    emit(HabitsLoaded(
      habits: habits, 
      categories: categories,
      temporaryProgress: temporaryProgress,
    ));
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<HabitsState> emit,
  ) async {
    LoggerService.info('Cargando categorías de hábitos');

    final result = await getCategoriesUseCase(NoParams());

    result.fold(
      (failure) {
        LoggerService.error('Error al cargar categorías: ${failure.message}');
        emit(HabitsError(failure.message));
      },
      (categories) {
        LoggerService.info('Categorías cargadas: ${categories.length}');
        // Si ya hay hábitos cargados, mantenerlos
        if (state is HabitsLoaded) {
          final currentState = state as HabitsLoaded;
          emit(currentState.copyWith(categories: categories));
        } else {
          emit(HabitsLoaded(
            habits: const [], 
            categories: categories,
            temporaryProgress: const {},
          ));
        }
      },
    );
  }

  // ==================== TEMPORARY PROGRESS HANDLERS ====================

  Future<void> _onIncrementTemporaryProgress(
    IncrementTemporaryProgressEvent event,
    Emitter<HabitsState> emit,
  ) async {
    final currentState = state;
    if (currentState is HabitsLoaded) {
      // Obtener el hábito para verificar el dailyGoal
      final habit = currentState.habits.firstWhere((h) => h.id == event.habitId);
      
      // Si ya completó el hábito hoy, no permitir más progreso temporal
      if (habit.completedToday > 0) {
        LoggerService.info('Hábito ya completado hoy, no se permite más progreso temporal');
        return;
      }
      
      // Obtener progreso temporal actual (solo progreso interno)
      final currentTempProgress = currentState.temporaryProgress[event.habitId] ?? 0;
      
      // Solo incrementar si no ha llegado al objetivo diario
      if (currentTempProgress < habit.dailyGoal) {
        final newTempCount = currentTempProgress + 1;
        
        // Si llegó al objetivo diario, completar automáticamente
        if (newTempCount >= habit.dailyGoal) {
          // Limpiar progreso temporal y completar hábito
          final clearResult = await habitsRepository.clearTemporaryProgress(event.habitId);
          clearResult.fold(
            (failure) => LoggerService.warning('Error al limpiar progreso temporal: ${failure.message}'),
            (_) => LoggerService.info('Progreso temporal limpiado para completar hábito'),
          );
          
          // Actualizar estado local y completar
          final newTemporaryProgress = Map<String, int>.from(currentState.temporaryProgress);
          newTemporaryProgress.remove(event.habitId);
          if (!emit.isDone) {
            emit(currentState.copyWith(temporaryProgress: newTemporaryProgress));
            add(CompleteHabitEvent(habitId: event.habitId));
          }
        } else {
          // Guardar progreso temporal en la base de datos
          final result = await habitsRepository.saveTemporaryProgress(
            habitId: event.habitId,
            tempCount: newTempCount,
          );
          
          result.fold(
            (failure) {
              LoggerService.error('Error al guardar progreso temporal: ${failure.message}');
              // Fallback: actualizar solo en memoria
              if (!emit.isDone) {
                final newTemporaryProgress = Map<String, int>.from(currentState.temporaryProgress);
                newTemporaryProgress[event.habitId] = newTempCount;
                emit(currentState.copyWith(temporaryProgress: newTemporaryProgress));
              }
            },
            (temporaryProgress) {
              LoggerService.info('Progreso temporal guardado: ${temporaryProgress.tempCount}');
              // Actualizar estado local
              if (!emit.isDone) {
                final newTemporaryProgress = Map<String, int>.from(currentState.temporaryProgress);
                newTemporaryProgress[event.habitId] = newTempCount;
                emit(currentState.copyWith(temporaryProgress: newTemporaryProgress));
              }
            },
          );
        }
      }
    }
  }

  Future<void> _onClearTemporaryProgress(
    ClearTemporaryProgressEvent event,
    Emitter<HabitsState> emit,
  ) async {
    final currentState = state;
    if (currentState is HabitsLoaded) {
      // Limpiar de la base de datos
      final result = await habitsRepository.clearTemporaryProgress(event.habitId);
      result.fold(
        (failure) => LoggerService.warning('Error al limpiar progreso temporal: ${failure.message}'),
        (_) => LoggerService.info('Progreso temporal limpiado correctamente'),
      );
      
      // Actualizar estado local (siempre, independientemente del resultado de BD)
      final newTemporaryProgress = Map<String, int>.from(currentState.temporaryProgress);
      newTemporaryProgress.remove(event.habitId);
      emit(currentState.copyWith(temporaryProgress: newTemporaryProgress));
    }
  }
}
