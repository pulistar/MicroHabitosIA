/// Constantes globales de la aplicación
class AppConstants {
  // ==================== ESPACIADOS ====================
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing30 = 30;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing56 = 56;
  
  // Alias para compatibilidad
  static const double spacingXSmall = spacing4;
  static const double spacingSmall = spacing8;
  static const double spacingMedium = spacing16;
  static const double spacingLarge = spacing24;
  static const double spacingXLarge = spacing40;
  
  // Padding aliases
  static const double paddingSmall = spacing8;
  static const double paddingMedium = spacing16;
  static const double paddingLarge = spacing24;

  // ==================== BORDES REDONDEADOS ====================
  static const double borderRadius4 = 4;
  static const double borderRadius8 = 8;
  static const double borderRadius12 = 12;
  static const double borderRadius16 = 16;
  static const double borderRadius20 = 20;
  static const double borderRadius24 = 24;

  // ==================== TAMAÑOS DE FUENTE ====================
  static const double fontSizeSmall = 12;
  static const double fontSizeMedium = 14;
  static const double fontSizeBase = 16;
  static const double fontSizeLarge = 18;
  static const double fontSizeXLarge = 20;
  static const double fontSizeXXLarge = 24;
  static const double fontSizeHuge = 28;
  static const double fontSizeGiant = 32;

  // ==================== DURACIONES ====================
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration snackbarDuration = Duration(seconds: 4);

  // ==================== ELEVACIONES ====================
  static const double elevation0 = 0;
  static const double elevation2 = 2;
  static const double elevation4 = 4;
  static const double elevation8 = 8;
  static const double elevation12 = 12;
  static const double elevation16 = 16;

  // ==================== OPACIDADES ====================
  static const double opacity10 = 0.1;
  static const double opacity20 = 0.2;
  static const double opacity30 = 0.3;
  static const double opacity40 = 0.4;
  static const double opacity50 = 0.5;
  static const double opacity60 = 0.6;
  static const double opacity70 = 0.7;
  static const double opacity80 = 0.8;
  static const double opacity90 = 0.9;

  // ==================== TAMAÑOS DE IMÁGENES ====================
  static const double imageWidth = 250;
  static const double imageHeight = 250;
  static const double iconSize = 100;

  // ==================== RUTAS ====================
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeResetPassword = '/reset-password';

  // ==================== DEEP LINKS ====================
  static const String deepLinkScheme = 'com.micrero.app';
  static const String deepLinkAuthCallback = 'auth-callback';

  // ==================== MENSAJES ====================
  static const String errorGeneric = 'Algo salió mal. Intenta de nuevo.';
  static const String errorNetwork = 'Error de conexión. Verifica tu internet.';
  static const String errorServer = 'Error del servidor. Intenta más tarde.';
  static const String errorUnauthorized = 'No autorizado. Inicia sesión de nuevo.';
  static const String loadingMessage = 'Cargando...';
  static const String successMessage = 'Operación exitosa';
}
