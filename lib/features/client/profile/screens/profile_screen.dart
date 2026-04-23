import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';
import '../../../../config/feature_flags.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/auth/auth_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _appointmentReminders = true;
  bool _promotions = false;
  bool _newDocuments = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: false,
      ),
      body: kDemoMode ? _buildDemo() : _buildReal(),
    );
  }

  // =====================================================================
  // Real API
  // =====================================================================
  Widget _buildReal() {
    final async = ref.watch(profileProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _errorState(e.toString()),
      data: (profile) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(profileProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeaderReal(profile.personal),
              const SizedBox(height: 16),
              _buildPersonalCardReal(profile.personal),
              const SizedBox(height: 12),
              _buildMedicalCardReal(profile.medical),
              const SizedBox(height: 12),
              _buildNotificationsCard(),
              const SizedBox(height: 20),
              _logoutButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderReal(PersonalInfo p) {
    final initials = _initialsFrom(p.name);
    return _profileHeader(
      name: p.name.isEmpty ? 'Mi perfil' : p.name,
      email: p.email ?? '',
      phone: p.phone ?? '',
      initials: initials,
      avatarUrl: p.avatarUrl,
    );
  }

  Widget _buildPersonalCardReal(PersonalInfo p) {
    return _infoCardWithEdit(
      title: 'Información personal',
      icon: Icons.person_outline,
      onEdit: () => _editPersonal(p),
      items: [
        _InfoRow(
            label: 'Fecha de nacimiento', value: p.dateOfBirth ?? '—'),
        _InfoRow(label: 'CI', value: p.nationalId ?? '—'),
        _InfoRow(label: 'Teléfono', value: p.phone ?? '—'),
        _InfoRow(label: 'Dirección', value: p.address ?? '—'),
        _InfoRow(label: 'Ciudad', value: p.city ?? '—'),
      ],
    );
  }

  Widget _buildMedicalCardReal(MedicalInfo? m) {
    return _infoCardWithEdit(
      title: 'Información médica',
      icon: Icons.medical_information_outlined,
      onEdit: () => _editMedical(m),
      items: [
        _InfoRow(label: 'Tipo de sangre', value: m?.bloodType ?? '—'),
        _InfoRow(label: 'Alergias', value: m?.allergies ?? 'Ninguna'),
        _InfoRow(label: 'Medicamentos', value: m?.medications ?? 'Ninguno'),
        _InfoRow(label: 'Condiciones', value: m?.conditions ?? 'Ninguna'),
        _InfoRow(
            label: 'Contacto emergencia',
            value: m?.emergencyContactName ?? '—'),
        _InfoRow(
            label: 'Teléfono emergencia',
            value: m?.emergencyContactPhone ?? '—'),
      ],
    );
  }

  Future<void> _editPersonal(PersonalInfo p) async {
    final updated = await showModalBottomSheet<_PersonalDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PersonalEditSheet(initial: p),
    );
    if (updated == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(profileServiceProvider).updatePersonal(
            firstName: updated.firstName,
            lastName: updated.lastName,
            phone: updated.phone,
            dateOfBirth: updated.dateOfBirth,
            nationalId: updated.nationalId,
            address: updated.address,
            city: updated.city,
          );
      ref.invalidate(profileProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _editMedical(MedicalInfo? m) async {
    final updated = await showModalBottomSheet<_MedicalDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MedicalEditSheet(initial: m),
    );
    if (updated == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(profileServiceProvider).updateMedical(
            bloodType: updated.bloodType,
            allergies: updated.allergies,
            medications: updated.medications,
            conditions: updated.conditions,
            emergencyContactName: updated.emergencyContactName,
            emergencyContactPhone: updated.emergencyContactPhone,
          );
      ref.invalidate(profileProvider);
      messenger.showSnackBar(
          const SnackBar(content: Text('Información médica actualizada')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // =====================================================================
  // Demo (legacy)
  // =====================================================================
  Widget _buildDemo() {
    final userName = DemoData.user['name'] as String;
    final userEmail = DemoData.user['email'] as String;
    final userPhone = DemoData.user['phone'] as String;
    final initials = DemoData.user['initials'] as String;
    final personal = DemoData.profile['personal'] as Map<String, dynamic>;
    final medical = DemoData.profile['medical'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _profileHeader(
              name: userName,
              email: userEmail,
              phone: userPhone,
              initials: initials),
          const SizedBox(height: 16),
          _infoCard(
            title: 'Información personal',
            icon: Icons.person_outline,
            items: [
              _InfoRow(
                  label: 'Fecha de nacimiento',
                  value: personal['date_of_birth'] as String),
              _InfoRow(label: 'CI', value: personal['national_id'] as String),
              _InfoRow(label: 'Dirección', value: personal['address'] as String),
              _InfoRow(label: 'Ciudad', value: personal['city'] as String),
            ],
          ),
          const SizedBox(height: 12),
          _infoCard(
            title: 'Información médica',
            icon: Icons.medical_information_outlined,
            items: [
              _InfoRow(label: 'Tipo de sangre', value: medical['blood_type'] as String),
              _InfoRow(label: 'Alergias', value: medical['allergies'] as String),
              _InfoRow(label: 'Medicamentos', value: medical['medications'] as String),
              _InfoRow(label: 'Condiciones', value: medical['conditions'] as String),
            ],
          ),
          const SizedBox(height: 12),
          _buildNotificationsCard(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/clinic/dashboard'),
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: const Text('Cambiar a vista Clínica'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KiltoColors.navy,
                foregroundColor: KiltoColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _logoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // =====================================================================
  // Shared widgets
  // =====================================================================
  Widget _profileHeader({
    required String name,
    required String email,
    required String phone,
    required String initials,
    String? avatarUrl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Theme.of(context).colorScheme.primary,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(initials,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.white))
                : null,
          ),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KiltoColors.navy)),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(email,
                style: const TextStyle(
                    fontSize: 13, color: KiltoColors.greyText)),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(phone,
                style: const TextStyle(
                    fontSize: 13, color: KiltoColors.greyText)),
          ],
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<_InfoRow> items,
  }) {
    return Container(
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
          Row(
            children: [
              Icon(icon, size: 18, color: KiltoColors.teal),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.navy)),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(_rowItem),
        ],
      ),
    );
  }

  Widget _infoCardWithEdit({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required List<_InfoRow> items,
  }) {
    return Container(
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
          Row(
            children: [
              Icon(icon, size: 18, color: KiltoColors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.navy)),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: KiltoColors.teal),
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(_rowItem),
        ],
      ),
    );
  }

  Widget _rowItem(_InfoRow item) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(item.label,
                  style: const TextStyle(
                      fontSize: 13, color: KiltoColors.greyText)),
            ),
            Expanded(
              child: Text(item.value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: KiltoColors.navy)),
            ),
          ],
        ),
      );

  Widget _buildNotificationsCard() {
    return Container(
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
              Icon(Icons.notifications_outlined,
                  size: 18, color: KiltoColors.teal),
              SizedBox(width: 8),
              Text('Notificaciones',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.navy)),
            ],
          ),
          const SizedBox(height: 8),
          _toggleRow('Recordatorios de citas', _appointmentReminders,
              (v) => setState(() => _appointmentReminders = v)),
          _toggleRow('Promociones', _promotions,
              (v) => setState(() => _promotions = v)),
          _toggleRow('Nuevos documentos', _newDocuments,
              (v) => setState(() => _newDocuments = v)),
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: KiltoColors.navy)),
            SizedBox(
              height: 28,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Theme.of(context).colorScheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      );

  Widget _logoutButton() {
    final showSwitchClinic = kCentralAuth && !kDemoMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSwitchClinic) ...[
          OutlinedButton.icon(
            onPressed: _onSwitchClinic,
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Cambiar de clínica'),
            style: OutlinedButton.styleFrom(
              foregroundColor: KiltoColors.navy,
              side: const BorderSide(color: KiltoColors.greyMid),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        ElevatedButton.icon(
          onPressed: () async {
            if (kCentralAuth && !kDemoMode) {
              await ref.read(accountProvider.notifier).logout();
            } else if (kDemoMode) {
              context.go('/login');
            } else {
              ref.read(authStateProvider.notifier).logout();
            }
          },
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Cerrar sesión de Kilto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: KiltoColors.redLight,
            foregroundColor: KiltoColors.red,
            iconColor: KiltoColors.red,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  /// Leaves the current clinic's tenant session without logging out of the
  /// Kilto account. Bounces back to the clinic selector so the user can pick
  /// another clinic or add a new one.
  Future<void> _onSwitchClinic() async {
    await ref.read(tenantSessionProvider.notifier).leave();
    if (!mounted) return;
    context.go('/clinics');
  }

  Widget _errorState(String msg) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: KiltoColors.greyText),
            const SizedBox(height: 12),
            const Text('No se pudo cargar el perfil',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: KiltoColors.greyText)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.invalidate(profileProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );

  String _initialsFrom(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return 'U';
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow({required this.label, required this.value});
}

// =======================================================================
// Personal edit sheet
// =======================================================================

class _PersonalDraft {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? dateOfBirth;
  final String? nationalId;
  final String? address;
  final String? city;

  _PersonalDraft({
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.nationalId,
    this.address,
    this.city,
  });
}

class _PersonalEditSheet extends StatefulWidget {
  final PersonalInfo initial;
  const _PersonalEditSheet({required this.initial});

  @override
  State<_PersonalEditSheet> createState() => _PersonalEditSheetState();
}

class _PersonalEditSheetState extends State<_PersonalEditSheet> {
  late final _firstName =
      TextEditingController(text: widget.initial.firstName ?? '');
  late final _lastName =
      TextEditingController(text: widget.initial.lastName ?? '');
  late final _phone = TextEditingController(text: widget.initial.phone ?? '');
  late final _dob =
      TextEditingController(text: widget.initial.dateOfBirth ?? '');
  late final _ci =
      TextEditingController(text: widget.initial.nationalId ?? '');
  late final _address =
      TextEditingController(text: widget.initial.address ?? '');
  late final _city = TextEditingController(text: widget.initial.city ?? '');

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _dob.dispose();
    _ci.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Editar información personal',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy)),
            const SizedBox(height: 16),
            _field(_firstName, 'Nombre'),
            _field(_lastName, 'Apellido'),
            _field(_phone, 'Teléfono',
                keyboardType: TextInputType.phone),
            _field(_dob, 'Fecha de nacimiento (YYYY-MM-DD)'),
            _field(_ci, 'CI'),
            _field(_address, 'Dirección'),
            _field(_city, 'Ciudad'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      _PersonalDraft(
                        firstName: _nullIfEmpty(_firstName.text),
                        lastName: _nullIfEmpty(_lastName.text),
                        phone: _nullIfEmpty(_phone.text),
                        dateOfBirth: _nullIfEmpty(_dob.text),
                        nationalId: _nullIfEmpty(_ci.text),
                        address: _nullIfEmpty(_address.text),
                        city: _nullIfEmpty(_city.text),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: KiltoColors.white,
                    ),
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();
}

// =======================================================================
// Medical edit sheet
// =======================================================================

class _MedicalDraft {
  final String? bloodType;
  final String? allergies;
  final String? medications;
  final String? conditions;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  _MedicalDraft({
    this.bloodType,
    this.allergies,
    this.medications,
    this.conditions,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });
}

class _MedicalEditSheet extends StatefulWidget {
  final MedicalInfo? initial;
  const _MedicalEditSheet({this.initial});

  @override
  State<_MedicalEditSheet> createState() => _MedicalEditSheetState();
}

class _MedicalEditSheetState extends State<_MedicalEditSheet> {
  late final _blood =
      TextEditingController(text: widget.initial?.bloodType ?? '');
  late final _allergies =
      TextEditingController(text: widget.initial?.allergies ?? '');
  late final _meds =
      TextEditingController(text: widget.initial?.medications ?? '');
  late final _conditions =
      TextEditingController(text: widget.initial?.conditions ?? '');
  late final _emergencyName =
      TextEditingController(text: widget.initial?.emergencyContactName ?? '');
  late final _emergencyPhone =
      TextEditingController(text: widget.initial?.emergencyContactPhone ?? '');

  @override
  void dispose() {
    _blood.dispose();
    _allergies.dispose();
    _meds.dispose();
    _conditions.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Editar información médica',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy)),
            const SizedBox(height: 16),
            _field(_blood, 'Tipo de sangre (p.ej. O+)'),
            _field(_allergies, 'Alergias', maxLines: 2),
            _field(_meds, 'Medicamentos', maxLines: 2),
            _field(_conditions, 'Condiciones', maxLines: 2),
            _field(_emergencyName, 'Contacto de emergencia'),
            _field(_emergencyPhone, 'Tel. emergencia',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      _MedicalDraft(
                        bloodType: _nullIfEmpty(_blood.text),
                        allergies: _nullIfEmpty(_allergies.text),
                        medications: _nullIfEmpty(_meds.text),
                        conditions: _nullIfEmpty(_conditions.text),
                        emergencyContactName: _nullIfEmpty(_emergencyName.text),
                        emergencyContactPhone: _nullIfEmpty(_emergencyPhone.text),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: KiltoColors.white,
                    ),
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();
}
