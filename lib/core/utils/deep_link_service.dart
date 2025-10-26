import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger_service.dart';
import '../constants/app_constants.dart';

class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static GlobalKey<NavigatorState>? navigatorKey;
  
  static Future<void> initialize(BuildContext context) async {
    // Manejar deep links cuando la app está cerrada
    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
    
    // Manejar deep links cuando la app está abierta
    _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
    );
  }
  
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }
  
  static void _handleDeepLink(Uri uri) {
    LoggerService.deepLink(uri.toString(), params: uri.queryParameters);
    
    // Verificar si es un deep link de auth callback
    if (uri.scheme == AppConstants.deepLinkScheme && 
        uri.host == AppConstants.deepLinkAuthCallback) {
      // Para OAuth: NO navegar automáticamente. Supabase actualizará la sesión.
      // Solo navegamos a Reset Password cuando el tipo sea explícitamente 'recovery'.
      final type = uri.queryParameters['type'];
      if (type == 'recovery') {
        LoggerService.auth('Deep Link: Password recovery');
        navigatorKey?.currentState?.pushNamedAndRemoveUntil(
          AppConstants.routeResetPassword,
          (route) => false,
        );
        return;
      }

      // Si existe sesión válida, la app (AuthWrapper/Bloc) llevará al Home.
      // Aquí solo registramos el evento para evitar redirecciones erróneas con enlaces viejos.
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      LoggerService.auth('Deep Link auth-callback recibido. hasSession=$hasSession (no navegamos desde DeepLinkService)');
    }
  }
  
}
