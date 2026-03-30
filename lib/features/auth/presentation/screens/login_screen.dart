import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/constants/api_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController(
    text: ApiConstants.defaultBaseUrl,
  );
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        baseUrl: _serverController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 44,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Selamat Datang', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Login untuk melanjutkan ke TJI Scanner',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  // Username
                  AppTextField(
                    label: 'Username',
                    hint: 'admin',
                    controller: _usernameController,
                    prefixIcon: Icons.person_outline,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  AppTextField(
                    label: 'Password',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        label: 'Login',
                        isLoading: state is AuthLoading,
                        icon: Icons.login,
                        onPressed: _onLogin,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'TJI Warehouse Scanner v1.0.0',
                      style: AppTextStyles.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
