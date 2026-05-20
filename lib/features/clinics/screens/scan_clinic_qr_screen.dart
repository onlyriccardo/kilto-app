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
      ref.read(clinicsListVersionProvider.notifier).state++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Te uniste a ${membership.tenantName}!')),
      );
      context.go('/clinics');
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
      if (uri.pathSegments.first == 'j') {
        return uri.pathSegments.last;
      }
    }
    final bareRe = RegExp(r'^[A-Z0-9]{10,32}$', caseSensitive: false);
    if (bareRe.hasMatch(trimmed)) return trimmed.toUpperCase();
    return null;
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
      backgroundColor: KiltoColors.zinc950,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
          ),
          // Subtle vignette gradient so corner buttons stay legible.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  _GlassIconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 16),
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: const Text(
                      'ESCANEAR QR',
                      style: TextStyle(
                        fontFamily: KiltoFonts.familyHeading,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _GlassIconButton(
                    icon: ValueListenableBuilder<MobileScannerState>(
                      valueListenable: _controller,
                      builder: (_, state, __) {
                        return Icon(
                          state.torchState == TorchState.on
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: Colors.white,
                          size: 16,
                        );
                      },
                    ),
                    onTap: _controller.toggleTorch,
                  ),
                ],
              ),
            ),
          ),
          // Viewfinder corners
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(child: _ViewFinder()),
            ),
          ),
          if (_submitting)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          // Bottom CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Apunta al código QR',
                      style: TextStyle(
                        fontFamily: KiltoFonts.familyHeading,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tu clínica lo tiene impreso en la recepción',
                      style: TextStyle(
                        fontFamily: KiltoFonts.familyBody,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: () =>
                          context.pushReplacement('/clinics/enter-code'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(KiltoRadii.xsmall),
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                      ),
                      icon: const Icon(Icons.keyboard_rounded, size: 16),
                      label: const Text(
                        'Ingresar código en su lugar',
                        style: TextStyle(
                          fontFamily: KiltoFonts.familyHeading,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(
        side: BorderSide(color: Color(0x26FFFFFF), width: 1),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Center(child: icon)),
      ),
    );
  }
}

class _ViewFinder extends StatelessWidget {
  const _ViewFinder();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        children: [
          for (final corner in _Corner.values)
            Positioned(
              top: corner.top ? 0 : null,
              bottom: corner.top ? null : 0,
              left: corner.left ? 0 : null,
              right: corner.left ? null : 0,
              child: CustomPaint(
                size: const Size(34, 34),
                painter: _CornerPainter(corner: corner),
              ),
            ),
        ],
      ),
    );
  }
}

enum _Corner {
  topLeft(top: true, left: true),
  topRight(top: true, left: false),
  bottomLeft(top: false, left: true),
  bottomRight(top: false, left: false);

  const _Corner({required this.top, required this.left});
  final bool top;
  final bool left;
}

class _CornerPainter extends CustomPainter {
  final _Corner corner;
  _CornerPainter({required this.corner});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final r = 14.0;
    final w = size.width;
    final h = size.height;

    final path = Path();
    switch (corner) {
      case _Corner.topLeft:
        path.moveTo(0, h);
        path.lineTo(0, r);
        path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
        path.lineTo(w, 0);
        break;
      case _Corner.topRight:
        path.moveTo(0, 0);
        path.lineTo(w - r, 0);
        path.arcToPoint(Offset(w, r), radius: Radius.circular(r));
        path.lineTo(w, h);
        break;
      case _Corner.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, h - r);
        path.arcToPoint(Offset(r, h), radius: Radius.circular(r));
        path.lineTo(w, h);
        break;
      case _Corner.bottomRight:
        path.moveTo(0, h);
        path.lineTo(w - r, h);
        path.arcToPoint(Offset(w, h - r), radius: Radius.circular(r));
        path.lineTo(w, 0);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.corner != corner;
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
