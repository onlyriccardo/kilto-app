import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_data.dart';
import '../../subscreens/patient_detail_screen.dart';

class ClinicPatientsScreen extends StatefulWidget {
  const ClinicPatientsScreen({super.key});

  @override
  State<ClinicPatientsScreen> createState() => _ClinicPatientsScreenState();
}

class _ClinicPatientsScreenState extends State<ClinicPatientsScreen> {
  String _searchQuery = '';
  String _activeFilter = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  static const _filters = ['Todos', 'Activos', 'Inactivos', 'Con deuda'];

  List<Map<String, dynamic>> get _filteredPatients {
    var patients = DemoData.patients.toList();

    // Search filter
    if (_searchQuery.isNotEmpty) {
      patients = patients.where((p) {
        final name = (p['name'] as String).toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Status filter
    switch (_activeFilter) {
      case 'Activos':
        patients = patients.where((p) => p['status'] == 'active').toList();
        break;
      case 'Inactivos':
        patients = patients.where((p) => p['status'] == 'inactive').toList();
        break;
      case 'Con deuda':
        patients = patients.where((p) {
          final balance = p['balance'] as String;
          return balance != '0 Bs';
        }).toList();
        break;
    }

    return patients;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPatients;

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pacientes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: KiltoColors.navy,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddPatientSheet(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: KiltoColors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: KiltoColors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar paciente...',
                  hintStyle: const TextStyle(color: KiltoColors.greyText, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: KiltoColors.greyText),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    borderSide: const BorderSide(color: KiltoColors.teal, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _filters.map((filter) {
                  final isActive = _activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? KiltoColors.teal : KiltoColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? KiltoColors.teal : KiltoColors.greyMid,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? KiltoColors.white : KiltoColors.navy,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${filtered.length} pacientes',
                style: const TextStyle(
                  fontSize: 13,
                  color: KiltoColors.greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Patient list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final patient = filtered[index];
                  return _buildPatientCard(context, patient);
                },
              ),
            ),
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
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Nuevo Paciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paciente agregado'), backgroundColor: Color(0xFF2EC4B6)),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: KiltoColors.teal, foregroundColor: KiltoColors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Map<String, dynamic> patient) {
    final status = patient['status'] as String;
    final balance = patient['balance'] as String;
    final hasDebt = balance != '0 Bs';

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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(patient: patient),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KiltoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KiltoColors.greyMid),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: KiltoColors.navy,
              child: Text(
                patient['initials'] as String,
                style: const TextStyle(
                  color: KiltoColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
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
                          patient['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: KiltoColors.navy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 12, color: KiltoColors.greyText),
                      const SizedBox(width: 4),
                      Text(
                        patient['phone'] as String,
                        style: const TextStyle(fontSize: 11, color: KiltoColors.greyText),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today, size: 12, color: KiltoColors.greyText),
                      const SizedBox(width: 4),
                      Text(
                        '\u00dalt. visita: ${patient['lastVisit']}',
                        style: const TextStyle(fontSize: 11, color: KiltoColors.greyText),
                      ),
                    ],
                  ),
                  if (hasDebt) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Saldo: $balance',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KiltoColors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: KiltoColors.greyText, size: 20),
          ],
        ),
      ),
    );
  }
}
