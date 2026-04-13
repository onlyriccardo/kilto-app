import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../config/demo_mode.dart';
import '../../../config/demo_data.dart';

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

class OdontogramScreen extends StatelessWidget {
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

  static const _statusMap = {
    'healthy': ToothStatus.healthy,
    'treated': ToothStatus.treated,
    'attention': ToothStatus.attention,
    'extracted': ToothStatus.extracted,
  };

  static ToothData _fromDemoData(int fdi, Map<String, dynamic> data) {
    final treatments = data['treatments'] as List<dynamic>? ?? [];
    return ToothData(
      fdiNumber: fdi,
      name: data['name'] as String,
      status: _statusMap[data['status']] ?? ToothStatus.healthy,
      history: treatments.map((t) => '${(t as Map)['desc']} - ${t['date']}').toList(),
    );
  }

  // Upper arch FDI order: 18-11 then 21-28
  static const _upperFdi = [18, 17, 16, 15, 14, 13, 12, 11, 21, 22, 23, 24, 25, 26, 27, 28];
  // Lower arch FDI order: 48-41 then 31-38
  static const _lowerFdi = [48, 47, 46, 45, 44, 43, 42, 41, 31, 32, 33, 34, 35, 36, 37, 38];

  List<ToothData> get _upperTeeth => kDemoMode
      ? _upperFdi.map((fdi) {
          final data = DemoData.toothData[fdi];
          if (data != null) return _fromDemoData(fdi, data);
          return ToothData(fdiNumber: fdi, name: 'Tooth $fdi', status: ToothStatus.healthy);
        }).toList()
      : [
          const ToothData(fdiNumber: 18, name: 'Tercer molar superior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 17, name: 'Segundo molar superior derecho', status: ToothStatus.treated, history: ['Amalgama - 15/01/2025']),
          const ToothData(fdiNumber: 16, name: 'Primer molar superior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 15, name: 'Segundo premolar superior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 14, name: 'Primer premolar superior derecho', status: ToothStatus.attention, history: ['Caries detectada - 28/03/2026']),
          const ToothData(fdiNumber: 13, name: 'Canino superior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 12, name: 'Incisivo lateral superior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 11, name: 'Incisivo central superior derecho', status: ToothStatus.treated, history: ['Resina compuesta - 10/06/2024']),
          const ToothData(fdiNumber: 21, name: 'Incisivo central superior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 22, name: 'Incisivo lateral superior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 23, name: 'Canino superior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 24, name: 'Primer premolar superior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 25, name: 'Segundo premolar superior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 26, name: 'Primer molar superior izquierdo', status: ToothStatus.treated, history: ['Endodoncia - 05/09/2024', 'Corona - 20/09/2024']),
          const ToothData(fdiNumber: 27, name: 'Segundo molar superior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 28, name: 'Tercer molar superior izquierdo', status: ToothStatus.extracted, history: ['Extracción - 12/03/2025']),
        ];

  List<ToothData> get _lowerTeeth => kDemoMode
      ? _lowerFdi.map((fdi) {
          final data = DemoData.toothData[fdi];
          if (data != null) return _fromDemoData(fdi, data);
          return ToothData(fdiNumber: fdi, name: 'Tooth $fdi', status: ToothStatus.healthy);
        }).toList()
      : [
          const ToothData(fdiNumber: 48, name: 'Tercer molar inferior derecho', status: ToothStatus.extracted, history: ['Extracción - 12/03/2025']),
          const ToothData(fdiNumber: 47, name: 'Segundo molar inferior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 46, name: 'Primer molar inferior derecho', status: ToothStatus.attention, history: ['Caries profunda - 28/03/2026']),
          const ToothData(fdiNumber: 45, name: 'Segundo premolar inferior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 44, name: 'Primer premolar inferior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 43, name: 'Canino inferior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 42, name: 'Incisivo lateral inferior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 41, name: 'Incisivo central inferior derecho', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 31, name: 'Incisivo central inferior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 32, name: 'Incisivo lateral inferior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 33, name: 'Canino inferior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 34, name: 'Primer premolar inferior izquierdo', status: ToothStatus.treated, history: ['Resina - 15/01/2025']),
          const ToothData(fdiNumber: 35, name: 'Segundo premolar inferior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 36, name: 'Primer molar inferior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 37, name: 'Segundo molar inferior izquierdo', status: ToothStatus.healthy),
          const ToothData(fdiNumber: 38, name: 'Tercer molar inferior izquierdo', status: ToothStatus.healthy),
        ];

  @override
  Widget build(BuildContext context) {
    final allTeeth = [..._upperTeeth, ..._lowerTeeth];
    final healthyCount = allTeeth.where((t) => t.status == ToothStatus.healthy).length;
    final treatedCount = allTeeth.where((t) => t.status == ToothStatus.treated).length;
    final attentionCount = allTeeth.where((t) => t.status == ToothStatus.attention).length;
    final extractedCount = allTeeth.where((t) => t.status == ToothStatus.extracted).length;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coming soon note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: KiltoColors.tealLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: KiltoColors.tealDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vista de solo lectura. Vista interactiva disponible próximamente.',
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

            // Legend
            _buildLegend(),
            const SizedBox(height: 20),

            // Upper arch
            Container(
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
                  const Text(
                    'Arcada Superior',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildToothRow(context, _upperTeeth, isUpper: true),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Divider
            Center(
              child: Container(
                width: 60,
                height: 2,
                color: KiltoColors.greyMid,
              ),
            ),
            const SizedBox(height: 4),

            // Lower arch
            Container(
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
                  const Text(
                    'Arcada Inferior',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildToothRow(context, _lowerTeeth, isUpper: false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary cards
            Row(
              children: [
                Expanded(
                    child: _buildSummaryCard(
                        'Sano', healthyCount, KiltoColors.green, KiltoColors.greenLight)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildSummaryCard(
                        'Tratado', treatedCount, KiltoColors.blue, KiltoColors.blueLight)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildSummaryCard(
                        'Atención', attentionCount, KiltoColors.yellow, KiltoColors.yellowLight)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildSummaryCard(
                        'Extraído', extractedCount, KiltoColors.greyText, KiltoColors.grey)),
              ],
            ),
            const SizedBox(height: 24),
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

  Widget _buildToothRow(BuildContext context, List<ToothData> teeth, {bool isUpper = true}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First 8 teeth (right quadrant)
          ...teeth.take(8).map((tooth) => _buildTooth(context, tooth, isUpper)),
          // Midline separator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(width: 1, height: 40, color: KiltoColors.greyMid),
          ),
          // Last 8 teeth (left quadrant)
          ...teeth.skip(8).map((tooth) => _buildTooth(context, tooth, isUpper)),
        ],
      ),
    );
  }

  Widget _buildTooth(BuildContext context, ToothData tooth, bool isUpper) {
    final fill = _statusColors[tooth.status] ?? KiltoColors.white;
    final isExtracted = tooth.status == ToothStatus.extracted;
    final borderColor = tooth.status == ToothStatus.healthy ? KiltoColors.greyMid : fill;

    return GestureDetector(
      onTap: () => _showToothDetail(context, tooth),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Column(
          children: [
            if (isUpper) Text(
              '${tooth.fdiNumber}',
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: KiltoColors.greyText),
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
            if (!isUpper) Text(
              '${tooth.fdiNumber}',
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: KiltoColors.greyText),
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
              // Handle
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
              // Tooth number and status
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
                          color: isHealthyColor ? KiltoColors.green : statusColor,
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
                        children: [
                          const Icon(Icons.circle, size: 6, color: KiltoColors.teal),
                          const SizedBox(width: 10),
                          Text(
                            entry,
                            style: const TextStyle(
                              fontSize: 13,
                              color: KiltoColors.navy,
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

/// CustomPainter that draws a tooth shape — crown + root
/// Upper teeth: crown at top, root pointing down
/// Lower teeth: root pointing up, crown at bottom
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
      // Upper tooth: wide crown at top, narrow root at bottom
      // Crown
      path.moveTo(w * 0.15, h * 0.12);
      path.quadraticBezierTo(w * 0.15, 0, w * 0.5, 0);
      path.quadraticBezierTo(w * 0.85, 0, w * 0.85, h * 0.12);
      // Right side down to root
      path.lineTo(w * 0.82, h * 0.45);
      path.quadraticBezierTo(w * 0.80, h * 0.55, w * 0.70, h * 0.55);
      // Root
      path.lineTo(w * 0.62, h * 0.55);
      path.quadraticBezierTo(w * 0.55, h * 0.6, w * 0.5, h * 0.85);
      path.quadraticBezierTo(w * 0.45, h * 0.6, w * 0.38, h * 0.55);
      path.lineTo(w * 0.30, h * 0.55);
      path.quadraticBezierTo(w * 0.20, h * 0.55, w * 0.18, h * 0.45);
      path.lineTo(w * 0.15, h * 0.12);
      path.close();
    } else {
      // Lower tooth: narrow root at top, wide crown at bottom
      // Root
      path.moveTo(w * 0.38, h * 0.45);
      path.lineTo(w * 0.30, h * 0.45);
      path.quadraticBezierTo(w * 0.20, h * 0.45, w * 0.18, h * 0.55);
      // Crown
      path.lineTo(w * 0.15, h * 0.88);
      path.quadraticBezierTo(w * 0.15, h, w * 0.5, h);
      path.quadraticBezierTo(w * 0.85, h, w * 0.85, h * 0.88);
      path.lineTo(w * 0.82, h * 0.55);
      path.quadraticBezierTo(w * 0.80, h * 0.45, w * 0.70, h * 0.45);
      // Root
      path.lineTo(w * 0.62, h * 0.45);
      path.quadraticBezierTo(w * 0.55, h * 0.4, w * 0.5, h * 0.15);
      path.quadraticBezierTo(w * 0.45, h * 0.4, w * 0.38, h * 0.45);
      path.close();
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, stroke);

    // X mark for extracted teeth
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
