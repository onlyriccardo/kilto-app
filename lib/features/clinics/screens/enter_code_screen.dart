import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/widgets/kilto_text.dart';

/// Manual entry of a clinic invite code (paste fallback for when the QR
/// scanner isn't usable or the user received a code via email/chat).
class EnterCodeScreen extends ConsumerStatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  ConsumerState<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends ConsumerState<EnterCodeScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Strip the visual em-dash / spaces / hyphens — backend wants pure code.
    final raw = _controller.text.trim().toUpperCase();
    final code = raw.replaceAll(RegExp(r'[\s\u2014\-]+'), '');
    if (code.isEmpty) return;

    setState(() => _submitting = true);

    try {
      final m = await ref.read(accountAuthServiceProvider).joinClinic(code);
      if (!mounted) return;
      // Tell MyClinics to re-fetch its list before we land on it.
      ref.read(clinicsListVersionProvider.notifier).state++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Te uniste a ${m.tenantName}!')),
      );
      context.go('/clinics');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_humanize(e)),
            backgroundColor: KiltoColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KiltoRadii.small),
            ),
          ),
        );
        setState(() => _submitting = false);
      }
    }
  }

  String _humanize(Object e) {
    final s = e.toString();
    if (s.contains('not_found')) return 'Código no válido.';
    if (s.contains('revoked')) return 'Código revocado por la clínica.';
    if (s.contains('expired')) return 'Código expirado.';
    if (s.contains('exhausted')) return 'Código ya usado al máximo.';
    if (s.contains('email_pattern')) {
      return 'Tu correo no cumple con el patrón requerido.';
    }
    return 'No se pudo unir. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
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
              const SizedBox(height: 20),
              KiltoText.h1('Ingresa tu código'),
              const SizedBox(height: 8),
              KiltoText.body(
                'Pídele el código a tu clínica si aún no lo tienes. Tiene 8 dígitos.',
                color: KiltoColors.zinc500,
              ),
              const SizedBox(height: 28),
              KiltoText.eyebrow('Código'),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 9, // 8 digits + the auto-inserted em-dash
                inputFormatters: [_InstallCodeFormatter()],
                style: const TextStyle(
                  fontFamily: KiltoFonts.familyHeading,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color: KiltoColors.zinc950,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '1234—5678',
                  counterText: '',
                  hintStyle: const TextStyle(
                    fontFamily: KiltoFonts.familyHeading,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 6,
                    color: KiltoColors.zinc300,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: KiltoColors.onBrand,
                          ),
                        )
                      : const Text('Unirme'),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    context.pushReplacement('/clinics/scan'),
                child: const Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: KiltoFonts.familyBody,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: KiltoColors.zinc500,
                    ),
                    children: [
                      TextSpan(text: '¿Tienes el QR? '),
                      TextSpan(
                        text: 'Escanéalo',
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Auto-formats input as `1234—5678` while only ever holding 8 digits in the
/// underlying buffer. Patient install codes use only digits 2-9 (no 0/1) but
/// we accept all digits here and let the backend validate the alphabet —
/// rejecting 0/1 client-side would be confusing if the format ever evolves.
class _InstallCodeFormatter extends TextInputFormatter {
  static const _separator = '—';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only digits.
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clamped = digits.length > 8 ? digits.substring(0, 8) : digits;

    String formatted;
    if (clamped.length <= 4) {
      formatted = clamped;
    } else {
      formatted = '${clamped.substring(0, 4)}$_separator${clamped.substring(4)}';
    }

    // Place caret at end — simplest correct behaviour for an 8-char input.
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
