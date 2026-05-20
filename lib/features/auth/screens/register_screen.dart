import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/kilto_wordmark.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/widgets/kilto_text.dart';

/// Create a Kilto root account. No tenant context here — clinics are joined
/// separately from MyClinics via QR / code.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.length < 8) {
      _showError('Correo y contraseña (mín. 8) son obligatorios.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(accountProvider.notifier).register(
            email: email,
            password: password,
            name: _name.text.trim(),
            phone: _phone.text.trim(),
          );
      if (!mounted) return;
      context.go('/clinics');
    } catch (_) {
      _showError('No se pudo registrar. ¿El correo ya existe?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
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
    return Scaffold(
      backgroundColor: KiltoColors.surface,
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/login'),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: KiltoColors.zinc900),
                    style: IconButton.styleFrom(
                      backgroundColor: KiltoColors.zinc100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: KiltoWordmark(iconSize: 28),
                ),
                const SizedBox(height: 28),
                KiltoText.h1('Crea tu cuenta'),
                const SizedBox(height: 8),
                KiltoText.body(
                  'Una cuenta para todas tus clínicas. Únete con QR o código.',
                  color: KiltoColors.zinc500,
                ),
                const SizedBox(height: 28),
                _field(
                  label: 'Nombre',
                  controller: _name,
                  hint: 'Tu nombre',
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                _field(
                  label: 'Correo',
                  controller: _email,
                  hint: 'correo@ejemplo.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _field(
                  label: 'Contraseña',
                  controller: _password,
                  hint: 'mínimo 8 caracteres',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: KiltoColors.zinc400,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 16),
                _field(
                  label: 'Teléfono (opcional)',
                  controller: _phone,
                  hint: '+591 7 123 4567',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: KiltoColors.onBrand,
                            ),
                          )
                        : const Text('Crear cuenta'),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontFamily: KiltoFonts.familyBody,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: KiltoColors.zinc500,
                      ),
                      children: [
                        TextSpan(text: '¿Ya tienes cuenta? '),
                        TextSpan(
                          text: 'Iniciar sesión',
                          style: TextStyle(
                            fontFamily: KiltoFonts.familyHeading,
                            color: KiltoColors.zinc950,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KiltoText.eyebrow(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          textCapitalization: textCapitalization,
          style: const TextStyle(
            color: KiltoColors.zinc950,
            fontFamily: KiltoFonts.familyBody,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: KiltoColors.zinc400, size: 18),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
