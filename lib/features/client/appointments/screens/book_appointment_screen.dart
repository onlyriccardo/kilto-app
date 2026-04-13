import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _currentStep = 0;
  int? _selectedServiceIndex;
  int? _selectedDoctorIndex;
  int _selectedDateIndex = 0;
  int? _selectedTimeIndex;
  final _notesController = TextEditingController();

  static const _serviceIcons = [
    Icons.clean_hands,
    Icons.medical_services_outlined,
    Icons.auto_fix_high,
    Icons.wb_sunny_outlined,
    Icons.healing,
    Icons.camera_alt_outlined,
    Icons.build_outlined,
    Icons.biotech,
    Icons.warning_amber_rounded,
  ];

  List<_ServiceData> get _services => kDemoMode
      ? DemoData.services.asMap().entries.map((e) => _ServiceData(
            name: e.value['name'] as String,
            icon: e.key < _serviceIcons.length ? _serviceIcons[e.key] : Icons.medical_services_outlined,
            duration: e.value['duration'] as String,
            price: e.value['price'] as String,
          )).toList()
      : [
          _ServiceData(name: 'Limpieza dental', icon: Icons.clean_hands, duration: '45 min', price: 'Bs 150'),
          _ServiceData(name: 'Ortodoncia', icon: Icons.auto_fix_high, duration: '30 min', price: 'Bs 200'),
          _ServiceData(name: 'Extracción', icon: Icons.healing, duration: '60 min', price: 'Bs 300'),
          _ServiceData(name: 'Blanqueamiento', icon: Icons.wb_sunny_outlined, duration: '90 min', price: 'Bs 500'),
          _ServiceData(name: 'Control general', icon: Icons.medical_services_outlined, duration: '20 min', price: 'Bs 100'),
          _ServiceData(name: 'Endodoncia', icon: Icons.biotech, duration: '90 min', price: 'Bs 800'),
        ];

  List<_DoctorData> get _doctors => kDemoMode
      ? DemoData.doctors.map((d) => _DoctorData(
            name: d['name'] as String,
            specialty: d['specialty'] as String,
            availability: d['nextAvail'] as String,
          )).toList()
      : [
          _DoctorData(name: 'Dr. María López', specialty: 'Odontología general', availability: 'Lun-Vie'),
          _DoctorData(name: 'Dr. Carlos Mendoza', specialty: 'Ortodoncia', availability: 'Lun, Mié, Vie'),
          _DoctorData(name: 'Dr. Ana Rojas', specialty: 'Cirugía oral', availability: 'Mar, Jue'),
        ];

  final _dates = [
    _DateData(dayName: 'Lun', dayNum: '14', month: 'Abr'),
    _DateData(dayName: 'Mar', dayNum: '15', month: 'Abr'),
    _DateData(dayName: 'Mié', dayNum: '16', month: 'Abr'),
    _DateData(dayName: 'Jue', dayNum: '17', month: 'Abr'),
    _DateData(dayName: 'Vie', dayNum: '18', month: 'Abr'),
    _DateData(dayName: 'Lun', dayNum: '21', month: 'Abr'),
    _DateData(dayName: 'Mar', dayNum: '22', month: 'Abr'),
  ];

  List<String> get _times => kDemoMode
      ? DemoData.availableTimeSlots
      : [
          '08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM',
          '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
          '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
          '04:00 PM', '04:30 PM',
        ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go('/client/appointments');
      }
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedServiceIndex != null;
      case 1:
        return _selectedDoctorIndex != null;
      case 2:
        return _selectedTimeIndex != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: _prevStep,
        ),
        title: const Text('Agendar cita'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Progress bar
          _buildProgressBar(),
          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
          // Bottom button
          if (_currentStep < 3)
            _buildBottomButton()
          else
            _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep
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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildServiceStep();
      case 1:
        return _buildDoctorStep();
      case 2:
        return _buildDateTimeStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildServiceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona un servicio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: KiltoColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Elige el tratamiento que necesitas',
          style: TextStyle(fontSize: 13, color: KiltoColors.greyText),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.78,
          ),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final service = _services[index];
            final isSelected = _selectedServiceIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedServiceIndex = index),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? KiltoColors.teal.withOpacity(0.08)
                      : KiltoColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? KiltoColors.teal : KiltoColors.greyMid,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      service.icon,
                      size: 28,
                      color: isSelected
                          ? KiltoColors.teal
                          : KiltoColors.navy.withOpacity(0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      service.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? KiltoColors.teal : KiltoColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.duration,
                      style: const TextStyle(
                        fontSize: 10,
                        color: KiltoColors.greyText,
                      ),
                    ),
                    Text(
                      service.price,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? KiltoColors.teal : KiltoColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDoctorStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Elige tu profesional',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: KiltoColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Selecciona quién te atenderá',
          style: TextStyle(fontSize: 13, color: KiltoColors.greyText),
        ),
        const SizedBox(height: 20),
        ...List.generate(_doctors.length, (index) {
          final doctor = _doctors[index];
          final isSelected = _selectedDoctorIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDoctorIndex = index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? KiltoColors.teal.withOpacity(0.08)
                    : KiltoColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? KiltoColors.teal : KiltoColors.greyMid,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isSelected
                        ? KiltoColors.teal
                        : KiltoColors.navy.withOpacity(0.1),
                    child: Text(
                      doctor.name.split(' ').last[0],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? KiltoColors.white : KiltoColors.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: KiltoColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor.specialty,
                          style: const TextStyle(
                            fontSize: 12,
                            color: KiltoColors.greyText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 12,
                              color: KiltoColors.teal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctor.availability,
                              style: const TextStyle(
                                fontSize: 11,
                                color: KiltoColors.teal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: KiltoColors.teal, size: 24),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha y hora',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: KiltoColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Elige cuándo quieres tu cita',
          style: TextStyle(fontSize: 13, color: KiltoColors.greyText),
        ),
        const SizedBox(height: 20),
        // Date horizontal scroller
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = _selectedDateIndex == index;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDateIndex = index;
                  _selectedTimeIndex = null;
                }),
                child: Container(
                  width: 58,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? KiltoColors.teal : KiltoColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          isSelected ? KiltoColors.teal : KiltoColors.greyMid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.dayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? KiltoColors.white.withOpacity(0.8)
                              : KiltoColors.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date.dayNum,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? KiltoColors.white
                              : KiltoColors.navy,
                        ),
                      ),
                      Text(
                        date.month,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? KiltoColors.white.withOpacity(0.8)
                              : KiltoColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Horarios disponibles',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: KiltoColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        // Time slot grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: _times.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedTimeIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeIndex = index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? KiltoColors.teal : KiltoColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? KiltoColors.teal : KiltoColors.greyMid,
                  ),
                ),
                child: Center(
                  child: Text(
                    _times[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? KiltoColors.white : KiltoColors.navy,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    final service = _selectedServiceIndex != null
        ? _services[_selectedServiceIndex!]
        : null;
    final doctor = _selectedDoctorIndex != null
        ? _doctors[_selectedDoctorIndex!]
        : null;
    final date =
        _selectedDateIndex < _dates.length ? _dates[_selectedDateIndex] : null;
    final time = _selectedTimeIndex != null ? _times[_selectedTimeIndex!] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirmar cita',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: KiltoColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Revisa los detalles de tu cita',
          style: TextStyle(fontSize: 13, color: KiltoColors.greyText),
        ),
        const SizedBox(height: 20),
        // Summary card
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
              _summaryRow(
                  Icons.medical_services_outlined, 'Servicio', service?.name ?? '-'),
              const Divider(height: 24),
              _summaryRow(Icons.person_outline, 'Profesional', doctor?.name ?? '-'),
              const Divider(height: 24),
              _summaryRow(Icons.calendar_today,
                  'Fecha', date != null ? '${date.dayName} ${date.dayNum} ${date.month}' : '-'),
              const Divider(height: 24),
              _summaryRow(Icons.access_time, 'Hora', time ?? '-'),
              const Divider(height: 24),
              _summaryRow(Icons.timer_outlined, 'Duración', service?.duration ?? '-'),
              const Divider(height: 24),
              _summaryRow(Icons.attach_money, 'Precio', service?.price ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Notes
        const Text(
          'Notas adicionales (opcional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: KiltoColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Agrega alguna nota para tu profesional...',
            hintStyle: const TextStyle(
              fontSize: 13,
              color: KiltoColors.greyText,
            ),
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
      ],
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: KiltoColors.teal),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: KiltoColors.greyText,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: KiltoColors.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
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
          onPressed: _canProceed ? _nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: KiltoColors.teal,
            foregroundColor: KiltoColors.white,
            disabledBackgroundColor: KiltoColors.greyMid,
            disabledForegroundColor: KiltoColors.greyText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Cita agendada exitosamente'),
                backgroundColor: KiltoColors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            context.go('/client/appointments');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: KiltoColors.teal,
            foregroundColor: KiltoColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Confirmar cita',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _ServiceData {
  final String name;
  final IconData icon;
  final String duration;
  final String price;

  _ServiceData({
    required this.name,
    required this.icon,
    required this.duration,
    required this.price,
  });
}

class _DoctorData {
  final String name;
  final String specialty;
  final String availability;

  _DoctorData({
    required this.name,
    required this.specialty,
    required this.availability,
  });
}

class _DateData {
  final String dayName;
  final String dayNum;
  final String month;

  _DateData({
    required this.dayName,
    required this.dayNum,
    required this.month,
  });
}
