import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../config/demo_data.dart';
import 'clinic_chat_detail_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedTooth;

  Map<String, dynamic> get patient => widget.patient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = patient['status'] as String;
    String statusLabel;
    Color statusBg;
    Color statusFg;

    switch (status) {
      case 'active':
        statusLabel = 'Activo';
        statusBg = KiltoColors.greenLight;
        statusFg = KiltoColors.green;
        break;
      case 'inactive':
        statusLabel = 'Inactivo';
        statusBg = KiltoColors.grey;
        statusFg = KiltoColors.greyText;
        break;
      case 'overdue':
        statusLabel = 'Deuda';
        statusBg = KiltoColors.redLight;
        statusFg = KiltoColors.red;
        break;
      default:
        statusLabel = status;
        statusBg = KiltoColors.grey;
        statusFg = KiltoColors.greyText;
    }

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Paciente'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClinicChatDetailScreen(patient: patient),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: KiltoColors.white,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: KiltoColors.navy,
                  child: Text(
                    patient['initials'] as String,
                    style: const TextStyle(
                      color: KiltoColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  patient['name'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patient['phone'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: KiltoColors.greyText,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusFg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stat cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tratamientos',
                    '${patient['treatments']}',
                    KiltoColors.teal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Pr\u00f3xima cita',
                    patient['nextAppt'] as String,
                    KiltoColors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Balance',
                    patient['balance'] as String,
                    (patient['balance'] as String) != '0 Bs'
                        ? KiltoColors.red
                        : KiltoColors.green,
                  ),
                ),
              ],
            ),
          ),
          // Tab bar
          Container(
            color: KiltoColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: KiltoColors.teal,
              unselectedLabelColor: KiltoColors.greyText,
              indicatorColor: KiltoColors.teal,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Info'),
                Tab(text: 'Odontograma'),
                Tab(text: 'Historial'),
                Tab(text: 'Docs'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildOdontogramTab(),
                _buildHistorialTab(),
                _buildDocsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: KiltoColors.greyText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Info Tab ──
  Widget _buildInfoTab() {
    final allergies = patient['allergies'] as String;
    final hasAllergies = allergies != 'Ninguna';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal data card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KiltoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: KiltoColors.greyMid),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_outline, size: 18, color: KiltoColors.teal),
                    SizedBox(width: 8),
                    Text(
                      'Datos personales',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _infoRow('Email', patient['email'] as String),
                _infoRow('Fecha nac.', patient['dob'] as String),
                _infoRow('Tipo sangre', patient['blood'] as String),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alergias',
                        style: TextStyle(fontSize: 13, color: KiltoColors.greyText),
                      ),
                      Container(
                        padding: hasAllergies
                            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
                            : EdgeInsets.zero,
                        decoration: hasAllergies
                            ? BoxDecoration(
                                color: KiltoColors.redLight,
                                borderRadius: BorderRadius.circular(6),
                              )
                            : null,
                        child: Text(
                          allergies,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: hasAllergies ? KiltoColors.red : KiltoColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Last visits
          const Text(
            '\u00daltimas visitas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: KiltoColors.navy,
            ),
          ),
          const SizedBox(height: 10),
          ...DemoData.treatmentHistory.take(3).map((t) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KiltoColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: KiltoColors.greyMid),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 18, color: KiltoColors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t['service'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: KiltoColors.navy,
                          ),
                        ),
                        Text(
                          '${t['date']} \u2022 ${t['doctor']}',
                          style: const TextStyle(fontSize: 11, color: KiltoColors.greyText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _actionButton(context, Icons.calendar_today, 'Agendar cita', () => _showAppointmentSheet(context)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(context, Icons.upload_file, 'Subir doc', () => _showUploadDocSheet(context)),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: KiltoColors.greyText),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: KiltoColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: KiltoColors.teal,
        foregroundColor: KiltoColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showAppointmentSheet(BuildContext context) {
    String? selectedService;
    String? selectedTime;
    final serviceNames = DemoData.services.map((s) => s['name'] as String).toList();
    final timeSlots = DemoData.availableTimeSlots;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Agendar Cita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedService,
                decoration: const InputDecoration(labelText: 'Servicio', border: OutlineInputBorder()),
                items: serviceNames.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setSheetState(() => selectedService = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                initialValue: 'Hoy - Abril 14, 2026',
                decoration: const InputDecoration(labelText: 'Fecha', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTime,
                decoration: const InputDecoration(labelText: 'Hora', border: OutlineInputBorder()),
                items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setSheetState(() => selectedTime = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cita agendada exitosamente'), backgroundColor: Color(0xFF2EC4B6)),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: KiltoColors.teal, foregroundColor: KiltoColors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDocSheet(BuildContext context) {
    String? selectedType;
    const docTypes = ['Radiografía', 'Receta', 'Presupuesto', 'Consentimiento'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Subir Documento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de documento', border: OutlineInputBorder()),
                items: docTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setSheetState(() => selectedType = v),
              ),
              const SizedBox(height: 12),
              TextFormField(decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Documento subido exitosamente'), backgroundColor: Color(0xFF2EC4B6)),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: KiltoColors.teal, foregroundColor: KiltoColors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Subir', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTreatmentSheet(BuildContext context) {
    String? selectedTreatment;
    const treatmentTypes = ['Empaste', 'Endodoncia', 'Corona', 'Extracción', 'Limpieza', 'Radiografía'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Tratamiento - Diente $_selectedTooth', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTreatment,
                decoration: const InputDecoration(labelText: 'Tipo de tratamiento', border: OutlineInputBorder()),
                items: treatmentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setSheetState(() => selectedTreatment = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder(), alignLabelWithHint: true),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tratamiento guardado'), backgroundColor: Color(0xFF2EC4B6)),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: KiltoColors.teal, foregroundColor: KiltoColors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Foto - Diente $_selectedTooth', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: KiltoColors.teal, size: 28),
              title: const Text('Tomar foto', style: TextStyle(fontWeight: FontWeight.w600, color: KiltoColors.navy)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Foto guardada'), backgroundColor: Color(0xFF2EC4B6)),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, color: KiltoColors.teal, size: 28),
              title: const Text('Subir de galería', style: TextStyle(fontWeight: FontWeight.w600, color: KiltoColors.navy)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Foto guardada'), backgroundColor: Color(0xFF2EC4B6)),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ── Odontogram Tab ──
  static const _statusColors = {
    'healthy': KiltoColors.white,
    'treated': KiltoColors.blue,
    'attention': KiltoColors.yellow,
    'extracted': KiltoColors.greyText,
  };

  static const _statusLabels = {
    'healthy': 'Sano',
    'treated': 'Tratado',
    'attention': 'Atenci\u00f3n',
    'extracted': 'Extra\u00eddo',
  };

  static const _upperFdi = [18, 17, 16, 15, 14, 13, 12, 11, 21, 22, 23, 24, 25, 26, 27, 28];
  static const _lowerFdi = [48, 47, 46, 45, 44, 43, 42, 41, 31, 32, 33, 34, 35, 36, 37, 38];

  Widget _buildOdontogramTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          _buildLegend(),
          const SizedBox(height: 16),
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
                _buildToothRow(_upperFdi, isUpper: true),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Container(width: 60, height: 2, color: KiltoColors.greyMid),
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
                _buildToothRow(_lowerFdi, isUpper: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Selected tooth detail
          if (_selectedTooth != null) _buildToothDetailCard(),
          const SizedBox(height: 16),
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
        final isWhite = entry.key == 'healthy';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isWhite ? KiltoColors.greyMid : color),
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

  Widget _buildToothRow(List<int> fdiNumbers, {required bool isUpper}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...fdiNumbers.take(8).map((fdi) => _buildTooth(fdi, isUpper)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(width: 1, height: 40, color: KiltoColors.greyMid),
          ),
          ...fdiNumbers.skip(8).map((fdi) => _buildTooth(fdi, isUpper)),
        ],
      ),
    );
  }

  Widget _buildTooth(int fdi, bool isUpper) {
    final data = DemoData.toothData[fdi];
    final status = data?['status'] as String? ?? 'healthy';
    final fill = _statusColors[status] ?? KiltoColors.white;
    final isExtracted = status == 'extracted';
    final borderColor = status == 'healthy' ? KiltoColors.greyMid : fill;
    final isSelected = _selectedTooth == fdi;

    return GestureDetector(
      onTap: () => setState(() => _selectedTooth = fdi),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  border: Border.all(color: KiltoColors.teal, width: 2),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Column(
            children: [
              if (isUpper)
                Text(
                  '$fdi',
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
                  '$fdi',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: KiltoColors.greyText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToothDetailCard() {
    final fdi = _selectedTooth!;
    final data = DemoData.toothData[fdi];
    final name = data?['name'] as String? ?? 'Diente $fdi';
    final status = data?['status'] as String? ?? 'healthy';
    final treatments = data?['treatments'] as List<dynamic>? ?? [];
    final statusLabel = _statusLabels[status] ?? status;
    final statusColor = _statusColors[status] ?? KiltoColors.white;
    final isHealthy = status == 'healthy';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KiltoColors.teal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isHealthy
                      ? KiltoColors.greenLight
                      : statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$fdi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isHealthy ? KiltoColors.green : statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isHealthy
                            ? KiltoColors.greenLight
                            : statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isHealthy ? KiltoColors.green : statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (treatments.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...treatments.map((t) {
              final treatment = t as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: KiltoColors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${treatment['desc']} - ${treatment['date']}',
                        style: const TextStyle(fontSize: 12, color: KiltoColors.navy),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 14),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _actionButton(context, Icons.add_circle_outline, 'Agregar tratamiento', () => _showAddTreatmentSheet(context)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(context, Icons.camera_alt_outlined, 'Tomar/subir foto', () => _showPhotoSheet(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Historial Tab ──
  Widget _buildHistorialTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: DemoData.treatmentHistory.length,
      itemBuilder: (context, index) {
        final t = DemoData.treatmentHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KiltoColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KiltoColors.greyMid),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      t['service'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KiltoColors.navy,
                      ),
                    ),
                  ),
                  Text(
                    t['cost'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: KiltoColors.greyText),
                  const SizedBox(width: 4),
                  Text(
                    t['date'] as String,
                    style: const TextStyle(fontSize: 12, color: KiltoColors.greyText),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.person_outline, size: 12, color: KiltoColors.greyText),
                  const SizedBox(width: 4),
                  Text(
                    t['doctor'] as String,
                    style: const TextStyle(fontSize: 12, color: KiltoColors.greyText),
                  ),
                ],
              ),
              if (t['note'] != null) ...[
                const SizedBox(height: 6),
                Text(
                  t['note'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: KiltoColors.navy.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Docs Tab ──
  Widget _buildDocsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showUploadDocSheet(context),
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Subir documento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KiltoColors.teal,
                foregroundColor: KiltoColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...DemoData.documents.map((doc) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KiltoColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KiltoColors.greyMid),
              ),
              child: Row(
                children: [
                  Text(
                    doc['icon'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['title'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: KiltoColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doc['date']} \u2022 ${doc['doctor']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: KiltoColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: KiltoColors.grey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      doc['category'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: KiltoColors.greyText,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Tooth painter reused from odontogram module
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
