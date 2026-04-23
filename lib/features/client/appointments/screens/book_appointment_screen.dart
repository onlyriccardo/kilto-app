import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';

/// 4-step booking wizard:
///  0) service → /v1/services
///  1) staff   → /v1/staff
///  2) date + time → /v1/availability?date=&staff_id=
///  3) review + notes → POST /v1/appointments
///
/// Demo mode preserves the old hardcoded UI so /demo smoke-tests still work.
class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  int _currentStep = 0;
  final _notesController = TextEditingController();
  bool _submitting = false;

  // Real-API selections
  ServiceCatalogItem? _service;
  StaffMember? _staff;
  DateTime? _selectedDate;
  String? _selectedSlot;

  // Built list of next 14 days
  final List<DateTime> _dates = List.generate(
    14,
    (i) => DateTime.now().add(Duration(days: i + 1)),
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _service != null;
      case 1:
        return _staff != null;
      case 2:
        return _selectedDate != null && _selectedSlot != null;
      case 3:
        return !_submitting;
      default:
        return false;
    }
  }

  void _next() {
    if (_currentStep < 3) setState(() => _currentStep++);
  }

  void _prev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/client/appointments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: _prev,
        ),
        title: const Text('Agendar cita'),
        centerTitle: false,
      ),
      body: kDemoMode ? _buildDemo() : _buildReal(),
    );
  }

  // =====================================================================
  // Real-API wizard
  // =====================================================================
  Widget _buildReal() {
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildRealStepContent(),
          ),
        ),
        _buildFooterButton(
          label: _currentStep == 3 ? 'Confirmar cita' : 'Continuar',
          onPressed: _canProceed
              ? (_currentStep == 3 ? _submit : _next)
              : null,
          loading: _submitting,
        ),
      ],
    );
  }

  Widget _buildRealStepContent() {
    switch (_currentStep) {
      case 0:
        return _serviceStepReal();
      case 1:
        return _staffStepReal();
      case 2:
        return _dateTimeStepReal();
      case 3:
        return _reviewStepReal();
      default:
        return const SizedBox();
    }
  }

  Widget _serviceStepReal() {
    final async = ref.watch(servicesCatalogProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _errorBlock('No se pudieron cargar los servicios', e),
      data: (services) {
        if (services.isEmpty) {
          return _emptyBlock(
            'Esta clínica aún no publica servicios',
            'Contáctala directamente para agendar.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepTitle('Selecciona un servicio',
                'Elige el tratamiento que necesitas'),
            const SizedBox(height: 20),
            ...services.map((s) => _serviceTile(s)),
          ],
        );
      },
    );
  }

  Widget _serviceTile(ServiceCatalogItem s) {
    final selected = _service?.id == s.id;
    return GestureDetector(
      onTap: () => setState(() => _service = s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? KiltoColors.teal.withOpacity(0.08)
              : KiltoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? KiltoColors.teal : KiltoColors.greyMid,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.medical_services_outlined,
                color: selected
                    ? KiltoColors.teal
                    : KiltoColors.navy.withOpacity(0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? KiltoColors.teal : KiltoColors.navy,
                      )),
                  if (s.description != null && s.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(s.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: KiltoColors.greyText)),
                    ),
                ],
              ),
            ),
            if (s.price != null)
              Text('Bs ${s.price}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? KiltoColors.teal
                          : KiltoColors.navy)),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle,
                  color: KiltoColors.teal, size: 22),
            ],
          ],
        ),
      ),
    );
  }

  Widget _staffStepReal() {
    final async = ref.watch(staffProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _errorBlock('No se pudo cargar el equipo', e),
      data: (staff) {
        if (staff.isEmpty) {
          return _emptyBlock('Sin profesionales disponibles',
              'Esta clínica aún no ha registrado personal.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepTitle('Elige tu profesional', 'Quién te atenderá'),
            const SizedBox(height: 20),
            ...staff.map((s) => _staffTile(s)),
          ],
        );
      },
    );
  }

  Widget _staffTile(StaffMember s) {
    final selected = _staff?.id == s.id;
    final initial = s.name.isNotEmpty ? s.name[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: () => setState(() {
        _staff = s;
        _selectedSlot = null; // invalidate slot choice
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? KiltoColors.teal.withOpacity(0.08)
              : KiltoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? KiltoColors.teal : KiltoColors.greyMid,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected
                  ? KiltoColors.teal
                  : KiltoColors.navy.withOpacity(0.1),
              child: Text(initial,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: selected ? KiltoColors.white : KiltoColors.navy,
                  )),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: KiltoColors.navy)),
                  if (s.role != null)
                    Text(s.role!,
                        style: const TextStyle(
                            fontSize: 12, color: KiltoColors.greyText)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: KiltoColors.teal, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeStepReal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle('Fecha y hora', 'Elige cuándo quieres tu cita'),
        const SizedBox(height: 20),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            itemBuilder: (_, i) => _dateChip(_dates[i]),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Horarios disponibles',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: KiltoColors.navy)),
        const SizedBox(height: 12),
        if (_selectedDate == null)
          const Text('Selecciona una fecha arriba.',
              style: TextStyle(
                  fontSize: 12, color: KiltoColors.greyText))
        else
          _availabilityGrid(),
      ],
    );
  }

  Widget _dateChip(DateTime d) {
    final selected = _selectedDate != null &&
        _selectedDate!.year == d.year &&
        _selectedDate!.month == d.month &&
        _selectedDate!.day == d.day;
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return GestureDetector(
      onTap: () => setState(() {
        _selectedDate = d;
        _selectedSlot = null;
      }),
      child: Container(
        width: 58,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: selected ? KiltoColors.teal : KiltoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? KiltoColors.teal : KiltoColors.greyMid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weekdays[d.weekday - 1],
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? KiltoColors.white.withOpacity(0.8)
                      : KiltoColors.greyText,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 2),
            Text('${d.day}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: selected ? KiltoColors.white : KiltoColors.navy,
                )),
            Text(months[d.month - 1],
                style: TextStyle(
                  fontSize: 10,
                  color: selected
                      ? KiltoColors.white.withOpacity(0.8)
                      : KiltoColors.greyText,
                )),
          ],
        ),
      ),
    );
  }

  Widget _availabilityGrid() {
    final date =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    // Build a one-off future that we don't cache across dates.
    return FutureBuilder<List<String>>(
      future: ref
          .read(catalogServiceProvider)
          .availability(date: date, staffId: _staff?.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return _errorBlock('No se pudo cargar disponibilidad', snap.error);
        }
        final slots = snap.data ?? const [];
        if (slots.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No hay horarios disponibles para este día.',
                style: TextStyle(
                    fontSize: 13, color: KiltoColors.greyText)),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: slots.length,
          itemBuilder: (_, i) {
            final slot = slots[i];
            final selected = _selectedSlot == slot;
            return GestureDetector(
              onTap: () => setState(() => _selectedSlot = slot),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? KiltoColors.teal : KiltoColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? KiltoColors.teal
                        : KiltoColors.greyMid,
                  ),
                ),
                child: Center(
                  child: Text(slot,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? KiltoColors.white
                            : KiltoColors.navy,
                      )),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _reviewStepReal() {
    final dateLabel = _selectedDate != null
        ? '${_selectedDate!.day}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
        : '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle('Confirmar cita', 'Revisa los detalles'),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: KiltoColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: KiltoColors.greyMid),
          ),
          child: Column(
            children: [
              _summaryRow(Icons.medical_services_outlined, 'Servicio',
                  _service?.name ?? '-'),
              const Divider(height: 24),
              _summaryRow(Icons.person_outline, 'Profesional',
                  _staff?.name ?? '-'),
              const Divider(height: 24),
              _summaryRow(Icons.calendar_today, 'Fecha', dateLabel),
              const Divider(height: 24),
              _summaryRow(Icons.access_time, 'Hora', _selectedSlot ?? '-'),
              if (_service?.price != null) ...[
                const Divider(height: 24),
                _summaryRow(Icons.attach_money, 'Precio',
                    'Bs ${_service!.price}'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Notas adicionales (opcional)',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KiltoColors.navy),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Agrega alguna nota para tu profesional...',
            hintStyle: const TextStyle(
                fontSize: 13, color: KiltoColors.greyText),
            filled: true,
            fillColor: KiltoColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: KiltoColors.greyMid),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: KiltoColors.greyMid),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: KiltoColors.teal, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_service == null ||
        _staff == null ||
        _selectedDate == null ||
        _selectedSlot == null) {
      return;
    }
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(appointmentsServiceProvider).book(
            serviceName: _service!.name,
            staffId: _staff!.id,
            date:
                '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
            time: _selectedSlot!,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      if (!mounted) return;
      ref.invalidate(appointmentsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Cita agendada exitosamente'),
          backgroundColor: KiltoColors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.go('/client/appointments');
    } catch (e) {
      setState(() => _submitting = false);
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // =====================================================================
  // Shared UI
  // =====================================================================
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: i <= _currentStep
                    ? KiltoColors.teal
                    : KiltoColors.greyMid,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooterButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: KiltoColors.white,
        border: Border(top: BorderSide(color: KiltoColors.greyMid)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: KiltoColors.white,
            disabledBackgroundColor: KiltoColors.greyMid,
            disabledForegroundColor: KiltoColors.greyText,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 18, color: KiltoColors.teal),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: KiltoColors.greyText)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KiltoColors.navy)),
          ),
        ],
      );

  Widget _errorBlock(String title, Object? err) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline,
                size: 40, color: KiltoColors.greyText),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('$err',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: KiltoColors.greyText)),
          ],
        ),
      );

  Widget _emptyBlock(String title, String subtitle) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: KiltoColors.navy)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: KiltoColors.greyText)),
          ],
        ),
      );

  // =====================================================================
  // Demo mode (unchanged legacy hardcoded flow)
  // =====================================================================
  int? _demoServiceIdx;
  int? _demoDoctorIdx;
  int? _demoTimeIdx;

  List<Map<String, String>> get _demoServices =>
      DemoData.services.cast<Map<String, String>>();
  List<Map<String, String>> get _demoDoctors =>
      DemoData.doctors.cast<Map<String, String>>();
  List<String> get _demoTimes => DemoData.availableTimeSlots;

  bool get _demoCanProceed {
    switch (_currentStep) {
      case 0:
        return _demoServiceIdx != null;
      case 1:
        return _demoDoctorIdx != null;
      case 2:
        return _demoTimeIdx != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Widget _buildDemo() {
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildDemoContent(),
          ),
        ),
        _buildFooterButton(
          label: _currentStep == 3 ? 'Confirmar cita' : 'Continuar',
          onPressed: _demoCanProceed
              ? () {
                  if (_currentStep == 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cita agendada (demo)')),
                    );
                    context.go('/client/appointments');
                  } else {
                    _next();
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDemoContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepTitle('Selecciona un servicio',
                'Elige el tratamiento que necesitas'),
            const SizedBox(height: 20),
            ...List.generate(_demoServices.length, (i) {
              final s = _demoServices[i];
              final sel = _demoServiceIdx == i;
              return GestureDetector(
                onTap: () => setState(() => _demoServiceIdx = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel
                        ? KiltoColors.teal.withOpacity(0.08)
                        : KiltoColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          sel ? KiltoColors.teal : KiltoColors.greyMid,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medical_services_outlined),
                      const SizedBox(width: 12),
                      Expanded(child: Text(s['name'] ?? '')),
                      Text(s['price'] ?? ''),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepTitle('Elige tu profesional', ''),
            const SizedBox(height: 20),
            ...List.generate(_demoDoctors.length, (i) {
              final d = _demoDoctors[i];
              final sel = _demoDoctorIdx == i;
              return GestureDetector(
                onTap: () => setState(() => _demoDoctorIdx = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel
                        ? KiltoColors.teal.withOpacity(0.08)
                        : KiltoColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          sel ? KiltoColors.teal : KiltoColors.greyMid,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Text(d['name'] ?? ''),
                ),
              );
            }),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepTitle('Fecha y hora', ''),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.2),
              itemCount: _demoTimes.length,
              itemBuilder: (_, i) {
                final sel = _demoTimeIdx == i;
                return GestureDetector(
                  onTap: () => setState(() => _demoTimeIdx = i),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          sel ? KiltoColors.teal : KiltoColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel
                              ? KiltoColors.teal
                              : KiltoColors.greyMid),
                    ),
                    child: Center(child: Text(_demoTimes[i])),
                  ),
                );
              },
            ),
          ],
        );
      case 3:
        return const _StepTitle('Confirmar cita (demo)',
            'Los datos no se enviarán al servidor en modo demo.');
      default:
        return const SizedBox();
    }
  }
}

class _StepTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepTitle(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KiltoColors.navy)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 13, color: KiltoColors.greyText)),
          ],
        ],
      );
}
