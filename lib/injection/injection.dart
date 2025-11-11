import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/local_storage/hive_service.dart';
import '../core/local_storage/preferences_service.dart';
import '../core/local_storage/sync_service.dart';
import '../features/authentication/domain/usecases/get_onboarding_items.dart';
import '../features/authentication/presentation/bloc/onboarding_bloc.dart';
import '../features/authentication/domain/usecases/login_with_email_usecase.dart';
import '../features/authentication/domain/usecases/login_with_google_usecase.dart';
import '../features/authentication/domain/usecases/signup_usecase.dart';
import '../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../features/authentication/domain/usecases/is_user_authenticated_usecase.dart';
import '../features/authentication/domain/usecases/logout_usecase.dart';
import '../features/authentication/presentation/bloc/login_bloc.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';
import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';

// Home imports
import '../features/home/domain/usecases/get_user_profile_usecase.dart';
import '../features/home/domain/usecases/get_dashboard_data_usecase.dart';
import '../features/home/domain/usecases/logout_usecase.dart' as home_logout;
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/home/data/datasources/home_remote_datasource.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';

// MicroHabits imports
import '../features/microhabits/domain/usecases/get_user_habits_usecase.dart';
import '../features/microhabits/domain/usecases/create_habit_usecase.dart';
import '../features/microhabits/domain/usecases/complete_habit_usecase.dart';
import '../features/microhabits/domain/usecases/get_categories_usecase.dart';
import '../features/microhabits/presentation/bloc/habits_bloc.dart';
import '../features/microhabits/data/datasources/habits_remote_datasource.dart';
import '../features/microhabits/data/repositories/habits_repository_impl.dart';
import '../features/microhabits/domain/repositories/habits_repository.dart';

// Ranking imports
import '../features/ranking/domain/usecases/get_weekly_ranking_usecase.dart';
import '../features/ranking/presentation/bloc/ranking_bloc.dart';
import '../features/ranking/data/datasources/ranking_remote_datasource.dart';
import '../features/ranking/data/repositories/ranking_repository_impl.dart';
import '../features/ranking/domain/repositories/ranking_repository.dart';

// AI Coach imports
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/ai_coach/domain/usecases/send_message_usecase.dart';
import '../features/ai_coach/domain/usecases/analyze_progress_usecase.dart';
import '../features/ai_coach/domain/usecases/get_suggestions_usecase.dart';
import '../features/ai_coach/presentation/bloc/ai_coach_bloc.dart';
import '../features/ai_coach/data/datasources/ai_coach_remote_datasource.dart';
import '../features/ai_coach/data/repositories/ai_coach_repository_impl.dart';
import '../features/ai_coach/domain/repositories/ai_coach_repository.dart';

// Notifications imports
import '../core/notifications/notification_service.dart';
import '../core/notifications/ai_notification_service.dart';
import '../features/notifications/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

// Alias para compatibilidad
final getIt = sl;

Future<void> init() async {
  // ==================== LOCAL STORAGE ====================
  // Inicializar Hive
  await HiveService.init();
  sl.registerLazySingleton<HiveService>(() => HiveService());

  // Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<PreferencesService>(() => PreferencesService(prefs));

  // Inicializar SyncService
  sl.registerLazySingleton<SyncService>(
    () => SyncService(sl<HiveService>(), sl<PreferencesService>()),
  );
  await sl<SyncService>().init();

  // ==================== SUPABASE ====================
  final supabaseClient = Supabase.instance.client;
  sl.registerSingleton<SupabaseClient>(supabaseClient);

  // ==================== DATA SOURCES ====================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      supabaseClient: sl<SupabaseClient>(),
    ),
  );

  sl.registerLazySingleton<HabitsRemoteDataSource>(
    () => HabitsRemoteDataSourceImpl(
      supabaseClient: sl<SupabaseClient>(),
    ),
  );

  sl.registerLazySingleton<RankingRemoteDataSource>(
    () => RankingRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  // AI Coach - Gemini AI
  final geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final geminiModel = GenerativeModel(
    model: 'gemini-flash-latest',
    apiKey: geminiApiKey,
  );
  sl.registerSingleton<GenerativeModel>(geminiModel);

  sl.registerLazySingleton<AiCoachRemoteDataSource>(
    () => AiCoachRemoteDataSourceImpl(model: sl<GenerativeModel>()),
  );

  // Notifications
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<AiNotificationService>(
    () => AiNotificationService(model: sl<GenerativeModel>()),
  );

  // ==================== REPOSITORIES ====================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl<HomeRemoteDataSource>()),
  );

  sl.registerLazySingleton<HabitsRepository>(
    () => HabitsRepositoryImpl(remoteDataSource: sl<HabitsRemoteDataSource>()),
  );

  sl.registerLazySingleton<RankingRepository>(
    () => RankingRepositoryImpl(sl<RankingRemoteDataSource>()),
  );

  sl.registerLazySingleton<AiCoachRepository>(
    () => AiCoachRepositoryImpl(remoteDataSource: sl<AiCoachRemoteDataSource>()),
  );

  // ==================== USE CASES ====================
  // Onboarding
  sl.registerLazySingleton(() => GetOnboardingItemsUseCase());

  // Authentication
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => IsUserAuthenticatedUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

  // Home
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => GetDashboardDataUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => home_logout.LogoutUseCase(sl<HomeRepository>()));

  // MicroHabits
  sl.registerLazySingleton(() => GetUserHabitsUseCase(sl<HabitsRepository>()));
  sl.registerLazySingleton(() => CreateHabitUseCase(sl<HabitsRepository>()));
  sl.registerLazySingleton(() => CompleteHabitUseCase(sl<HabitsRepository>()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl<HabitsRepository>()));

  // Ranking
  sl.registerLazySingleton(() => GetWeeklyRankingUseCase(sl<RankingRepository>()));

  // AI Coach
  sl.registerLazySingleton(() => SendMessageUseCase(sl<AiCoachRepository>()));
  sl.registerLazySingleton(() => AnalyzeProgressUseCase(sl<AiCoachRepository>()));
  sl.registerLazySingleton(() => GetSuggestionsUseCase(sl<AiCoachRepository>()));

  // ==================== BLOCS ====================
  sl.registerFactory(() => OnboardingBloc(
    getOnboardingItemsUseCase: sl(),
  ));

  sl.registerFactory(() => LoginBloc(
    loginWithEmailUseCase: sl(),
    loginWithGoogleUseCase: sl(),
    signUpUseCase: sl(),
  ));

  sl.registerLazySingleton(() => AuthBloc(
    getCurrentUserUseCase: sl(),
    isUserAuthenticatedUseCase: sl(),
    logoutUseCase: sl(),
  ));

  sl.registerFactory(() => HomeBloc(
    getDashboardDataUseCase: sl(),
    getUserProfileUseCase: sl(),
    logoutUseCase: sl<home_logout.LogoutUseCase>(),
  ));

  sl.registerFactory(() => HabitsBloc(
    getUserHabitsUseCase: sl(),
    createHabitUseCase: sl(),
    completeHabitUseCase: sl(),
    getCategoriesUseCase: sl(),
    habitsRepository: sl(),
  ));

  sl.registerFactory(() => RankingBloc(
    getWeeklyRankingUseCase: sl(),
  ));

  sl.registerFactory(() => AiCoachBloc(
    sendMessageUseCase: sl(),
    analyzeProgressUseCase: sl(),
    getSuggestionsUseCase: sl(),
    homeRepository: sl(),
    habitsRepository: sl(),
    rankingRepository: sl(),
  ));

  sl.registerFactory(() => NotificationBloc(
    notificationService: sl(),
    aiNotificationService: sl(),
    homeRepository: sl(),
  ));
}
