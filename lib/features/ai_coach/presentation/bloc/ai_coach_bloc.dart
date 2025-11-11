import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/analyze_progress_usecase.dart';
import '../../domain/usecases/get_suggestions_usecase.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../microhabits/domain/repositories/habits_repository.dart';
import '../../../ranking/domain/repositories/ranking_repository.dart';
import 'ai_coach_event.dart';
import 'ai_coach_state.dart';

/// BLoC para manejar el estado del Coach IA
class AiCoachBloc extends Bloc<AiCoachEvent, AiCoachState> {
  final SendMessageUseCase sendMessageUseCase;
  final AnalyzeProgressUseCase analyzeProgressUseCase;
  final GetSuggestionsUseCase getSuggestionsUseCase;
  final HomeRepository homeRepository;
  final HabitsRepository habitsRepository;
  final RankingRepository rankingRepository;
  final Uuid uuid = const Uuid();

  List<ChatMessageEntity> _messages = [];
  List<String> _suggestions = [];
  Map<String, dynamic>? _pendingHabit; // Hábito pendiente de confirmación

  AiCoachBloc({
    required this.sendMessageUseCase,
    required this.analyzeProgressUseCase,
    required this.getSuggestionsUseCase,
    required this.homeRepository,
    required this.habitsRepository,
    required this.rankingRepository,
  }) : super(const AiCoachInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<AnalyzeProgressEvent>(_onAnalyzeProgress);
    on<LoadSuggestionsEvent>(_onLoadSuggestions);
    on<ClearChatEvent>(_onClearChat);

    // Cargar sugerencias al iniciar
    add(const LoadSuggestionsEvent());
    
    // Mensaje de bienvenida
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessageEntity(
      id: uuid.v4(),
      content: '¡Hola! 👋 Soy tu Coach de Hábitos. Estoy aquí para ayudarte a alcanzar tus metas. ¿En qué puedo ayudarte hoy?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(welcomeMessage);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<AiCoachState> emit,
  ) async {
    try {
      // Verificar si el usuario está confirmando un hábito
      final lowerMessage = event.message.toLowerCase().trim();
      if (_pendingHabit != null && (lowerMessage == 'sí' || lowerMessage == 'si' || lowerMessage == 'yes')) {
        await _createHabitFromSuggestion(emit);
        return;
      }

      // Agregar mensaje del usuario
      final userMessage = ChatMessageEntity(
        id: uuid.v4(),
        content: event.message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);

      // Emitir estado de carga
      emit(AiCoachLoading(messages: List.from(_messages), suggestions: _suggestions));

      // Enviar mensaje al Coach IA
      final response = await sendMessageUseCase(event.message, _messages);
      _messages.add(response);

      // Detectar si el Coach sugirió un hábito
      _detectHabitSuggestion(response.content);

      // Emitir estado con la respuesta
      emit(AiCoachLoaded(messages: List.from(_messages), suggestions: _suggestions));
    } catch (e) {
      emit(AiCoachError(
        message: 'Error al enviar mensaje: $e',
        messages: List.from(_messages),
        suggestions: _suggestions,
      ));
    }
  }

  void _detectHabitSuggestion(String message) {
    // Buscar el patrón [HABIT:nombre|categoria|descripcion]
    final habitPattern = RegExp(r'\[HABIT:(.*?)\|(.*?)\|(.*?)\]');
    final match = habitPattern.firstMatch(message);
    
    if (match != null) {
      _pendingHabit = {
        'name': match.group(1)?.trim() ?? '',
        'category': match.group(2)?.trim() ?? '',
        'description': match.group(3)?.trim() ?? '',
      };
    }
  }

  Future<void> _createHabitFromSuggestion(Emitter<AiCoachState> emit) async {
    if (_pendingHabit == null) return;

    try {
      // Agregar mensaje de confirmación del usuario
      final userMessage = ChatMessageEntity(
        id: uuid.v4(),
        content: 'Sí',
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);

      emit(AiCoachLoading(messages: List.from(_messages), suggestions: _suggestions));

      // Crear el hábito
      final result = await habitsRepository.createHabit(
        name: _pendingHabit!['name'],
        description: _pendingHabit!['description'],
        category: _pendingHabit!['category'],
        color: _getCategoryColor(_pendingHabit!['category']),
        icon: _getCategoryIcon(_pendingHabit!['category']),
        dailyGoal: 1,
      );

      result.fold(
        (failure) {
          final errorMessage = ChatMessageEntity(
            id: uuid.v4(),
            content: 'Lo siento, hubo un error al crear el hábito. ¿Quieres intentarlo de nuevo?',
            isUser: false,
            timestamp: DateTime.now(),
          );
          _messages.add(errorMessage);
        },
        (_) {
          final successMessage = ChatMessageEntity(
            id: uuid.v4(),
            content: '¡Perfecto! ✅ He agregado "${_pendingHabit!['name']}" a tus hábitos. ¡Vamos a por ello! 💪',
            isUser: false,
            timestamp: DateTime.now(),
          );
          _messages.add(successMessage);
          _pendingHabit = null; // Limpiar hábito pendiente
        },
      );

      emit(AiCoachLoaded(messages: List.from(_messages), suggestions: _suggestions));
    } catch (e) {
      emit(AiCoachError(
        message: 'Error al crear hábito: $e',
        messages: List.from(_messages),
        suggestions: _suggestions,
      ));
    }
  }

  String _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'salud':
        return '#4CAF50';
      case 'productividad':
        return '#2196F3';
      case 'bienestar':
        return '#9C27B0';
      case 'ejercicio':
        return '#FF5722';
      case 'alimentación':
        return '#FF9800';
      default:
        return '#607D8B';
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salud':
        return 'favorite';
      case 'productividad':
        return 'work';
      case 'bienestar':
        return 'self_improvement';
      case 'ejercicio':
        return 'fitness_center';
      case 'alimentación':
        return 'restaurant';
      default:
        return 'check_circle';
    }
  }

  Future<void> _onAnalyzeProgress(
    AnalyzeProgressEvent event,
    Emitter<AiCoachState> emit,
  ) async {
    try {
      // Agregar mensaje del usuario
      final userMessage = ChatMessageEntity(
        id: uuid.v4(),
        content: 'Analiza mi progreso',
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);

      // Emitir estado de carga
      emit(AiCoachLoading(messages: List.from(_messages), suggestions: _suggestions));

      // Obtener datos reales del usuario
      final dashboardResult = await homeRepository.getDashboardData();
      final habitsResult = await habitsRepository.getUserHabits();
      final rankingResult = await rankingRepository.getWeeklyRanking();

      // Extraer datos del Either
      final dashboard = dashboardResult.fold(
        (failure) => throw Exception('Error al obtener dashboard'),
        (data) => data,
      );
      
      final habitsList = habitsResult.fold(
        (failure) => throw Exception('Error al obtener hábitos'),
        (data) => data,
      );

      final ranking = rankingResult.fold(
        (failure) => null, // Si falla, continuamos sin ranking
        (data) => data,
      );

      // Encontrar la posición del usuario en el ranking
      int? userPosition;
      int? userCompletions;
      int? totalUsers;
      if (ranking != null) {
        totalUsers = ranking.length;
        for (int i = 0; i < ranking.length; i++) {
          if (ranking[i].userId == dashboard.userProfile.id) {
            userPosition = i + 1; // Posición 1-indexed
            userCompletions = ranking[i].weeklyCompletions;
            break;
          }
        }
      }

      // Construir datos del usuario para análisis
      final userData = {
        'total_habits': dashboard.userProfile.totalHabits,
        'completed_today': dashboard.userProfile.completedToday,
        'current_streak': dashboard.userProfile.currentStreak,
        'longest_streak': dashboard.userProfile.longestStreak,
        'weekly_progress': dashboard.weeklyProgress,
        'habits': habitsList.map((h) => {
          'name': h.name,
          'category': h.category,
          'daily_goal': h.dailyGoal,
          'completed_today': h.completedToday,
          'total_completions': h.totalCompletions,
          'current_streak': h.currentStreak,
          'longest_streak': h.longestStreak,
          'is_active': h.isActive,
        }).toList(),
        'ranking': {
          'position': userPosition,
          'completions': userCompletions,
          'total_users': totalUsers,
          'top_3': ranking != null && ranking.length >= 3
              ? ranking.take(3).map((r) => {
                  'name': r.displayName,
                  'completions': r.weeklyCompletions,
                  'streak': r.currentStreak,
                }).toList()
              : [],
        },
      };

      // Analizar progreso con datos reales
      final analysis = await analyzeProgressUseCase(userData);

      // Agregar respuesta del Coach
      final coachMessage = ChatMessageEntity(
        id: uuid.v4(),
        content: analysis,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(coachMessage);

      // Emitir estado con la respuesta
      emit(AiCoachLoaded(messages: List.from(_messages), suggestions: _suggestions));
    } catch (e) {
      emit(AiCoachError(
        message: 'Error al analizar progreso: $e',
        messages: List.from(_messages),
        suggestions: _suggestions,
      ));
    }
  }

  Future<void> _onLoadSuggestions(
    LoadSuggestionsEvent event,
    Emitter<AiCoachState> emit,
  ) async {
    try {
      _suggestions = await getSuggestionsUseCase();
      emit(AiCoachLoaded(messages: List.from(_messages), suggestions: _suggestions));
    } catch (e) {
      // Si falla, usar sugerencias por defecto
      _suggestions = [
        '💪 ¿Cómo puedo mantener mi racha?',
        '🎯 Dame consejos para crear un nuevo hábito',
        '📊 Analiza mi progreso',
      ];
      emit(AiCoachLoaded(messages: List.from(_messages), suggestions: _suggestions));
    }
  }

  Future<void> _onClearChat(
    ClearChatEvent event,
    Emitter<AiCoachState> emit,
  ) async {
    _messages.clear();
    _addWelcomeMessage();
    emit(AiCoachLoaded(messages: List.from(_messages), suggestions: _suggestions));
  }
}
