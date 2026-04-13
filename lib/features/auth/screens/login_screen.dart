import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/storage/secure_storage.dart';

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
    final tenant = _tenantController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (tenant.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
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
    } catch (e) {
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
        backgroundColor: KiltoColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    // Tooth logo placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: KiltoColors.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        size: 44,
                        color: KiltoColors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'kilto',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: KiltoColors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tu negocio, en un solo lugar',
                      style: TextStyle(
                        fontSize: 13,
                        color: KiltoColors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tenant slug field
                    _buildTextField(
                      controller: _tenantController,
                      hintText: 'Nombre de tu clínica (slug)',
                      prefixIcon: Icons.business_rounded,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 14),

                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Correo electrónico',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: KiltoColors.greyText,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(
                              () => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _login(ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KiltoColors.teal,
                          foregroundColor: KiltoColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor:
                              KiltoColors.teal.withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: KiltoColors.white,
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Google sign-in button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: null, // Disabled — coming soon
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('Continuar con Google'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: KiltoColors.white.withOpacity(0.4),
                          side: BorderSide(
                            color: KiltoColors.white.withOpacity(0.15),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledForegroundColor:
                              KiltoColors.white.withOpacity(0.35),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coming soon...',
                      style: TextStyle(
                        fontSize: 11,
                        color: KiltoColors.white.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Create account link
                    TextButton(
                      onPressed: () {
                        // Registration not wired yet
                        _showError(
                            'Registro no disponible aún. Contacta a tu clínica.');
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: KiltoColors.white.withOpacity(0.6),
                          ),
                          children: const [
                            TextSpan(text: '¿No tienes cuenta? '),
                            TextSpan(
                              text: 'Crear cuenta',
                              style: TextStyle(
                                color: KiltoColors.teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Footer
                    Text(
                      'Powered by kilto · v1.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: KiltoColors.white.withOpacity(0.25),
                      ),
                    ),
                    const SizedBox(height: 24),
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
      style: const TextStyle(color: KiltoColors.navy, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: KiltoColors.greyText, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: KiltoColors.greyText, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: KiltoColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KiltoColors.teal, width: 2),
        ),
      ),
    );
  }
}
