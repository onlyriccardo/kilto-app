import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/clinic_theme.dart';
import '../../../../config/demo_data.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';
import '../../../../core/widgets/kilto_card.dart';
import '../../../../core/widgets/kilto_empty_state.dart';
import '../../../../core/widgets/kilto_text.dart';

/// 4-step booking wizard:
///  0) service → /v1/services
///  1) staff   → /v1/staff
///  2) date + time → /v1/availability?date=&staff_id=
///  3) review + notes → POST /v1/appointments
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

  final List<DateTime> _dates = List.generate(
    14,
    (i) => DateTime.now().add(Duration(days: i + 1)),
  );

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Color get _accent =>
      Theme.of(context).extension<ClinicAccentExtension>()?.accent ??
      KiltoColors.brandPrimary;

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
    const labels = ['Servicio', 'Profesional', 'Fecha y hora', 'Confirmar'];

    return Scaffold(
      backgroundColor: KiltoColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _prev,
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: KiltoColors.zinc900),
                    style: IconButton.styleFrom(
                      backgroundColor: KiltoColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(KiltoRadii.xsmall),
                        side: const BorderSide(color: KiltoColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KiltoText.label('Paso ${_currentStep + 1} de 4'),
                        KiltoText.h3(labels[_currentStep]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _ProgressBar(currentStep: _currentStep, accent: _accent),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: kDemoMode ? _buildDemoContent() : _buildRealStepContent(),
              ),
            ),
            _Footer(
              label: _currentStep == 3 ? 'Confirmar cita' : 'Continuar',
              onPressed: kDemoMode
                  ? (_demoCanProceed
                      ? () {
                          if (_currentStep == 3) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Cita agendada (demo)')),
                            );
                            context.go('/client/appointments');
                          } else {
                            _next();
                          }
                        }
                      : null)
                  : (_canProceed
                      ? (_currentStep == 3 ? _submit : _next)
                      : null),
              loading: _submitting,
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  // Real-API steps
  // ===================================================================
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
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _errorBlock('No se pudieron cargar los servicios', e),
      data: (services) {
        if (services.isEmpty) {
          return KiltoEmptyState(
            icon: Icons.medical_services_outlined,
            title: 'Esta clínica aún no publica servicios',
            subtitle: 'Contáctala directamente para agendar.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final s in services) ...[
              _SelectableRow(
                title: s.name,
                subtitle: (s.description ?? '').isNotEmpty
                    ? s.description!
                    : null,
                trailing: s.price != null ? 'Bs ${s.price}' : null,
                leading: const Icon(Icons.medical_services_outlined,
                    size: 18, color: KiltoColors.zinc700),
                selected: _service?.id == s.id,
                accent: _accent,
                onTap: () => setState(() => _service = s),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }

  Widget _staffStepReal() {
    final async = ref.watch(staffProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _errorBlock('No se pudo cargar el equipo', e),
      data: (staff) {
        if (staff.isEmpty) {
          return KiltoEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'Sin profesionales disponibles',
            subtitle: 'Esta clínica aún no ha registrado personal.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final s in staff) ...[
              _SelectableRow(
                title: s.name,
                subtitle: s.role,
                leading: _StaffAvatar(name: s.name, selected: _staff?.id == s.id, accent: _accent),
                selected: _staff?.id == s.id,
                accent: _accent,
                onTap: () => setState(() {
                  _staff = s;
                  _selectedSlot = null;
                }),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }

  Widget _dateTimeStepReal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: _dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _dateChip(_dates[i]),
          ),
        ),
        const SizedBox(height: 24),
        KiltoText.eyebrow('Horarios disponibles'),
        const SizedBox(height: 10),
        if (_selectedDate == null)
          KiltoText.body('Selecciona una fecha arriba.',
              color: KiltoColors.zinc500)
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
        width: 62,
        decoration: BoxDecoration(
          color: selected ? _accent : KiltoColors.surface,
          borderRadius: BorderRadius.circular(KiltoRadii.medium),
          border: Border.all(
            color: selected ? _accent : KiltoColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected ? KiltoShadows.hero(_accent) : KiltoShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekdays[d.weekday - 1],
              style: TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: selected ? Colors.white : KiltoColors.zinc500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${d.day}',
              style: TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.0,
                color: selected ? Colors.white : KiltoColors.zinc950,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              months[d.month - 1].toUpperCase(),
              style: TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: selected ? Colors.white : KiltoColors.zinc500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _availabilityGrid() {
    final date =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
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
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: KiltoText.body('No hay horarios disponibles para este día.',
                color: KiltoColors.zinc500),
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
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selected ? _accent : KiltoColors.surface,
                  borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
                  border: Border.all(
                    color: selected ? _accent : KiltoColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    slot,
                    style: TextStyle(
                      fontFamily: KiltoFonts.familyHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : KiltoColors.zinc950,
                    ),
                  ),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KiltoCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              _summaryRow(Icons.medical_services_outlined, 'Servicio',
                  _service?.name ?? '-'),
              const Divider(height: 1, color: KiltoColors.borderLight),
              _summaryRow(Icons.person_outline, 'Profesional',
                  _staff?.name ?? '-'),
              const Divider(height: 1, color: KiltoColors.borderLight),
              _summaryRow(Icons.calendar_today_rounded, 'Fecha', dateLabel),
              const Divider(height: 1, color: KiltoColors.borderLight),
              _summaryRow(Icons.access_time_rounded, 'Hora',
                  _selectedSlot ?? '-'),
              if (_service?.price != null) ...[
                const Divider(height: 1, color: KiltoColors.borderLight),
                _summaryRow(Icons.attach_money_rounded, 'Precio',
                    'Bs ${_service!.price}'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        KiltoText.eyebrow('Notas (opcional)'),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: const TextStyle(
            fontFamily: KiltoFonts.familyBody,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: KiltoColors.zinc950,
          ),
          decoration: const InputDecoration(
            hintText: 'Agrega alguna nota para tu profesional...',
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
          backgroundColor: KiltoColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KiltoRadii.small),
          ),
        ),
      );
      context.go('/client/appointments');
    } catch (e) {
      setState(() => _submitting = false);
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _summaryRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: KiltoColors.zinc100,
                borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
              ),
              child: Icon(icon, size: 14, color: KiltoColors.zinc700),
            ),
            const SizedBox(width: 10),
            KiltoText.label(label),
            const Spacer(),
            Flexible(
              child: KiltoText.strong(value, align: TextAlign.end, size: 13),
            ),
          ],
        ),
      );

  Widget _errorBlock(String title, Object? err) => KiltoEmptyState(
        icon: Icons.error_outline_rounded,
        title: title,
        subtitle: '$err',
      );

  // ===================================================================
  // Demo path (unchanged data, restyled)
  // ===================================================================
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

  Widget _buildDemoContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _demoServices.length; i++) ...[
              _SelectableRow(
                title: _demoServices[i]['name'] ?? '',
                trailing: _demoServices[i]['price'],
                leading: const Icon(Icons.medical_services_outlined,
                    size: 18, color: KiltoColors.zinc700),
                selected: _demoServiceIdx == i,
                accent: _accent,
                onTap: () => setState(() => _demoServiceIdx = i),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _demoDoctors.length; i++) ...[
              _SelectableRow(
                title: _demoDoctors[i]['name'] ?? '',
                leading: _StaffAvatar(
                    name: _demoDoctors[i]['name'] ?? '?',
                    selected: _demoDoctorIdx == i,
                    accent: _accent),
                selected: _demoDoctorIdx == i,
                accent: _accent,
                onTap: () => setState(() => _demoDoctorIdx = i),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      case 2:
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: _demoTimes.length,
          itemBuilder: (_, i) {
            final sel = _demoTimeIdx == i;
            return GestureDetector(
              onTap: () => setState(() => _demoTimeIdx = i),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: sel ? _accent : KiltoColors.surface,
                  borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
                  border: Border.all(
                    color: sel ? _accent : KiltoColors.border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _demoTimes[i],
                    style: TextStyle(
                      fontFamily: KiltoFonts.familyHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : KiltoColors.zinc950,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      case 3:
        return KiltoCard(
          padding: const EdgeInsets.all(18),
          child: KiltoText.body(
            'Los datos no se enviarán al servidor en modo demo.',
            color: KiltoColors.zinc500,
          ),
        );
      default:
        return const SizedBox();
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final int currentStep;
  final Color accent;
  const _ProgressBar({required this.currentStep, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
            decoration: BoxDecoration(
              color: i <= currentStep ? accent : KiltoColors.zinc200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _Footer extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const _Footer({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: KiltoColors.surface,
        border: Border(top: BorderSide(color: KiltoColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: KiltoColors.onBrand,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}

class _SelectableRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final Widget leading;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _SelectableRow({
    required this.title,
    required this.leading,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(KiltoRadii.medium);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected
                ? Color.alphaBlend(accent.withValues(alpha: 0.08), Colors.white)
                : KiltoColors.surface,
            borderRadius: radius,
            border: Border.all(
              color: selected ? accent : KiltoColors.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected ? null : KiltoShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KiltoText.strong(title, size: 14),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        KiltoText.label(subtitle!,
                            color: KiltoColors.zinc500),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  KiltoText.strong(trailing!, size: 13, color: KiltoColors.zinc700),
                ],
                if (selected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle_rounded, color: accent, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaffAvatar extends StatelessWidget {
  final String name;
  final bool selected;
  final Color accent;
  const _StaffAvatar(
      {required this.name, required this.selected, required this.accent});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final bg = selected ? accent : KiltoColors.zinc100;
    final fg = selected
        ? (accent.computeLuminance() > 0.55 ? Colors.black : Colors.white)
        : KiltoColors.zinc900;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}
