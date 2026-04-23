/// Thin service layer over /api/v1/* endpoints.
///
/// Every method returns typed models and throws on error (callers wrap in
/// try/catch or FutureBuilder). The Dio interceptor attaches the tenant-
/// session bearer automatically for any path starting with `/v1/`, so these
/// services assume the user is already inside a clinic.

import '../api_client.dart';
import 'models.dart';

// =======================================================================
// Appointments
// =======================================================================

class AppointmentsResult {
  final List<Appointment> upcoming;
  final List<Appointment> past;

  const AppointmentsResult({required this.upcoming, required this.past});
}

class AppointmentsService {
  final ApiClient api;
  AppointmentsService(this.api);

  Future<AppointmentsResult> list() async {
    final r = await api.get('/v1/appointments');
    final d = r.data as Map<String, dynamic>;
    final up = (d['upcoming'] as List? ?? [])
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
    final past = (d['past'] as List? ?? [])
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
    return AppointmentsResult(upcoming: up, past: past);
  }

  Future<Appointment> book({
    required String serviceName,
    int? staffId,
    required String date, // YYYY-MM-DD
    required String time, // HH:mm
    int? duration,
    String? notes,
  }) async {
    final r = await api.post('/v1/appointments', data: {
      'service_name': serviceName,
      if (staffId != null) 'staff_id': staffId,
      'date': date,
      'time': time,
      if (duration != null) 'duration': duration,
      if (notes != null) 'notes': notes,
    });
    return Appointment.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> confirm(int id) async {
    await api.post('/v1/appointments/$id/confirm');
  }

  Future<void> cancel(int id) async {
    await api.delete('/v1/appointments/$id');
  }

  Future<Appointment> reschedule({
    required int id,
    String? date,
    String? time,
    String? notes,
  }) async {
    final r = await api.put('/v1/appointments/$id', data: {
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (notes != null) 'notes': notes,
    });
    return Appointment.fromJson(r.data as Map<String, dynamic>);
  }
}

// =======================================================================
// Services catalog + staff + availability (used by booking flow)
// =======================================================================

class CatalogService {
  final ApiClient api;
  CatalogService(this.api);

  Future<List<ServiceCatalogItem>> services() async {
    final r = await api.get('/v1/services');
    final list = (r.data as Map<String, dynamic>)['services'] as List? ?? [];
    return list
        .map((e) => ServiceCatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StaffMember>> staff() async {
    final r = await api.get('/v1/staff');
    final list = (r.data as Map<String, dynamic>)['staff'] as List? ?? [];
    return list
        .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns available HH:mm slots for a given ISO date.
  Future<List<String>> availability({
    required String date,
    int? staffId,
  }) async {
    final r = await api.get(
      '/v1/availability',
      queryParameters: {
        'date': date,
        if (staffId != null) 'staff_id': staffId,
      },
    );
    final slots =
        (r.data as Map<String, dynamic>)['slots'] as List? ?? const [];
    return slots.map((e) => e.toString()).toList();
  }
}

// =======================================================================
// Documents
// =======================================================================

class DocumentsService {
  final ApiClient api;
  DocumentsService(this.api);

  Future<List<DocumentItem>> list() async {
    final r = await api.get('/v1/documents');
    final list =
        (r.data as Map<String, dynamic>)['documents'] as List? ?? const [];
    return list
        .map((e) => DocumentItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// =======================================================================
// Notifications
// =======================================================================

class NotificationsService {
  final ApiClient api;
  NotificationsService(this.api);

  Future<List<NotificationItem>> list() async {
    final r = await api.get('/v1/notifications');
    final list =
        (r.data as Map<String, dynamic>)['notifications'] as List? ?? const [];
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(int id) async {
    await api.post('/v1/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await api.post('/v1/notifications/read-all');
  }
}

// =======================================================================
// Dental (Odontogram)
// =======================================================================

class DentalService {
  final ApiClient api;
  DentalService(this.api);

  Future<OdontogramRecord> odontogram() async {
    final r = await api.get('/v1/modules/dental/odontogram');
    return OdontogramRecord.fromJson(r.data as Map<String, dynamic>);
  }
}

// =======================================================================
// Profile
// =======================================================================

class ProfileService {
  final ApiClient api;
  ProfileService(this.api);

  Future<Profile> show() async {
    final r = await api.get('/v1/profile');
    return Profile.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> updatePersonal({
    String? firstName,
    String? lastName,
    String? phone,
    String? dateOfBirth,
    String? nationalId,
    String? address,
    String? city,
  }) async {
    await api.put('/v1/profile', data: {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (nationalId != null) 'national_id': nationalId,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
    });
  }

  Future<void> updateMedical({
    String? bloodType,
    String? allergies,
    String? medications,
    String? conditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    await api.put('/v1/profile/medical', data: {
      if (bloodType != null) 'blood_type': bloodType,
      if (allergies != null) 'allergies': allergies,
      if (medications != null) 'medications': medications,
      if (conditions != null) 'conditions': conditions,
      if (emergencyContactName != null)
        'emergency_contact_name': emergencyContactName,
      if (emergencyContactPhone != null)
        'emergency_contact_phone': emergencyContactPhone,
    });
  }
}
