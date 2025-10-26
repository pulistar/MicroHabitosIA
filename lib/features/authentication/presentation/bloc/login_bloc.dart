import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../../../core/usecases/usecase.dart';

// ==================== EVENTOS ====================
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithEmailEvent extends LoginEvent {
  final String email;
  final String password;

  const LoginWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LoginWithGoogleEvent extends LoginEvent {
  const LoginWithGoogleEvent();
}

class SignUpEvent extends LoginEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpEvent({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

// ==================== ESTADOS ====================
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserEntity user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginError extends LoginState {
  final String message;

  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}

class SignUpSuccess extends LoginState {
  final UserEntity user;

  const SignUpSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// ==================== BLOC ====================
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final SignUpUseCase signUpUseCase;

  LoginBloc({
    required this.loginWithEmailUseCase,
    required this.loginWithGoogleUseCase,
    required this.signUpUseCase,
  }) : super(const LoginInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<SignUpEvent>(_onSignUp);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await loginWithEmailUseCase(
      LoginWithEmailParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await loginWithGoogleUseCase(NoParams());

    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );

    result.fold(
      (failure) => emit(LoginError(failure.message)),
      // Emitir LoginSuccess en lugar de SignUpSuccess para navegar a Home
      (user) => emit(LoginSuccess(user)),
    );
  }
}
