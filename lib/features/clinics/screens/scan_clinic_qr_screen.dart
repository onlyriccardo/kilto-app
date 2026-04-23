import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../config/theme.dart';
import '../../../core/auth/auth_providers.dart';

/// Scans a clinic invite QR. Accepts payloads in three forms:
///   * A bare code: `ABCD2345EFGH6789`
///   * A deep link: `kilto://join/ABCD2345EFGH6789`
///   * A universal link: `https://<domain>/j/ABCD2345EFGH6789`
class ScanClinicQrScreen extends ConsumerStatefulWidget {
  const ScanClinicQrScreen({super.key});

  @override
  ConsumerState<ScanClinicQrScreen> createState() =>
      _ScanClinicQrScreenState();
}

class _ScanClinicQrScreenState extends ConsumerState<ScanClinicQrScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_submitting) return;

    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    final code = _extractCode(raw);
    if (code == null) {
      _showError('QR no reconocido.');
      return;
    }

    setState(() => _submitting = true);

    try {
      final membership =
          await ref.read(accountAuthServiceProvider).joinClinic(code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Te uniste a ${membership.tenantName}!')),
      );
      context.pop();
    } catch (e) {
      _showError(_humanize(e));
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _extractCode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('kilto://join/')) {
      return trimmed.substring('kilto://join/'.length);
    }
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.host.isNotEmpty && uri.pathSegments.length >= 2) {
      // https://<domain>/j/<code>
      if (uri.pathSegments.first == 'j') {
        return uri.pathSegments.last;
      }
    }
    // Bare code — allow uppercase alphanumeric 10-32 chars.
    final bareRe = RegExp(r'^[A-Z0-9]{10,32}$', caseSensitive: false);
    if (bareRe.hasMatch(trimmed)) return trimmed.toUpperCase();
    return null;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: KiltoColors.error),
    );
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        // Transparent appbar over the camera feed — force white foreground so
        // the back chevron and flash toggle are readable against arbitrary
        // camera backgrounds.
        backgroundColor: Colors.black.withOpacity(0.35),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Escanear QR de clínica',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (_, state, __) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  color: Colors.white,
                );
              },
            ),
            onPressed: _controller.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(KiltoRadii.large),
                  ),
                ),
              ),
            ),
          ),
          if (_submitting)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: TextButton.icon(
                onPressed: () => context.pushReplacement('/clinics/enter-code'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.keyboard_rounded, size: 18),
                label: const Text('Ingresar código manualmente'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
