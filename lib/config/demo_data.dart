/// All hardcoded mockup data for demo mode.
/// Modeled after the kilto-app.jsx mockup — dental clinic in Santa Cruz, Bolivia.

class DemoData {
  // ── Tenant / Business ──
  static const tenant = {
    'id': 1,
    'name': 'Clínica Dental Sonrisa',
    'slug': 'clinica-sonrisa',
    'logo_url': null,
    'active_modules': ['dental'],
  };

  // ── Current User ──
  static const user = {
    'id': 1,
    'name': 'María López',
    'first_name': 'María',
    'last_name': 'López',
    'email': 'maria.lopez@email.com',
    'phone': '+591 76543210',
    'type': 'client',
    'avatar_url': null,
    'initials': 'ML',
  };

  // ── Staff / Doctors ──
  static const List<Map<String, dynamic>> doctors = [
    {'id': 1, 'name': 'Dr. Carlos Rodríguez', 'specialty': 'Odontología General', 'initials': 'CR', 'nextAvail': 'Hoy, 14:00'},
    {'id': 2, 'name': 'Dra. Ana Gutiérrez', 'specialty': 'Ortodoncia', 'initials': 'AG', 'nextAvail': 'Mañana, 09:00'},
    {'id': 3, 'name': 'Dr. Luis Fernández', 'specialty': 'Endodoncia', 'initials': 'LF', 'nextAvail': 'Mié, 11:00'},
    {'id': 4, 'name': 'Dra. Sofía Mamani', 'specialty': 'Odontopediatría', 'initials': 'SM', 'nextAvail': 'Jue, 10:00'},
  ];

  // ── Services ──
  static const List<Map<String, dynamic>> services = [
    {'id': 1, 'name': 'Limpieza dental', 'icon': '🦷', 'duration': '45 min', 'price': '150 Bs'},
    {'id': 2, 'name': 'Consulta general', 'icon': '👨‍⚕️', 'duration': '30 min', 'price': '100 Bs'},
    {'id': 3, 'name': 'Ortodoncia', 'icon': '🔧', 'duration': '40 min', 'price': '200 Bs'},
    {'id': 4, 'name': 'Blanqueamiento', 'icon': '✨', 'duration': '60 min', 'price': '350 Bs'},
    {'id': 5, 'name': 'Extracción', 'icon': '🏥', 'duration': '30 min', 'price': '180 Bs'},
    {'id': 6, 'name': 'Radiografía', 'icon': '📷', 'duration': '15 min', 'price': '80 Bs'},
    {'id': 7, 'name': 'Implante dental', 'icon': '🔩', 'duration': '90 min', 'price': '2500 Bs'},
    {'id': 8, 'name': 'Endodoncia', 'icon': '💉', 'duration': '60 min', 'price': '450 Bs'},
    {'id': 9, 'name': 'Urgencia', 'icon': '🚨', 'duration': 'Variable', 'price': '200 Bs'},
  ];

  // ── Appointments ──
  static const List<Map<String, dynamic>> upcomingAppointments = [
    {
      'id': 1,
      'date': 'Lunes 14 Abril',
      'time': '10:00 - 10:45',
      'service': 'Ortodoncia - Control mensual',
      'doctor': 'Dra. Ana Gutiérrez',
      'doctorInitials': 'AG',
      'status': 'confirmed',
    },
    {
      'id': 2,
      'date': 'Miércoles 23 Abril',
      'time': '15:00 - 15:30',
      'service': 'Limpieza dental',
      'doctor': 'Dr. Carlos Rodríguez',
      'doctorInitials': 'CR',
      'status': 'pending',
    },
    {
      'id': 3,
      'date': 'Viernes 9 Mayo',
      'time': '09:00 - 09:30',
      'service': 'Consulta general',
      'doctor': 'Dr. Carlos Rodríguez',
      'doctorInitials': 'CR',
      'status': 'pending',
    },
  ];

  static const List<Map<String, dynamic>> pastAppointments = [
    {
      'id': 4,
      'date': 'Viernes 28 Marzo',
      'time': '11:00 - 11:45',
      'service': 'Ortodoncia - Ajuste',
      'doctor': 'Dra. Ana Gutiérrez',
      'doctorInitials': 'AG',
      'status': 'completed',
    },
    {
      'id': 5,
      'date': 'Lunes 10 Febrero',
      'time': '14:00 - 14:30',
      'service': 'Radiografía panorámica',
      'doctor': 'Dr. Carlos Rodríguez',
      'doctorInitials': 'CR',
      'status': 'completed',
    },
    {
      'id': 6,
      'date': 'Jueves 16 Enero',
      'time': '10:00 - 10:45',
      'service': 'Limpieza dental',
      'doctor': 'Dr. Carlos Rodríguez',
      'doctorInitials': 'CR',
      'status': 'completed',
    },
  ];

  // ── Documents ──
  static const List<Map<String, dynamic>> documents = [
    {'id': 1, 'type': 'xray', 'title': 'Radiografía panorámica', 'date': '10 Feb 2026', 'doctor': 'Dr. Rodríguez', 'category': 'Radiografías', 'icon': '📷'},
    {'id': 2, 'type': 'prescription', 'title': 'Receta - Ibuprofeno 400mg', 'date': '28 Mar 2026', 'doctor': 'Dra. Gutiérrez', 'category': 'Recetas', 'icon': '💊'},
    {'id': 3, 'type': 'budget', 'title': 'Presupuesto tratamiento ortodoncia', 'date': '15 Ene 2026', 'doctor': 'Dra. Gutiérrez', 'category': 'Presupuestos', 'icon': '📊'},
    {'id': 4, 'type': 'consent', 'title': 'Consentimiento informado - Extracción', 'date': '20 Dic 2025', 'doctor': 'Dr. Fernández', 'category': 'Consentimientos', 'icon': '📝'},
    {'id': 5, 'type': 'invoice', 'title': 'Factura #2026-0147', 'date': '28 Mar 2026', 'doctor': 'Admin', 'category': 'Facturas', 'icon': '🧾'},
    {'id': 6, 'type': 'xray', 'title': 'Radiografía periapical #14', 'date': '20 Sep 2025', 'doctor': 'Dr. Rodríguez', 'category': 'Radiografías', 'icon': '📷'},
  ];

  // ── Notifications ──
  static const List<Map<String, dynamic>> notifications = [
    {'id': 1, 'icon': '🔔', 'text': 'Recordatorio: Tu cita de mañana a las 10:00 — Limpieza dental con Dr. Rodríguez', 'time': 'Hace 2h', 'unread': true},
    {'id': 2, 'icon': '📄', 'text': 'Nuevo documento: Dr. Rodríguez subió tu radiografía panorámica', 'time': 'Hace 1 día', 'unread': true},
    {'id': 3, 'icon': '💡', 'text': 'Han pasado 6 meses desde tu última limpieza. ¿Agendamos una cita?', 'time': 'Hace 3 días', 'unread': false},
    {'id': 4, 'icon': '🎉', 'text': '¡Feliz cumpleaños María! Tienes 15% de descuento en blanqueamiento este mes', 'time': 'Hace 5 días', 'unread': false},
    {'id': 5, 'icon': '✅', 'text': 'Cita confirmada: Ortodoncia — Lunes 14 Abril, 10:00', 'time': 'Hace 1 sem', 'unread': false},
  ];

  // ── Chat Messages ──
  static const List<Map<String, dynamic>> chatMessages = [
    {'id': 1, 'from': 'clinic', 'text': '¡Hola María! Bienvenida al chat de Clínica Dental Sonrisa. ¿En qué podemos ayudarte?', 'time': '10:30'},
    {'id': 2, 'from': 'patient', 'text': 'Hola, quería consultar si tienen disponibilidad para una limpieza esta semana', 'time': '10:32'},
    {'id': 3, 'from': 'clinic', 'text': '¡Claro! Tenemos disponibilidad el jueves a las 15:00 y el viernes a las 09:00 con el Dr. Rodríguez. ¿Cuál prefieres?', 'time': '10:33'},
    {'id': 4, 'from': 'patient', 'text': 'El viernes a las 9 me queda perfecto', 'time': '10:35'},
    {'id': 5, 'from': 'clinic', 'text': '¡Listo! Te agendo para el viernes 9 de mayo a las 09:00. Te llegará la confirmación por notificación. 😊', 'time': '10:36'},
  ];

  // ── Profile ──
  static const profile = {
    'personal': {
      'name': 'María López',
      'first_name': 'María',
      'last_name': 'López',
      'email': 'maria.lopez@email.com',
      'phone': '+591 76543210',
      'date_of_birth': '15 Julio 1992',
      'national_id': '7654321 SC',
      'address': 'Av. San Martín #456',
      'city': 'Santa Cruz de la Sierra',
    },
    'medical': {
      'blood_type': 'O+',
      'allergies': 'Penicilina',
      'medications': 'Ninguno',
      'conditions': 'Ninguna',
    },
  };

  // ── Odontogram (Dental) ──
  static const Map<int, Map<String, dynamic>> toothData = {
    11: {'name': 'Incisivo central superior derecho', 'status': 'healthy'},
    12: {'name': 'Incisivo lateral superior derecho', 'status': 'healthy'},
    13: {'name': 'Canino superior derecho', 'status': 'healthy'},
    14: {'name': 'Primer premolar superior derecho', 'status': 'treated', 'treatments': [
      {'date': '15 Mar 2026', 'desc': 'Empaste composite', 'doctor': 'Dr. Rodríguez'},
      {'date': '20 Sep 2025', 'desc': 'Radiografía periapical', 'doctor': 'Dr. Rodríguez'},
    ]},
    15: {'name': 'Segundo premolar superior derecho', 'status': 'healthy'},
    16: {'name': 'Primer molar superior derecho', 'status': 'attention', 'treatments': [
      {'date': '28 Mar 2026', 'desc': 'Diagnóstico: caries oclusal', 'doctor': 'Dra. Gutiérrez'},
    ]},
    17: {'name': 'Segundo molar superior derecho', 'status': 'healthy'},
    18: {'name': 'Tercer molar superior derecho', 'status': 'extracted'},
    21: {'name': 'Incisivo central superior izquierdo', 'status': 'healthy'},
    22: {'name': 'Incisivo lateral superior izquierdo', 'status': 'healthy'},
    23: {'name': 'Canino superior izquierdo', 'status': 'treated', 'treatments': [
      {'date': '10 Ene 2026', 'desc': 'Carilla dental', 'doctor': 'Dr. Rodríguez'},
    ]},
    24: {'name': 'Primer premolar superior izquierdo', 'status': 'healthy'},
    25: {'name': 'Segundo premolar superior izquierdo', 'status': 'healthy'},
    26: {'name': 'Primer molar superior izquierdo', 'status': 'healthy'},
    27: {'name': 'Segundo molar superior izquierdo', 'status': 'treated', 'treatments': [
      {'date': '05 Nov 2025', 'desc': 'Empaste amalgama', 'doctor': 'Dr. Fernández'},
    ]},
    28: {'name': 'Tercer molar superior izquierdo', 'status': 'healthy'},
    31: {'name': 'Incisivo central inferior izquierdo', 'status': 'healthy'},
    32: {'name': 'Incisivo lateral inferior izquierdo', 'status': 'healthy'},
    33: {'name': 'Canino inferior izquierdo', 'status': 'healthy'},
    34: {'name': 'Primer premolar inferior izquierdo', 'status': 'healthy'},
    35: {'name': 'Segundo premolar inferior izquierdo', 'status': 'healthy'},
    36: {'name': 'Primer molar inferior izquierdo', 'status': 'treated', 'treatments': [
      {'date': '12 Ago 2025', 'desc': 'Endodoncia', 'doctor': 'Dr. Fernández'},
      {'date': '15 Ago 2025', 'desc': 'Corona de porcelana', 'doctor': 'Dr. Fernández'},
    ]},
    37: {'name': 'Segundo molar inferior izquierdo', 'status': 'healthy'},
    38: {'name': 'Tercer molar inferior izquierdo', 'status': 'extracted'},
    41: {'name': 'Incisivo central inferior derecho', 'status': 'healthy'},
    42: {'name': 'Incisivo lateral inferior derecho', 'status': 'healthy'},
    43: {'name': 'Canino inferior derecho', 'status': 'healthy'},
    44: {'name': 'Primer premolar inferior derecho', 'status': 'healthy'},
    45: {'name': 'Segundo premolar inferior derecho', 'status': 'attention', 'treatments': [
      {'date': '28 Mar 2026', 'desc': 'Diagnóstico: fisura en esmalte', 'doctor': 'Dra. Gutiérrez'},
    ]},
    46: {'name': 'Primer molar inferior derecho', 'status': 'healthy'},
    47: {'name': 'Segundo molar inferior derecho', 'status': 'healthy'},
    48: {'name': 'Tercer molar inferior derecho', 'status': 'healthy'},
  };

  // ── Time slots ──
  static const List<String> availableTimeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '14:00', '14:30', '15:00', '15:30', '16:00',
  ];
  static const List<String> unavailableTimeSlots = ['10:00', '11:00', '14:30'];

  // ── Health tip ──
  static const healthTip = '¿Sabías que deberías cambiar tu cepillo de dientes cada 3 meses? Un cepillo desgastado no limpia correctamente.';

  // ══════════════════════════════════════════════
  //  CLINIC / TENANT SIDE (Staff view)
  // ══════════════════════════════════════════════

  static const clinicUser = {
    'name': 'Dr. Carlos Rodríguez',
    'initials': 'CR',
    'role': 'Odontólogo General · Admin',
  };

  static const List<Map<String, dynamic>> patients = [
    {'id': 1, 'name': 'María López', 'initials': 'ML', 'phone': '+591 76543210', 'email': 'maria.lopez@email.com', 'dob': '15/07/1992', 'blood': 'O+', 'allergies': 'Penicilina', 'lastVisit': '28 Mar', 'nextAppt': '14 Abr · 10:00', 'balance': '0 Bs', 'status': 'active', 'treatments': 12},
    {'id': 2, 'name': 'Carlos Mendoza', 'initials': 'CM', 'phone': '+591 71234567', 'email': 'carlos.m@email.com', 'dob': '03/11/1985', 'blood': 'A+', 'allergies': 'Ninguna', 'lastVisit': '20 Mar', 'nextAppt': '16 Abr · 09:00', 'balance': '350 Bs', 'status': 'active', 'treatments': 8},
    {'id': 3, 'name': 'Ana Quispe', 'initials': 'AQ', 'phone': '+591 69876543', 'email': 'ana.quispe@email.com', 'dob': '22/03/1998', 'blood': 'B-', 'allergies': 'Látex', 'lastVisit': '15 Mar', 'nextAppt': '—', 'balance': '0 Bs', 'status': 'inactive', 'treatments': 3},
    {'id': 4, 'name': 'Roberto Flores', 'initials': 'RF', 'phone': '+591 77654321', 'email': 'r.flores@email.com', 'dob': '08/01/1978', 'blood': 'AB+', 'allergies': 'Ninguna', 'lastVisit': '10 Abr', 'nextAppt': '24 Abr · 14:00', 'balance': '150 Bs', 'status': 'active', 'treatments': 22},
    {'id': 5, 'name': 'Lucía Vargas', 'initials': 'LV', 'phone': '+591 72345678', 'email': 'lucia.v@email.com', 'dob': '19/09/2001', 'blood': 'O-', 'allergies': 'Sulfonamidas', 'lastVisit': '05 Abr', 'nextAppt': '20 Abr · 15:00', 'balance': '0 Bs', 'status': 'active', 'treatments': 5},
    {'id': 6, 'name': 'Diego Salazar', 'initials': 'DS', 'phone': '+591 73456789', 'email': 'diego.s@email.com', 'dob': '14/06/1990', 'blood': 'A-', 'allergies': 'Ninguna', 'lastVisit': '01 Feb', 'nextAppt': '—', 'balance': '800 Bs', 'status': 'overdue', 'treatments': 15},
    {'id': 7, 'name': 'Valentina Rojas', 'initials': 'VR', 'phone': '+591 74567890', 'email': 'val.rojas@email.com', 'dob': '30/12/1995', 'blood': 'B+', 'allergies': 'Ninguna', 'lastVisit': '12 Abr', 'nextAppt': '14 Abr · 08:00', 'balance': '0 Bs', 'status': 'active', 'treatments': 9},
  ];

  static const List<Map<String, dynamic>> todayAppointments = [
    {'id': 1, 'time': '08:00', 'end': '08:45', 'patientIdx': 6, 'service': 'Ortodoncia - Control', 'status': 'completed', 'room': 'Cons. 2'},
    {'id': 2, 'time': '09:00', 'end': '09:30', 'patientIdx': 0, 'service': 'Limpieza dental', 'status': 'completed', 'room': 'Cons. 1'},
    {'id': 3, 'time': '09:30', 'end': '10:15', 'patientIdx': 4, 'service': 'Consulta general', 'status': 'in-progress', 'room': 'Cons. 3'},
    {'id': 4, 'time': '10:00', 'end': '10:45', 'patientIdx': 0, 'service': 'Ortodoncia - Control mensual', 'status': 'confirmed', 'room': 'Cons. 2'},
    {'id': 5, 'time': '11:00', 'end': '11:30', 'patientIdx': 1, 'service': 'Radiografía panorámica', 'status': 'confirmed', 'room': 'Rayos X'},
    {'id': 6, 'time': '14:00', 'end': '14:45', 'patientIdx': 3, 'service': 'Endodoncia', 'status': 'pending', 'room': 'Cons. 1'},
    {'id': 7, 'time': '15:00', 'end': '15:30', 'patientIdx': 1, 'service': 'Consulta general', 'status': 'pending', 'room': 'Cons. 1'},
    {'id': 8, 'time': '16:00', 'end': '17:00', 'patientIdx': 4, 'service': 'Blanqueamiento', 'status': 'pending', 'room': 'Cons. 3'},
  ];

  static const List<Map<String, dynamic>> conversations = [
    {'patientIdx': 4, 'lastMsg': '¿Puedo reagendar mi cita de mañana?', 'time': '09:12', 'unread': 2},
    {'patientIdx': 3, 'lastMsg': '¿Cuánto cuesta el implante?', 'time': 'Ayer', 'unread': 1},
    {'patientIdx': 0, 'lastMsg': 'El viernes a las 9 me queda perfecto', 'time': '10:35', 'unread': 0},
    {'patientIdx': 1, 'lastMsg': 'Gracias doctora, muy amable', 'time': 'Ayer', 'unread': 0},
    {'patientIdx': 6, 'lastMsg': 'Ok, llego en 10 minutos', 'time': '11 Abr', 'unread': 0},
  ];

  static const List<Map<String, dynamic>> campaigns = [
    {'name': 'Blanqueamiento Abril', 'status': 'active', 'sent': 245, 'opened': 182, 'clicked': 67, 'type': 'promo'},
    {'name': 'Recordatorio limpieza 6 meses', 'status': 'active', 'sent': 128, 'opened': 98, 'clicked': 45, 'type': 'reminder'},
    {'name': 'Feliz cumpleaños - Descuento', 'status': 'active', 'sent': 34, 'opened': 28, 'clicked': 12, 'type': 'birthday'},
    {'name': 'Promo Día de la Madre', 'status': 'draft', 'sent': 0, 'opened': 0, 'clicked': 0, 'type': 'promo'},
  ];

  static const List<Map<String, dynamic>> recentActivity = [
    {'icon': '📅', 'text': 'María López confirmó cita del 14 Abr', 'time': '10 min'},
    {'icon': '📄', 'text': 'Radiografía subida — Roberto Flores', 'time': '25 min'},
    {'icon': '💳', 'text': 'Pago recibido: Carlos Mendoza — 200 Bs', 'time': '1h'},
    {'icon': '🆕', 'text': 'Nuevo paciente: Valentina Rojas', 'time': '2h'},
    {'icon': '❌', 'text': 'Ana Quispe canceló cita del 18 Abr', 'time': '3h'},
  ];

  static const List<Map<String, dynamic>> clinicNotifications = [
    {'text': 'Lucía Vargas llegó a la clínica — cita de 09:30', 'time': 'Hace 5 min', 'unread': true, 'icon': '🏥'},
    {'text': 'María López confirmó su cita de mañana 10:00', 'time': 'Hace 10 min', 'unread': true, 'icon': '✅'},
    {'text': 'Nuevo mensaje de Lucía Vargas', 'time': 'Hace 30 min', 'unread': true, 'icon': '💬'},
    {'text': 'Pago recibido: Carlos Mendoza — 200 Bs', 'time': 'Hace 1h', 'unread': false, 'icon': '💳'},
    {'text': 'Ana Quispe canceló su cita del 18 Abr', 'time': 'Hace 3h', 'unread': false, 'icon': '❌'},
    {'text': "Campaña 'Blanqueamiento Abril' — 67 clics", 'time': 'Hace 5h', 'unread': false, 'icon': '📊'},
  ];

  static const List<Map<String, dynamic>> transactions = [
    {'date': '14 Abr', 'patient': 'Roberto Flores', 'service': 'Endodoncia', 'amount': '450 Bs', 'method': 'Tarjeta', 'status': 'Pagado'},
    {'date': '14 Abr', 'patient': 'Valentina Rojas', 'service': 'Ortodoncia', 'amount': '200 Bs', 'method': 'QR', 'status': 'Pagado'},
    {'date': '13 Abr', 'patient': 'Carlos Mendoza', 'service': 'Pago parcial', 'amount': '800 Bs', 'method': 'Transf.', 'status': 'Parcial'},
    {'date': '12 Abr', 'patient': 'Lucía Vargas', 'service': 'Limpieza', 'amount': '150 Bs', 'method': 'Efectivo', 'status': 'Pagado'},
    {'date': '10 Abr', 'patient': 'Diego Salazar', 'service': 'Consulta', 'amount': '100 Bs', 'method': '—', 'status': 'Pendiente'},
  ];

  static const List<Map<String, dynamic>> team = [
    {'name': 'Dr. Carlos Rodríguez', 'role': 'Odontólogo General · Admin', 'initials': 'CR'},
    {'name': 'Dra. Ana Gutiérrez', 'role': 'Ortodoncista', 'initials': 'AG'},
    {'name': 'Dr. Luis Fernández', 'role': 'Endodoncista', 'initials': 'LF'},
    {'name': 'Dra. Sofía Mamani', 'role': 'Odontopediatra', 'initials': 'SM'},
    {'name': 'Karen Torrico', 'role': 'Recepcionista', 'initials': 'KT'},
  ];

  static const List<Map<String, dynamic>> treatmentHistory = [
    {'date': '28 Mar 2026', 'service': 'Ortodoncia - Ajuste', 'doctor': 'Dra. Gutiérrez', 'cost': '200 Bs', 'note': 'Cambio de arco superior'},
    {'date': '10 Feb 2026', 'service': 'Radiografía panorámica', 'doctor': 'Dr. Rodríguez', 'cost': '80 Bs', 'note': 'Control anual'},
    {'date': '16 Ene 2026', 'service': 'Limpieza dental', 'doctor': 'Dr. Rodríguez', 'cost': '150 Bs', 'note': 'Sin complicaciones'},
    {'date': '05 Nov 2025', 'service': 'Empaste #27', 'doctor': 'Dr. Fernández', 'cost': '250 Bs', 'note': 'Amalgama, cara oclusal'},
    {'date': '20 Sep 2025', 'service': 'Radiografía periapical #14', 'doctor': 'Dr. Rodríguez', 'cost': '50 Bs', 'note': 'Pre-evaluación'},
    {'date': '15 Ago 2025', 'service': 'Corona porcelana #36', 'doctor': 'Dr. Fernández', 'cost': '800 Bs', 'note': 'Post endodoncia'},
  ];

  static const clinicSettings = {
    'name': 'Clínica Dental Sonrisa',
    'address': 'Av. Monseñor Rivero #340',
    'city': 'Santa Cruz de la Sierra',
    'phone': '+591 3 3456789',
    'email': 'info@sonrisadental.com',
    'hours': 'L-V 08:00-18:00 · S 09:00-13:00',
  };
}
