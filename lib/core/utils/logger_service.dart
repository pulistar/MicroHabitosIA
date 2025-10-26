import 'package:logger/logger.dart';

/// Servicio centralizado de logging
class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log de información
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log de debug
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log de advertencia
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log de error
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log de error crítico
  static void critical(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log de evento importante
  static void event(String eventName, {Map<String, dynamic>? data}) {
    final message = data != null ? '$eventName: $data' : eventName;
    _logger.i('📊 EVENT: $message');
  }

  /// Log de inicio de operación
  static void startOperation(String operationName) {
    _logger.i('▶️ START: $operationName');
  }

  /// Log de fin de operación
  static void endOperation(String operationName) {
    _logger.i('✅ END: $operationName');
  }

  /// Log de deep link
  static void deepLink(String uri, {Map<String, String>? params}) {
    final message = params != null ? 'Deep link: $uri with params: $params' : 'Deep link: $uri';
    _logger.i('🔗 $message');
  }

  /// Log de autenticación
  static void auth(String message) {
    _logger.i('🔐 AUTH: $message');
  }

  /// Log de API call
  static void apiCall(String method, String endpoint, {dynamic body}) {
    final message = body != null ? '$method $endpoint with body: $body' : '$method $endpoint';
    _logger.i('🌐 API: $message');
  }
}
