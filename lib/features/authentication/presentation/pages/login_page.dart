import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../injection/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSignUp = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext blocContext) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validar email
    _emailError = Validators.validateEmail(email);

    // Validar contraseña
    _passwordError = Validators.validatePassword(password);

    // Validar confirmación de contraseña en signup
    if (_isSignUp) {
      _confirmPasswordError = Validators.validatePasswordMatch(password, confirmPassword);
    }

    setState(() {});

    // Si hay errores, no continuar
    if (_emailError != null || _passwordError != null || _confirmPasswordError != null) {
      return;
    }

    if (_isSignUp) {
      blocContext.read<LoginBloc>().add(
            SignUpEvent(
              email: email,
              password: password,
            ),
          );
    } else {
      blocContext.read<LoginBloc>().add(
            LoginWithEmailEvent(
              email: email,
              password: password,
            ),
          );
    }
  }

  void _handleGoogleLogin(BuildContext blocContext) {
    blocContext.read<LoginBloc>().add(const LoginWithGoogleEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LoginBloc>(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
            stops: AppColors.primaryGradientStops,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    // Navegar automáticamente cuando se autentica
                    Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
                  }
                },
              ),
              BlocListener<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginSuccess) {
                    // Notificar al AuthBloc que verifique el estado
                    context.read<AuthBloc>().add(const AuthCheckRequested());
                  } else if (state is LoginError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 4),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(AppConstants.spacing16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                  }
                },
              ),
            ],
            child: BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                final isLoading = state is LoginLoading;

                return SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing24,
                        vertical: AppConstants.spacing30,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: AppConstants.spacing48),
                          // Título
                          Text(
                            _isSignUp ? 'Crear Cuenta' : 'Iniciar Sesión',
                            style: AppTypography.headlineLarge.copyWith(
                              fontSize: AppConstants.fontSizeHuge,
                            ),
                          ),
                          SizedBox(height: AppConstants.spacing12),
                          // Subtítulo
                          Text(
                            _isSignUp
                                ? 'Únete a MicroHabits AI'
                                : 'Bienvenido de vuelta',
                            style: AppTypography.bodyLarge,
                          ),
                          SizedBox(height: AppConstants.spacing40),
                          // Email input
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'tu@email.com',
                            icon: Icons.email_outlined,
                            enabled: !isLoading,
                            errorText: _emailError,
                            onChanged: (_) {
                              setState(() {
                                _emailError = null;
                              });
                            },
                          ),
                          SizedBox(height: AppConstants.spacing20),
                          // Password input
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            hint: '••••••••',
                            icon: Icons.lock_outlined,
                            isPassword: true,
                            enabled: !isLoading,
                            errorText: _passwordError,
                            onPasswordVisibilityToggle: () {
                              setState(() => _isPasswordVisible = !_isPasswordVisible);
                            },
                            isPasswordVisible: _isPasswordVisible,
                            onChanged: (_) {
                              setState(() {
                                _passwordError = null;
                              });
                            },
                          ),
                          // Confirmar contraseña (solo en signup)
                          if (_isSignUp) ...[
                            SizedBox(height: AppConstants.spacing20),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmar Contraseña',
                              hint: '••••••••',
                              icon: Icons.lock_outlined,
                              isPassword: true,
                              enabled: !isLoading,
                              errorText: _confirmPasswordError,
                              onPasswordVisibilityToggle: () {
                                setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                              },
                              isPasswordVisible: _isConfirmPasswordVisible,
                              onChanged: (_) {
                                setState(() {
                                  _confirmPasswordError = null;
                                });
                              },
                            ),
                          ],
                          SizedBox(height: AppConstants.spacing30),
                          // Botón principal
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () => _handleLogin(context),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _isSignUp ? 'Registrarse' : 'Iniciar Sesión',
                                    ),
                            ),
                          ),
                          SizedBox(height: AppConstants.spacing20),
                          // Divisor
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.white30,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacing12,
                                ),
                                child: Text(
                                  'O',
                                  style: AppTypography.bodySmall,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.white30,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.spacing20),
                          // Botón Google
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : () => _handleGoogleLogin(context),
                              icon: const Icon(Icons.g_mobiledata),
                              label: const Text('Continuar con Google'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.white,
                                side: const BorderSide(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: AppConstants.spacing16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppConstants.spacing30),
                          // Toggle Sign Up / Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isSignUp
                                    ? '¿Ya tienes cuenta? '
                                    : '¿No tienes cuenta? ',
                                style: AppTypography.bodyMedium,
                              ),
                              GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        setState(() => _isSignUp = !_isSignUp);
                                        _emailController.clear();
                                        _passwordController.clear();
                                      },
                                child: Text(
                                  _isSignUp ? 'Inicia sesión' : 'Regístrate',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.accentPink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
    VoidCallback? onPasswordVisibilityToggle,
    bool isPasswordVisible = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        SizedBox(height: AppConstants.spacing8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: isPassword && !isPasswordVisible,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: onPasswordVisibilityToggle,
                  )
                : null,
            errorText: errorText,
            errorBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  )
                : null,
            focusedErrorBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
