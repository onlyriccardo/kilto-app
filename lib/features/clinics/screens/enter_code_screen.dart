import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../core/auth/auth_providers.dart';

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
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _submitting = true);

    try {
      final m = await ref.read(accountAuthServiceProvider).joinClinic(code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Te uniste a ${m.tenantName}!')),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_humanize(e)), backgroundColor: KiltoColors.error),
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
      appBar: AppBar(title: const Text('Ingresar código')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ingresa el código que te dio tu clínica. Tiene 16 caracteres.',
                style: TextStyle(
                  fontSize: 14,
                  color: KiltoColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
                decoration: const InputDecoration(
                  hintText: 'ABCD2345EFGH6789',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: KiltoColors.onBrand),
                        )
                      : const Text('Unirme'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
