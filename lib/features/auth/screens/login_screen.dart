import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../config/feature_flags.dart';
import '../../../config/theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/storage/secure_storage.dart';

/// Legacy providers kept for the pre-Kilto-central-auth flow.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(storage: SecureStorageService()),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    api: ref.read(apiClientProvider),
    storage: SecureStorageService(),
  ),
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _tenantController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _tenantController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(WidgetRef ref) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kCentralAuth) {
        await ref
            .read(accountProvider.notifier)
            .login(email: email, password: password);
        if (!mounted) return;
        context.go('/clinics');
      } else {
        final tenant = _tenantController.text.trim();
        if (tenant.isEmpty) {
          _showError('Indica el slug de tu clínica');
          return;
        }

        final authService = ref.read(authServiceProvider);
        final data = await authService.login(
          email: email,
          password: password,
          tenantSlug: tenant,
        );

        final user = data['user'] as Map<String, dynamic>;
        final tenantData = user['tenant'] as Map<String, dynamic>;
        final modules = (tenantData['active_modules'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        ref.read(authStateProvider.notifier).login(
              token: data['token'] as String,
              userType: user['type'] as String,
              userName: user['name'] as String,
              userEmail: user['email'] as String,
              tenantName: tenantData['name'] as String,
              tenantSlug: tenantData['slug'] as String,
              activeModules: modules,
            );
      }
    } catch (_) {
      _showError('Credenciales incorrectas. Intenta de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: KiltoColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KiltoRadii.small),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Scaffold(
          backgroundColor: KiltoColors.bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.vertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 64),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/brand/kilto-wordmark-light.svg',
                          height: 44,
                          semanticsLabel: 'Kilto',
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tu negocio, en un solo lugar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: KiltoColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    if (!kCentralAuth) ...[
                      const _FieldLabel('Clínica'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _tenantController,
                        hintText: 'slug de tu clínica',
                        prefixIcon: Icons.business_rounded,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _FieldLabel('Correo'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'correo@ejemplo.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Contraseña'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: KiltoColors.textTertiary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(
                              () => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _login(ref),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: KiltoColors.onBrand,
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    if (kCentralAuth) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: const Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: KiltoColors.textSecondary,
                            ),
                            children: [
                              TextSpan(text: '¿No tienes cuenta? '),
                              TextSpan(
                                text: 'Crear cuenta',
                                style: TextStyle(
                                  color: KiltoColors.brandPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                    const Text(
                      'Powered by Kilto · v1.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: KiltoColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: KiltoColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: KiltoColors.textTertiary, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: KiltoColors.textSecondary,
      ),
    );
  }
}
