import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/clinic_providers.dart';
import '../../subscreens/patient_detail_screen.dart';

/// Staff-side patients browser. Fetched from /v1/clinic/patients with
/// filter + search passed through. The backend computes each patient's
/// status (active/inactive) from recent bookings.
class ClinicPatientsScreen extends ConsumerStatefulWidget {
  const ClinicPatientsScreen({super.key});

  @override
  ConsumerState<ClinicPatientsScreen> createState() => _ClinicPatientsScreenState();
}

class _ClinicPatientsScreenState extends ConsumerState<ClinicPatientsScreen> {
  String _searchQuery = '';
  String _activeFilter = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  // UI label → backend filter key.
  static const _filters = ['Todos', 'Activos', 'Inactivos', 'Con deuda'];
  static const _filterKey = {
    'Todos': 'all',
    'Activos': 'active',
    'Inactivos': 'inactive',
    'Con deuda': 'overdue',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = PatientsQuery(
      filter: _filterKey[_activeFilter] ?? 'all',
      query: _searchQuery,
    );
    final async = ref.watch(clinicPatientsProvider(q));

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + add
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pacientes',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: KiltoColors.navy),
                  ),
                  GestureDetector(
                    onTap: () => _showAddPatientSheet(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar paciente...',
                  prefixIcon: const Icon(Icons.search, color: KiltoColors.greyText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: KiltoColors.greyMid),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: KiltoColors.greyMid),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: KiltoColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter pills
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _filters.map((filter) {
                  final isActive = _activeFilter == filter;
                  final accent = Theme.of(context).colorScheme.primary;
                  final onAccent = Theme.of(context).colorScheme.onPrimary;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = filter),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? accent : KiltoColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isActive ? accent : KiltoColors.greyMid),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive ? onAccent : KiltoColors.navy),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _buildError(err, () => ref.invalidate(clinicPatientsProvider(q))),
                data: (patients) => _buildList(patients, q),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object err, VoidCallback retry) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: KiltoColors.red, size: 36),
              const SizedBox(height: 8),
              Text('No se pudieron cargar los pacientes\n$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: KiltoColors.greyText)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: retry, child: const Text('Reintentar')),
            ],
          ),
        ),
      );

  Widget _buildList(List<Map<String, dynamic>> patients, PatientsQuery q) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(clinicPatientsProvider(q)),
      child: patients.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No hay pacientes que coincidan con este filtro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: KiltoColors.greyText),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${patients.length} pacientes',
                      style: const TextStyle(
                          fontSize: 13,
                          color: KiltoColors.greyText,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: patients.length,
                    itemBuilder: (context, i) => _buildPatientCard(patients[i]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> p) {
    final status = p['status'] as String? ?? 'active';
    final statusLabel = switch (status) {
      'active' => 'Activo',
      'inactive' => 'Inactivo',
      'overdue' => 'Deuda',
      _ => status,
    };
    final statusBg = switch (status) {
      'active' => KiltoColors.greenLight,
      'overdue' => KiltoColors.redLight,
      _ => KiltoColors.grey,
    };
    final statusFg = switch (status) {
      'active' => KiltoColors.green,
      'overdue' => KiltoColors.red,
      _ => KiltoColors.greyText,
    };
    final balance = p['balance'] as String? ?? '0 Bs';
    final balanceAmount = (p['balance_amount'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: () {
        final id = p['id'] as int?;
        if (id == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PatientDetailScreen(patientId: id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: KiltoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KiltoColors.greyMid),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                p['initials'] as String? ?? '??',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p['name'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: KiltoColors.navy),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusFg),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 12, color: KiltoColors.greyText),
                      const SizedBox(width: 4),
                      Text(p['phone'] as String? ?? '—',
                          style: const TextStyle(
                              fontSize: 12, color: KiltoColors.greyText)),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today,
                          size: 12, color: KiltoColors.greyText),
                      const SizedBox(width: 4),
                      Text(
                        p['last_visit'] != null
                            ? 'Últ. visita: ${p['last_visit']}'
                            : 'Sin visitas',
                        style: const TextStyle(
                            fontSize: 12, color: KiltoColors.greyText),
                      ),
                    ],
                  ),
                  if (balanceAmount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Saldo: $balance',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: KiltoColors.red),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: KiltoColors.greyText),
          ],
        ),
      ),
    );
  }

  void _showAddPatientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddPatientSheet(
        onCreated: (created) {
          // Refresh the patient list for every cached filter/query combo
          // so the newly-created patient shows up immediately.
          ref.invalidate(clinicPatientsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Paciente ${created['name']} creado.'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

/// Create-patient form. Requires first name + at least one of email/phone.
/// Submits via ClinicPatientsService.create and handles 409 duplicates
/// with a clear message.
class _AddPatientSheet extends ConsumerStatefulWidget {
  final void Function(Map<String, dynamic> createdPatient) onCreated;
  const _AddPatientSheet({required this.onCreated});

  @override
  ConsumerState<_AddPatientSheet> createState() => _AddPatientSheetState();
}

class _AddPatientSheetState extends ConsumerState<_AddPatientSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _nationalId = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  DateTime? _dob;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _nationalId.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_email.text.trim().isEmpty && _phone.text.trim().isEmpty) {
      setState(() => _errorText = 'Ingresa al menos un email o teléfono.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final created = await ref.read(clinicPatientsServiceProvider).create(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            dateOfBirth: _dob?.toIso8601String().substring(0, 10),
            nationalId: _nationalId.text.trim(),
            address: _address.text.trim(),
            city: _city.text.trim(),
          );
      if (!mounted) return;
      widget.onCreated(created);
      Navigator.pop(context);
    } catch (e) {
      // Dio throws a DioException on non-2xx; show the backend message when
      // available (duplicate email/phone yields 409 with a friendly text).
      String msg = 'No se pudo crear el paciente.';
      final err = e.toString();
      if (err.contains('Ya existe un paciente')) {
        msg = err.contains('correo')
            ? 'Ya existe un paciente con ese correo.'
            : 'Ya existe un paciente con ese teléfono.';
      }
      setState(() => _errorText = msg);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Nuevo paciente',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.navy)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _firstName,
                      label: 'Nombre *',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Requerido'
                          : null,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      controller: _lastName,
                      label: 'Apellido',
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _field(
                controller: _phone,
                label: 'Teléfono',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _field(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(v.trim());
                  return ok ? null : 'Email inválido';
                },
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDob,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(
                    _dob == null
                        ? 'Seleccionar…'
                        : '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        color: _dob == null
                            ? KiltoColors.greyText
                            : KiltoColors.navy),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _field(controller: _nationalId, label: 'CI / Documento'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _field(controller: _address, label: 'Dirección'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(controller: _city, label: 'Ciudad'),
                  ),
                ],
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: KiltoColors.redLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 16, color: KiltoColors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorText!,
                            style: const TextStyle(
                                fontSize: 12, color: KiltoColors.red)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Text('Crear paciente',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
