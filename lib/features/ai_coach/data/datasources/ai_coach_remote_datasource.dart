import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/utils/logger_service.dart';
import '../models/chat_message_model.dart';

/// Interfaz para el datasource del Coach IA
abstract class AiCoachRemoteDataSource {
  Future<ChatMessageModel> sendMessage(String message, List<ChatMessageModel> conversationHistory);
  Future<String> analyzeUserProgress(Map<String, dynamic> userData);
  Future<List<String>> getSuggestions();
}

/// Implementación del datasource usando Gemini AI
class AiCoachRemoteDataSourceImpl implements AiCoachRemoteDataSource {
  final GenerativeModel model;
  
  AiCoachRemoteDataSourceImpl({required this.model});

  /// Prompt del sistema que define el comportamiento del Coach
  String get _systemPrompt => '''
Eres un Coach de Hábitos IA llamado "MicroCoach". Tu objetivo es ayudar a los usuarios a:
- Desarrollar y mantener microhábitos saludables
- Mantenerse motivados en su progreso
- Superar obstáculos y mantener rachas
- Celebrar sus logros
- Sugerir y crear hábitos personalizados

Características de tu personalidad:
- Empático y motivador
- Conciso y directo (respuestas cortas)
- Positivo pero realista
- Usa emojis ocasionalmente para ser más cercano
- Hablas en español de forma natural

Reglas importantes:
- Respuestas máximo 3-4 líneas
- Enfócate en acciones concretas
- Celebra los pequeños logros
- Si el usuario está desmotivado, sé comprensivo pero anímalo
- Sugiere estrategias basadas en ciencia del comportamiento

IMPORTANTE - Análisis de Ranking:
Cuando analices el progreso del usuario, SIEMPRE menciona su posición en el ranking si está disponible.
El ranking se basa en completaciones semanales de hábitos.
Ejemplos:
- "¡Estás en el puesto 3 del ranking con 45 completaciones esta semana! 🏆 Muy cerca del top. Sigue así."
- "Vi que estás en el puesto 15 con 20 completaciones. ¡No te desanimes! Cada hábito cuenta. 💪"
- "¡Increíble! Estás en el TOP 3 del ranking con 60 completaciones. Eres un ejemplo para todos. 🌟"

Usa los datos del ranking (posición, completaciones, total de usuarios) para motivar y dar contexto.

IMPORTANTE - Sugerencia de hábitos:
Cuando el usuario te pida sugerir un hábito, responde en este formato EXACTO:
[HABIT:nombre_del_habito|categoria|descripcion]
Ejemplo: [HABIT:Beber agua|Salud|Tomar un vaso de agua al despertar]

Categorías válidas: Salud, Productividad, Bienestar, Ejercicio, Alimentación

Después del formato, pregunta: "¿Quieres que lo agregue a tus hábitos?"
''';

  @override
  Future<ChatMessageModel> sendMessage(
    String message,
    List<ChatMessageModel> conversationHistory,
  ) async {
    try {
      LoggerService.info('🤖 Enviando mensaje al Coach IA');
      
      // Construir el historial de conversación
      final history = conversationHistory.map((msg) {
        return Content.text('${msg.isUser ? "Usuario" : "Coach"}: ${msg.content}');
      }).toList();

      // Agregar el prompt del sistema y el mensaje actual
      final prompt = [
        Content.text(_systemPrompt),
        ...history,
        Content.text('Usuario: $message'),
      ];

      // Generar respuesta
      final response = await model.generateContent(prompt);
      final responseText = response.text ?? 'Lo siento, no pude generar una respuesta.';

      LoggerService.info('✅ Respuesta del Coach recibida');

      // Crear modelo de respuesta
      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: responseText.trim(),
        isUser: false,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      LoggerService.error('Error al enviar mensaje al Coach: $e');
      
      // Verificar si es un error de API Key
      final errorMessage = e.toString();
      String fallbackMessage;
      
      if (errorMessage.contains('not found') || errorMessage.contains('API version')) {
        fallbackMessage = '''
🔧 Configuración necesaria:

1. Ve a: https://aistudio.google.com/app/apikey
2. Crea una nueva API Key
3. Asegúrate de habilitar "Generative Language API"
4. Actualiza tu archivo .env con la nueva clave

Mientras tanto, estoy aquí para ayudarte con consejos generales sobre hábitos. 💪

¿En qué puedo ayudarte?
''';
      } else {
        fallbackMessage = 'Lo siento, tuve un problema al procesar tu mensaje. ¿Puedes intentarlo de nuevo? 🤔';
      }
      
      // Respuesta de fallback
      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: fallbackMessage,
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<String> analyzeUserProgress(Map<String, dynamic> userData) async {
    try {
      LoggerService.info('📊 Analizando progreso del usuario');
      
      final totalHabits = userData['total_habits'] ?? 0;
      final completedToday = userData['completed_today'] ?? 0;
      final currentStreak = userData['current_streak'] ?? 0;
      final longestStreak = userData['longest_streak'] ?? 0;

      final prompt = Content.text('''
$_systemPrompt

Analiza el progreso del usuario y dale un feedback motivador:

Estadísticas:
- Total de hábitos: $totalHabits
- Completados hoy: $completedToday
- Racha actual: $currentStreak días
- Racha más larga: $longestStreak días

Da un análisis breve (máximo 4 líneas) con:
1. Reconocimiento de su progreso
2. Un consejo específico para mejorar
3. Palabras de ánimo
''');

      final response = await model.generateContent([prompt]);
      final analysis = response.text ?? 'Sigue así, vas muy bien! 💪';

      LoggerService.info('✅ Análisis completado');
      return analysis.trim();
    } catch (e) {
      LoggerService.error('Error al analizar progreso: $e');
      return '¡Vas por buen camino! Sigue construyendo tus hábitos día a día. 🌟';
    }
  }

  @override
  Future<List<String>> getSuggestions() async {
    return [
      '💪 ¿Cómo puedo mantener mi racha?',
      '🎯 Dame consejos para crear un nuevo hábito',
      '📊 Analiza mi progreso',
      '🚀 ¿Cómo puedo mejorar?',
      '💡 Sugiéreme hábitos saludables',
      '⏰ ¿Cuál es el mejor momento para hacer ejercicio?',
    ];
  }
}
