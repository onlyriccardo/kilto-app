import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/clinic_theme.dart';
import '../../../../config/demo_data.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/feature_flags.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/widgets/kilto_card.dart';
import '../../../../core/widgets/kilto_empty_state.dart';
import '../../../../core/widgets/kilto_section_header.dart';
import '../../../../core/widgets/kilto_text.dart';

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
      backgroundColor: KiltoColors.bg,
      body: SafeArea(
        child: kDemoMode ? _buildDemo() : _buildReal(),
      ),
    );
  }

  // ── Real API ────────────────────────────────────────────────────────
  Widget _buildReal() {
    final async = ref.watch(profileProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => KiltoEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'No se pudo cargar el perfil',
        subtitle: e.toString(),
        actionLabel: 'Reintentar',
        onAction: () => ref.invalidate(profileProvider),
      ),
      data: (profile) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(profileProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _Header(profile: profile.personal),
            const SizedBox(height: 28),
            const KiltoSectionHeader('Información personal'),
            _personalCard(profile.personal),
            const SizedBox(height: 20),
            const KiltoSectionHeader('Información médica'),
            _medicalCard(profile.medical),
            const SizedBox(height: 20),
            const KiltoSectionHeader('Preferencias de notificaciones'),
            _notificationsCard(),
            const SizedBox(height: 24),
            _accountActions(),
          ],
        ),
      ),
    );
  }

  Widget _personalCard(PersonalInfo p) {
    return KiltoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _editHeader('Datos personales', () => _editPersonal(p)),
          const Divider(height: 1, color: KiltoColors.borderLight),
          _row('Fecha de nacimiento', p.dateOfBirth ?? '—'),
          _row('CI', p.nationalId ?? '—'),
          _row('Teléfono', p.phone ?? '—'),
          _row('Dirección', p.address ?? '—'),
          _row('Ciudad', p.city ?? '—', last: true),
        ],
      ),
    );
  }

  Widget _medicalCard(MedicalInfo? m) {
    return KiltoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _editHeader('Salud', () => _editMedical(m)),
          const Divider(height: 1, color: KiltoColors.borderLight),
          _row('Tipo de sangre', m?.bloodType ?? '—'),
          _row('Alergias', m?.allergies ?? 'Ninguna'),
          _row('Medicamentos', m?.medications ?? 'Ninguno'),
          _row('Condiciones', m?.conditions ?? 'Ninguna'),
          _row('Contacto emergencia', m?.emergencyContactName ?? '—'),
          _row('Teléfono emergencia', m?.emergencyContactPhone ?? '—',
              last: true),
        ],
      ),
    );
  }

  // ── Demo path (just for offline preview) ────────────────────────────
  Widget _buildDemo() {
    final p = DemoData.profile['personal'] as Map<String, dynamic>;
    final m = DemoData.profile['medical'] as Map<String, dynamic>;
    final personal = PersonalInfo(
      name: DemoData.user['name'] as String,
      firstName: (DemoData.user['name'] as String).split(' ').first,
      email: DemoData.user['email'] as String?,
      phone: DemoData.user['phone'] as String?,
      dateOfBirth: p['date_of_birth'] as String?,
      nationalId: p['national_id'] as String?,
      address: p['address'] as String?,
      city: p['city'] as String?,
    );
    final medical = MedicalInfo(
      bloodType: m['blood_type'] as String?,
      allergies: m['allergies'] as String?,
      medications: m['medications'] as String?,
      conditions: m['conditions'] as String?,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _Header(profile: personal),
        const SizedBox(height: 28),
        const KiltoSectionHeader('Información personal'),
        _personalCard(personal),
        const SizedBox(height: 20),
        const KiltoSectionHeader('Información médica'),
        _medicalCard(medical),
        const SizedBox(height: 20),
        const KiltoSectionHeader('Preferencias de notificaciones'),
        _notificationsCard(),
        const SizedBox(height: 24),
        _accountActions(),
      ],
    );
  }

  // ── Shared rows / cards ────────────────────────────────────────────
  Widget _editHeader(String title, VoidCallback onEdit) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          children: [
            Expanded(child: KiltoText.strong(title, size: 13)),
            TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('Editar'),
              style: TextButton.styleFrom(
                foregroundColor: KiltoColors.zinc950,
                textStyle: const TextStyle(
                  fontFamily: KiltoFonts.familyHeading,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _row(String label, String value, {bool last = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 140, child: KiltoText.label(label)),
              Expanded(
                child: KiltoText.body(value,
                    align: TextAlign.end, color: KiltoColors.zinc950),
              ),
            ],
          ),
        ),
        if (!last)
          const Divider(height: 1, color: KiltoColors.borderLight),
      ],
    );
  }

  Widget _notificationsCard() {
    return KiltoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _toggleRow('Recordatorios de citas', _appointmentReminders,
              (v) => setState(() => _appointmentReminders = v)),
          const Divider(height: 1, color: KiltoColors.borderLight),
          _toggleRow('Promociones', _promotions,
              (v) => setState(() => _promotions = v)),
          const Divider(height: 1, color: KiltoColors.borderLight),
          _toggleRow('Nuevos documentos', _newDocuments,
              (v) => setState(() => _newDocuments = v),
              last: true),
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged,
      {bool last = false}) {
    final accent =
        Theme.of(context).extension<ClinicAccentExtension>()?.accent ??
            KiltoColors.brandPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: KiltoText.body(label, color: KiltoColors.zinc950)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: accent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _accountActions() {
    final showSwitch = kCentralAuth && !kDemoMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSwitch) ...[
          OutlinedButton.icon(
            onPressed: _onSwitchClinic,
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: const Text('Cambiar de clínica'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontWeight: FontWeight.w700,
                fontSize: 13,
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
          icon: const Icon(Icons.logout_rounded, size: 16),
          label: const Text('Cerrar sesión de Kilto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: KiltoColors.errorLight,
            foregroundColor: KiltoColors.error,
            iconColor: KiltoColors.error,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KiltoRadii.medium),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onSwitchClinic() async {
    await ref.read(tenantSessionProvider.notifier).leave();
    if (!mounted) return;
    context.go('/clinics');
  }

  // ── Edit sheets ────────────────────────────────────────────────────
  Future<void> _editPersonal(PersonalInfo p) async {
    final updated = await showModalBottomSheet<_PersonalDraft>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KiltoRadii.xlarge)),
      ),
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
      messenger
          .showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _editMedical(MedicalInfo? m) async {
    final updated = await showModalBottomSheet<_MedicalDraft>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KiltoRadii.xlarge)),
      ),
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
}

class _Header extends StatelessWidget {
  final PersonalInfo profile;
  const _Header({required this.profile});

  String get _initials {
    final parts =
        profile.name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context).extension<ClinicAccentExtension>()?.accent ??
            KiltoColors.brandPrimary;
    final fg = accent.computeLuminance() > 0.55 ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent,
                  Color.alphaBlend(
                      Colors.white.withValues(alpha: 0.14), accent),
                ],
              ),
              borderRadius: BorderRadius.circular(KiltoRadii.large),
              boxShadow: KiltoShadows.hero(accent),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ),
          const SizedBox(height: 14),
          KiltoText.h2(profile.name.isEmpty ? 'Mi perfil' : profile.name,
              align: TextAlign.center),
          if (profile.email != null && profile.email!.isNotEmpty) ...[
            const SizedBox(height: 4),
            KiltoText.body(profile.email!, color: KiltoColors.zinc500),
          ],
        ],
      ),
    );
  }
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
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: KiltoColors.zinc300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            KiltoText.h3('Editar información personal'),
            const SizedBox(height: 16),
            _field(_firstName, 'NOMBRE'),
            _field(_lastName, 'APELLIDO'),
            _field(_phone, 'TELÉFONO', keyboardType: TextInputType.phone),
            _field(_dob, 'FECHA DE NACIMIENTO (YYYY-MM-DD)'),
            _field(_ci, 'CI'),
            _field(_address, 'DIRECCIÓN'),
            _field(_city, 'CIUDAD'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KiltoText.eyebrow(label),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: KiltoFonts.familyBody,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: KiltoColors.zinc950,
            ),
          ),
        ],
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
  late final _emergencyPhone = TextEditingController(
      text: widget.initial?.emergencyContactPhone ?? '');

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
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: KiltoColors.zinc300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            KiltoText.h3('Editar información médica'),
            const SizedBox(height: 16),
            _field(_blood, 'TIPO DE SANGRE'),
            _field(_allergies, 'ALERGIAS', maxLines: 2),
            _field(_meds, 'MEDICAMENTOS', maxLines: 2),
            _field(_conditions, 'CONDICIONES', maxLines: 2),
            _field(_emergencyName, 'CONTACTO DE EMERGENCIA'),
            _field(_emergencyPhone, 'TEL. EMERGENCIA',
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
                        emergencyContactName:
                            _nullIfEmpty(_emergencyName.text),
                        emergencyContactPhone:
                            _nullIfEmpty(_emergencyPhone.text),
                      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KiltoText.eyebrow(label),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontFamily: KiltoFonts.familyBody,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: KiltoColors.zinc950,
            ),
          ),
        ],
      ),
    );
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();
}
