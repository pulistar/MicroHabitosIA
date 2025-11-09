import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/utils/supabase_config.dart';
import 'core/utils/deep_link_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/authentication/presentation/pages/onboarding_page.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/authentication/presentation/widgets/auth_wrapper.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

import 'injection/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');
  
  // Inicializar Supabase PRIMERO
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  // Inicializar inyección de dependencias DESPUÉS
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    
    // Configurar deep link service
    DeepLinkService.setNavigatorKey(_navigatorKey);
    
    // Inicializar deep links después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'MicroHabits IA',
        navigatorKey: _navigatorKey,
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(
          authenticatedWidget: HomePage(),
          showOnboarding: true,
        ),
        routes: {
          AppConstants.routeOnboarding: (context) => const OnboardingPage(),
          AppConstants.routeLogin: (context) => const LoginPage(),
          AppConstants.routeHome: (context) => const AuthWrapper(
            authenticatedWidget: HomePage(),
          ),
        },
      ),
    );
  }
}

