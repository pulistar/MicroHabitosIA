import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/logger_service.dart';

/// Servicio para generar mensajes de notificación con IA
class AiNotificationService {
  final GenerativeModel model;

  AiNotificationService({required this.model});

  /// Generar mensaje motivacional personalizado
  Future<String> generateMotivationalMessage({
    required String userName,
    required int totalHabits,
    required int currentStreak,
    required int completedToday,
  }) async {
    try {
      final prompt = '''
Genera un mensaje motivacional CORTO (máximo 2 líneas) para una notificación de recordatorio de hábitos.

Contexto del usuario:
- Nombre: $userName
- Total de hábitos: $totalHabits
- Racha actual: $currentStreak días
- Completados hoy: $completedToday

El mensaje debe ser:
- MUY CORTO (máximo 2 líneas)
- Motivador y positivo
- Personalizado con el nombre si es apropiado
- Usar un emoji al final
- En español

Ejemplos:
- "¡Hola $userName! 💪 Llevas $currentStreak días de racha. ¡No la rompas hoy!"
- "Es hora de tus hábitos, $userName. ¡Cada día cuenta! 🌟"
- "¡$userName! Ya completaste $completedToday hábitos hoy. ¿Vamos por más? 🚀"

Genera SOLO el mensaje, sin comillas ni explicaciones.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final message = response.text?.trim() ?? _getDefaultMessage(userName);

      LoggerService.info('🔔 Mensaje de notificación generado por IA');
      return message;
    } catch (e) {
      LoggerService.error('Error al generar mensaje de notificación: $e');
      return _getDefaultMessage(userName);
    }
  }

  /// Generar mensaje para recordatorio de hábito específico
  Future<String> generateHabitReminder({
    required String habitName,
    required String userName,
  }) async {
    try {
      final prompt = '''
Genera un mensaje motivacional CORTO (1 línea) para recordar completar un hábito específico.

Hábito: $habitName
Usuario: $userName

El mensaje debe ser:
- UNA SOLA LÍNEA
- Motivador
- Específico al hábito
- Usar un emoji relacionado
- En español

Ejemplos:
- "¡Hora de $habitName, $userName! 💧"
- "No olvides: $habitName. ¡Tú puedes! 💪"
- "Recordatorio: $habitName te espera 🌟"

Genera SOLO el mensaje, sin comillas.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final message = response.text?.trim() ?? '¡Hora de $habitName! 💪';

      return message;
    } catch (e) {
      return '¡Hora de $habitName! 💪';
    }
  }

  /// Generar mensaje para racha en peligro
  Future<String> generateStreakWarning({
    required String userName,
    required int currentStreak,
  }) async {
    try {
      final prompt = '''
Genera un mensaje de URGENCIA CORTO (1-2 líneas) para advertir que la racha está en peligro.

Usuario: $userName
Racha actual: $currentStreak días

El mensaje debe ser:
- URGENTE pero motivador
- Mencionar la racha
- Usar emojis de urgencia/fuego
- En español

Ejemplos:
- "⚠️ ¡$userName! Tu racha de $currentStreak días está en peligro. ¡No la pierdas!"
- "🔥 ¡Cuidado! Llevas $currentStreak días. Completa tus hábitos HOY."

Genera SOLO el mensaje.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final message = response.text?.trim() ?? 
          '⚠️ ¡Tu racha de $currentStreak días está en peligro!';

      return message;
    } catch (e) {
      return '⚠️ ¡Tu racha de $currentStreak días está en peligro!';
    }
  }

  /// Mensaje por defecto si falla la IA
  String _getDefaultMessage(String userName) {
    final messages = [
      '¡Hola $userName! 💪 Es hora de tus hábitos.',
      '¡$userName! Recuerda completar tus hábitos hoy 🌟',
      '¡No olvides tus hábitos, $userName! 🚀',
      '¡Vamos $userName! Tus hábitos te esperan 💫',
    ];
    return messages[DateTime.now().second % messages.length];
  }
}
