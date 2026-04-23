/// Thin service layer over /api/v1/clinic/* endpoints (staff-facing).
///
/// These assume the user is already inside a clinic and their tenant-session
/// token was minted from a staff (TeamMember) account. Data is returned as
/// permissive Map<String, dynamic> / List<Map> to keep the screens flexible;
/// strongly-typed models can be added later if needed.

import '../api_client.dart';

/// Dashboard payload shape:
/// {
///   staff: { name, initials, email },
///   kpis:  { appointments_today, appointments_completed_today, active_patients,
///            new_patients_month, unread_messages, urgent_messages,
///            revenue_month, revenue_month_delta_pct },
///   in_progress: <booking | null>,
///   upcoming_today: [<booking>],
///   recent_activity: [],
/// }
class ClinicDashboardService {
  final ApiClient api;
  ClinicDashboardService(this.api);

  Future<Map<String, dynamic>> fetch() async {
    final r = await api.get('/v1/clinic/dashboard');
    return (r.data as Map).cast<String, dynamic>();
  }
}

class ClinicAgendaService {
  final ApiClient api;
  ClinicAgendaService(this.api);

  /// [date] = YYYY-MM-DD. If null, backend defaults to today.
  Future<Map<String, dynamic>> byDate({String? date}) async {
    final r = await api.get(
      '/v1/clinic/appointments',
      queryParameters: {if (date != null) 'date': date},
    );
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateStatus(int id, String status) async {
    final r = await api.put(
      '/v1/clinic/appointments/$id/status',
      data: {'status': status},
    );
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> create({
    required int contactId,
    required String scheduledAt, // ISO 8601 or YYYY-MM-DD HH:mm
    int? durationMinutes,
    int? coachId,
    String? notes,
  }) async {
    final r = await api.post('/v1/clinic/appointments', data: {
      'contact_id': contactId,
      'scheduled_at': scheduledAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (coachId != null) 'coach_id': coachId,
      if (notes != null) 'notes': notes,
    });
    return (r.data as Map).cast<String, dynamic>();
  }
}

class ClinicPatientsService {
  final ApiClient api;
  ClinicPatientsService(this.api);

  /// [filter] = all | active | inactive | overdue; [query] = search string.
  Future<List<Map<String, dynamic>>> list({String? filter, String? query}) async {
    final r = await api.get('/v1/clinic/patients', queryParameters: {
      if (filter != null && filter != 'all') 'filter': filter,
      if (query != null && query.isNotEmpty) 'q': query,
    });
    final data = (r.data as Map).cast<String, dynamic>();
    return ((data['patients'] as List?) ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  Future<Map<String, dynamic>> show(int id) async {
    final r = await api.get('/v1/clinic/patients/$id');
    return (r.data as Map).cast<String, dynamic>();
  }

  /// Create a new patient (Contact). Throws on 409 duplicate; the caller
  /// can inspect the DioException's response to read the dup's patient_id.
  Future<Map<String, dynamic>> create({
    required String firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dateOfBirth, // YYYY-MM-DD
    String? nationalId,
    String? address,
    String? city,
  }) async {
    final r = await api.post('/v1/clinic/patients', data: {
      'first_name': firstName,
      if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) 'date_of_birth': dateOfBirth,
      if (nationalId != null && nationalId.isNotEmpty) 'national_id': nationalId,
      if (address != null && address.isNotEmpty) 'address': address,
      if (city != null && city.isNotEmpty) 'city': city,
    });
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> addTreatment({
    required int patientId,
    required int toothNumber,
    required String treatmentCode,
    String? description,
    List<String>? surfaces,
    String? performedAt, // YYYY-MM-DD
  }) async {
    final r = await api.post('/v1/clinic/patients/$patientId/treatments', data: {
      'tooth_number': toothNumber,
      'treatment_code': treatmentCode,
      if (description != null) 'description': description,
      if (surfaces != null) 'surfaces': surfaces,
      if (performedAt != null) 'performed_at': performedAt,
    });
    return (r.data as Map).cast<String, dynamic>();
  }
}

class ClinicMessagingService {
  final ApiClient api;
  ClinicMessagingService(this.api);

  Future<List<Map<String, dynamic>>> conversations() async {
    final r = await api.get('/v1/clinic/conversations');
    final data = (r.data as Map).cast<String, dynamic>();
    return ((data['conversations'] as List?) ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  Future<Map<String, dynamic>> messages(int conversationId) async {
    final r = await api.get('/v1/clinic/conversations/$conversationId/messages');
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> send(int conversationId, String content) async {
    final r = await api.post(
      '/v1/clinic/conversations/$conversationId/messages',
      data: {'content': content},
    );
    return (r.data as Map).cast<String, dynamic>();
  }
}

class ClinicDirectoryService {
  final ApiClient api;
  ClinicDirectoryService(this.api);

  Future<List<Map<String, dynamic>>> team() async {
    final r = await api.get('/v1/clinic/team');
    final data = (r.data as Map).cast<String, dynamic>();
    return ((data['team'] as List?) ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  Future<List<Map<String, dynamic>>> services() async {
    final r = await api.get('/v1/clinic/services');
    final data = (r.data as Map).cast<String, dynamic>();
    return ((data['services'] as List?) ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  Future<Map<String, dynamic>> settings() async {
    final r = await api.get('/v1/clinic/settings');
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> finances() async {
    final r = await api.get('/v1/clinic/finances');
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> campaigns() async {
    final r = await api.get('/v1/clinic/campaigns');
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> notifications() async {
    final r = await api.get('/v1/clinic/notifications');
    final data = (r.data as Map).cast<String, dynamic>();
    return ((data['notifications'] as List?) ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }
}
