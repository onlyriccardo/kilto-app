import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../config/demo_mode.dart';
import '../../../config/demo_data.dart';
import '../../../core/api/v1/models.dart';
import '../../../core/api/v1/v1_providers.dart';

enum ToothStatus { healthy, treated, attention, extracted }

class ToothData {
  final int fdiNumber;
  final String name;
  final ToothStatus status;
  final List<String> history;

  const ToothData({
    required this.fdiNumber,
    required this.name,
    required this.status,
    this.history = const [],
  });
}

/// Odontogram tab inside Documents.
///
/// Demo mode keeps the legacy hardcoded DemoData path. Real mode pulls
/// `GET /v1/modules/dental/odontogram` and folds `surface_states` +
/// `treatments` into one `ToothData` per FDI, so the custom tooth painter
/// doesn't need to change.
class OdontogramScreen extends ConsumerWidget {
  const OdontogramScreen({super.key});

  static const _statusColors = {
    ToothStatus.healthy: KiltoColors.white,
    ToothStatus.treated: KiltoColors.blue,
    ToothStatus.attention: KiltoColors.yellow,
    ToothStatus.extracted: KiltoColors.greyText,
  };

  static const _statusLabels = {
    ToothStatus.healthy: 'Sano',
    ToothStatus.treated: 'Tratado',
    ToothStatus.attention: 'Atención',
    ToothStatus.extracted: 'Extraído',
  };

  // FDI numbering order for each arch — right quadrant first, then left.
  static const _upperFdi = [18, 17, 16, 15, 14, 13, 12, 11, 21, 22, 23, 24, 25, 26, 27, 28];
  static const _lowerFdi = [48, 47, 46, 45, 44, 43, 42, 41, 31, 32, 33, 34, 35, 36, 37, 38];

  // Full FDI → display name dictionary.
  static const _toothNames = <int, String>{
    18: 'Tercer molar superior derecho',
    17: 'Segundo molar superior derecho',
    16: 'Primer molar superior derecho',
    15: 'Segundo premolar superior derecho',
    14: 'Primer premolar superior derecho',
    13: 'Canino superior derecho',
    12: 'Incisivo lateral superior derecho',
    11: 'Incisivo central superior derecho',
    21: 'Incisivo central superior izquierdo',
    22: 'Incisivo lateral superior izquierdo',
    23: 'Canino superior izquierdo',
    24: 'Primer premolar superior izquierdo',
    25: 'Segundo premolar superior izquierdo',
    26: 'Primer molar superior izquierdo',
    27: 'Segundo molar superior izquierdo',
    28: 'Tercer molar superior izquierdo',
    48: 'Tercer molar inferior derecho',
    47: 'Segundo molar inferior derecho',
    46: 'Primer molar inferior derecho',
    45: 'Segundo premolar inferior derecho',
    44: 'Primer premolar inferior derecho',
    43: 'Canino inferior derecho',
    42: 'Incisivo lateral inferior derecho',
    41: 'Incisivo central inferior derecho',
    31: 'Incisivo central inferior izquierdo',
    32: 'Incisivo lateral inferior izquierdo',
    33: 'Canino inferior izquierdo',
    34: 'Primer premolar inferior izquierdo',
    35: 'Segundo premolar inferior izquierdo',
    36: 'Primer molar inferior izquierdo',
    37: 'Segundo molar inferior izquierdo',
    38: 'Tercer molar inferior izquierdo',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDemoMode) {
      return _buildBody(
        context,
        upper: _demoTeeth(_upperFdi),
        lower: _demoTeeth(_lowerFdi),
        note:
            'Vista demo. Los datos provienen de ejemplos locales.',
        onRetry: null,
      );
    }

    final async = ref.watch(odontogramProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildError(e.toString(),
          onRetry: () => ref.invalidate(odontogramProvider)),
      data: (record) {
        final upper = _realTeeth(_upperFdi, record);
        final lower = _realTeeth(_lowerFdi, record);
        final note = record.isEmpty
            ? 'Tu clínica aún no ha registrado datos del odontograma.'
            : 'Odontograma actualizado por tu profesional.';
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(odontogramProvider),
          child: _buildBody(
            context,
            upper: upper,
            lower: lower,
            note: note,
            onRetry: () => ref.invalidate(odontogramProvider),
          ),
        );
      },
    );
  }

  // =====================================================================
  // Data builders
  // =====================================================================
  List<ToothData> _realTeeth(List<int> fdis, OdontogramRecord record) {
    return fdis.map((fdi) {
      final key = fdi.toString();
      final txs = record.treatments[key] ?? const <DentalTreatmentRecord>[];
      final surfaces = record.surfaceStates[key] ?? const <String, String>{};
      final status = _deriveStatus(txs, surfaces);
      return ToothData(
        fdiNumber: fdi,
        name: _toothNames[fdi] ?? 'Pieza $fdi',
        status: status,
        history: txs.map((t) => t.summary()).toList(),
      );
    }).toList();
  }

  ToothStatus _deriveStatus(
    List<DentalTreatmentRecord> txs,
    Map<String, String> surfaces,
  ) {
    // 1. Extraction = hard signal.
    for (final t in txs) {
      final code = (t.treatmentCode ?? '').toLowerCase();
      if (code.contains('extract')) return ToothStatus.extracted;
    }
    // 2. Unresolved caries / fracture / other issue surface state = attention.
    for (final state in surfaces.values) {
      final s = state.toLowerCase();
      if (s.isEmpty) continue;
      if (s.contains('caries') ||
          s.contains('fractur') ||
          s.contains('lesion') ||
          s.contains('atencion') ||
          s == 'issue') {
        return ToothStatus.attention;
      }
    }
    // 3. Treatment history present = treated (amalgam, resin, endo, crown, ...).
    if (txs.any((t) => t.isResolved || (t.treatmentCode ?? '').isNotEmpty)) {
      return ToothStatus.treated;
    }
    // 4. Default.
    return ToothStatus.healthy;
  }

  List<ToothData> _demoTeeth(List<int> fdis) {
    const statusMap = {
      'healthy': ToothStatus.healthy,
      'treated': ToothStatus.treated,
      'attention': ToothStatus.attention,
      'extracted': ToothStatus.extracted,
    };
    return fdis.map((fdi) {
      final data = DemoData.toothData[fdi];
      if (data == null) {
        return ToothData(
          fdiNumber: fdi,
          name: _toothNames[fdi] ?? 'Pieza $fdi',
          status: ToothStatus.healthy,
        );
      }
      final treatments = data['treatments'] as List<dynamic>? ?? [];
      return ToothData(
        fdiNumber: fdi,
        name: (data['name'] as String?) ?? _toothNames[fdi] ?? 'Pieza $fdi',
        status: statusMap[data['status']] ?? ToothStatus.healthy,
        history: treatments
            .map((t) => '${(t as Map)['desc']} - ${t['date']}')
            .toList(),
      );
    }).toList();
  }

  // =====================================================================
  // UI
  // =====================================================================
  Widget _buildBody(
    BuildContext context, {
    required List<ToothData> upper,
    required List<ToothData> lower,
    required String note,
    required VoidCallback? onRetry,
  }) {
    final allTeeth = [...upper, ...lower];
    final healthy = allTeeth.where((t) => t.status == ToothStatus.healthy).length;
    final treated = allTeeth.where((t) => t.status == ToothStatus.treated).length;
    final attention = allTeeth.where((t) => t.status == ToothStatus.attention).length;
    final extracted = allTeeth.where((t) => t.status == ToothStatus.extracted).length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: KiltoColors.tealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: KiltoColors.tealDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 12,
                      color: KiltoColors.navy.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 20),
          _buildArch(context, upper, title: 'Arcada Superior', isUpper: true),
          const SizedBox(height: 4),
          Center(
            child: Container(
              width: 60,
              height: 2,
              color: KiltoColors.greyMid,
            ),
          ),
          const SizedBox(height: 4),
          _buildArch(context, lower, title: 'Arcada Inferior', isUpper: false),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                    'Sano', healthy, KiltoColors.green, KiltoColors.greenLight),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                    'Tratado', treated, KiltoColors.blue, KiltoColors.blueLight),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard('Atención', attention,
                    KiltoColors.yellow, KiltoColors.yellowLight),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard('Extraído', extracted,
                    KiltoColors.greyText, KiltoColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildError(String msg, {required VoidCallback onRetry}) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: KiltoColors.greyText),
            const SizedBox(height: 12),
            const Text('No se pudo cargar el odontograma',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: KiltoColors.greyText)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );

  Widget _buildArch(
    BuildContext context,
    List<ToothData> teeth, {
    required String title,
    required bool isUpper,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KiltoColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          _buildToothRow(context, teeth, isUpper: isUpper),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _statusLabels.entries.map((entry) {
        final color = _statusColors[entry.key]!;
        final isWhite = entry.key == ToothStatus.healthy;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isWhite ? KiltoColors.greyMid : color,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              entry.value,
              style: const TextStyle(
                fontSize: 12,
                color: KiltoColors.navy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildToothRow(
    BuildContext context,
    List<ToothData> teeth, {
    bool isUpper = true,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...teeth.take(8).map((t) => _buildTooth(context, t, isUpper)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(width: 1, height: 40, color: KiltoColors.greyMid),
          ),
          ...teeth.skip(8).map((t) => _buildTooth(context, t, isUpper)),
        ],
      ),
    );
  }

  Widget _buildTooth(BuildContext context, ToothData tooth, bool isUpper) {
    final fill = _statusColors[tooth.status] ?? KiltoColors.white;
    final isExtracted = tooth.status == ToothStatus.extracted;
    final borderColor =
        tooth.status == ToothStatus.healthy ? KiltoColors.greyMid : fill;

    return GestureDetector(
      onTap: () => _showToothDetail(context, tooth),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Column(
          children: [
            if (isUpper)
              Text(
                '${tooth.fdiNumber}',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: KiltoColors.greyText,
                ),
              ),
            if (isUpper) const SizedBox(height: 2),
            Opacity(
              opacity: isExtracted ? 0.4 : 1.0,
              child: SizedBox(
                width: 20,
                height: 30,
                child: CustomPaint(
                  painter: _ToothPainter(
                    fillColor: fill,
                    borderColor: borderColor,
                    isUpper: isUpper,
                    isExtracted: isExtracted,
                  ),
                ),
              ),
            ),
            if (!isUpper) const SizedBox(height: 2),
            if (!isUpper)
              Text(
                '${tooth.fdiNumber}',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: KiltoColors.greyText,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, int count, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showToothDetail(BuildContext context, ToothData tooth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final statusColor = _statusColors[tooth.status]!;
        final statusLabel = _statusLabels[tooth.status]!;
        final isHealthyColor = tooth.status == ToothStatus.healthy;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: KiltoColors.greyMid,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isHealthyColor
                          ? KiltoColors.greenLight
                          : statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${tooth.fdiNumber}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color:
                              isHealthyColor ? KiltoColors.green : statusColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tooth.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: KiltoColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isHealthyColor
                                ? KiltoColors.greenLight
                                : statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isHealthyColor
                                  ? KiltoColors.green
                                  : statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (tooth.history.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Historial de tratamientos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy,
                  ),
                ),
                const SizedBox(height: 10),
                ...tooth.history.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(Icons.circle,
                                size: 6, color: KiltoColors.teal),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry,
                              style: const TextStyle(
                                fontSize: 13,
                                color: KiltoColors.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ] else ...[
                const SizedBox(height: 20),
                const Text(
                  'Sin historial de tratamientos',
                  style: TextStyle(
                    fontSize: 13,
                    color: KiltoColors.greyText,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// CustomPainter that draws a tooth shape — crown + root.
/// Upper teeth: crown at top, root pointing down.
/// Lower teeth: root pointing up, crown at bottom.
class _ToothPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final bool isUpper;
  final bool isExtracted;

  _ToothPainter({
    required this.fillColor,
    required this.borderColor,
    required this.isUpper,
    required this.isExtracted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = fillColor;
    final stroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();

    if (isUpper) {
      path.moveTo(w * 0.15, h * 0.12);
      path.quadraticBezierTo(w * 0.15, 0, w * 0.5, 0);
      path.quadraticBezierTo(w * 0.85, 0, w * 0.85, h * 0.12);
      path.lineTo(w * 0.82, h * 0.45);
      path.quadraticBezierTo(w * 0.80, h * 0.55, w * 0.70, h * 0.55);
      path.lineTo(w * 0.62, h * 0.55);
      path.quadraticBezierTo(w * 0.55, h * 0.6, w * 0.5, h * 0.85);
      path.quadraticBezierTo(w * 0.45, h * 0.6, w * 0.38, h * 0.55);
      path.lineTo(w * 0.30, h * 0.55);
      path.quadraticBezierTo(w * 0.20, h * 0.55, w * 0.18, h * 0.45);
      path.lineTo(w * 0.15, h * 0.12);
      path.close();
    } else {
      path.moveTo(w * 0.38, h * 0.45);
      path.lineTo(w * 0.30, h * 0.45);
      path.quadraticBezierTo(w * 0.20, h * 0.45, w * 0.18, h * 0.55);
      path.lineTo(w * 0.15, h * 0.88);
      path.quadraticBezierTo(w * 0.15, h, w * 0.5, h);
      path.quadraticBezierTo(w * 0.85, h, w * 0.85, h * 0.88);
      path.lineTo(w * 0.82, h * 0.55);
      path.quadraticBezierTo(w * 0.80, h * 0.45, w * 0.70, h * 0.45);
      path.lineTo(w * 0.62, h * 0.45);
      path.quadraticBezierTo(w * 0.55, h * 0.4, w * 0.5, h * 0.15);
      path.quadraticBezierTo(w * 0.45, h * 0.4, w * 0.38, h * 0.45);
      path.close();
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);

    if (isExtracted) {
      final xPaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(w * 0.2, h * 0.15), Offset(w * 0.8, h * 0.85), xPaint);
      canvas.drawLine(Offset(w * 0.8, h * 0.15), Offset(w * 0.2, h * 0.85), xPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ToothPainter oldDelegate) =>
      fillColor != oldDelegate.fillColor ||
      borderColor != oldDelegate.borderColor ||
      isUpper != oldDelegate.isUpper ||
      isExtracted != oldDelegate.isExtracted;
}
