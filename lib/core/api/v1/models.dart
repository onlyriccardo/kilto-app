/// Dart models mirroring /api/v1/* response shapes.
///
/// Kept intentionally flat and permissive (most fields nullable) so changes
/// on the Laravel side don't crash the app.

class Appointment {
  final int id;
  final String date;       // YYYY-MM-DD
  final String time;       // HH:mm
  final String? endTime;
  final int duration;      // minutes
  final String service;
  final String? staffName;
  final String status;     // scheduled | completed | cancelled | no_show
  final String? notes;
  final DateTime? createdAt;

  const Appointment({
    required this.id,
    required this.date,
    required this.time,
    this.endTime,
    required this.duration,
    required this.service,
    this.staffName,
    required this.status,
    this.notes,
    this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: j['id'] as int,
        date: j['date'] as String,
        time: j['time'] as String,
        endTime: j['end_time'] as String?,
        duration: (j['duration'] as num?)?.toInt() ?? 30,
        service: (j['service'] as String?) ?? 'Cita',
        staffName: j['staff_name'] as String?,
        status: (j['status'] as String?) ?? 'scheduled',
        notes: j['notes'] as String?,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
      );
}

class ServiceCatalogItem {
  final int id;
  final String name;
  final String? description;
  final num? price;

  const ServiceCatalogItem({
    required this.id,
    required this.name,
    this.description,
    this.price,
  });

  factory ServiceCatalogItem.fromJson(Map<String, dynamic> j) =>
      ServiceCatalogItem(
        id: j['id'] as int,
        name: j['name'] as String,
        description: j['description'] as String?,
        // Laravel serializes decimal columns as strings ("350.00"), not numbers.
        // Be permissive: accept both num and string.
        price: _asNum(j['price']),
      );

  static num? _asNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }
}

class StaffMember {
  final int id;
  final String name;
  final String? email;
  final String? role;
  final String? avatarUrl;

  const StaffMember({
    required this.id,
    required this.name,
    this.email,
    this.role,
    this.avatarUrl,
  });

  factory StaffMember.fromJson(Map<String, dynamic> j) => StaffMember(
        id: j['id'] as int,
        name: (j['name'] as String?) ?? 'Sin nombre',
        email: j['email'] as String?,
        role: j['role'] as String?,
        avatarUrl: j['avatar_url'] as String?,
      );
}

class DocumentItem {
  final int id;
  final String title;
  final String? type;
  final String category;
  final String? categoryIcon;
  final String date;
  final String? downloadUrl;
  final int? size;

  const DocumentItem({
    required this.id,
    required this.title,
    this.type,
    required this.category,
    this.categoryIcon,
    required this.date,
    this.downloadUrl,
    this.size,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> j) => DocumentItem(
        id: j['id'] as int,
        title: (j['title'] as String?) ?? 'Documento',
        type: j['type'] as String?,
        category: (j['category'] as String?) ?? 'General',
        categoryIcon: j['category_icon'] as String?,
        date: (j['date'] as String?) ?? '',
        downloadUrl: j['download_url'] as String?,
        size: (j['size'] as num?)?.toInt(),
      );
}

class NotificationItem {
  final int id;
  final String title;
  final String? body;
  final String? icon;
  final String? url;
  final bool read;
  final DateTime? createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    this.body,
    this.icon,
    this.url,
    required this.read,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'] as int,
        title: (j['title'] as String?) ?? '',
        body: j['body'] as String?,
        icon: j['icon'] as String?,
        url: j['url'] as String?,
        read: (j['read'] as bool?) ?? false,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
      );
}

class PersonalInfo {
  final String name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? nationalId;
  final String? address;
  final String? city;
  final String? avatarUrl;

  const PersonalInfo({
    required this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.nationalId,
    this.address,
    this.city,
    this.avatarUrl,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> j) => PersonalInfo(
        name: (j['name'] as String?) ?? '',
        firstName: j['first_name'] as String?,
        lastName: j['last_name'] as String?,
        email: j['email'] as String?,
        phone: j['phone'] as String?,
        dateOfBirth: j['date_of_birth'] as String?,
        nationalId: j['national_id'] as String?,
        address: j['address'] as String?,
        city: j['city'] as String?,
        avatarUrl: j['avatar_url'] as String?,
      );
}

class MedicalInfo {
  final String? bloodType;
  final String? allergies;
  final String? medications;
  final String? conditions;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const MedicalInfo({
    this.bloodType,
    this.allergies,
    this.medications,
    this.conditions,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  factory MedicalInfo.fromJson(Map<String, dynamic> j) => MedicalInfo(
        bloodType: j['blood_type'] as String?,
        allergies: j['allergies'] as String?,
        medications: j['medications'] as String?,
        conditions: j['conditions'] as String?,
        emergencyContactName: j['emergency_contact_name'] as String?,
        emergencyContactPhone: j['emergency_contact_phone'] as String?,
      );
}

/// Raw response from `GET /v1/modules/dental/odontogram`.
///
/// The backend ships three maps keyed by FDI tooth number (as string):
///   * `surfaceStates`     — per-tooth surface → state (e.g. `{"M": "caries"}`)
///   * `perioData`         — per-tooth periodontal measurements (free-form)
///   * `treatments`        — per-tooth list of performed treatment records
/// Plus a `teethWithIssues` count computed server-side.
///
/// The screen folds all three into a `ToothData` per FDI number for rendering.
class OdontogramRecord {
  final Map<String, Map<String, String>> surfaceStates;
  final Map<String, Map<String, dynamic>> perioData;
  final int teethWithIssues;
  final Map<String, List<DentalTreatmentRecord>> treatments;

  const OdontogramRecord({
    this.surfaceStates = const {},
    this.perioData = const {},
    this.teethWithIssues = 0,
    this.treatments = const {},
  });

  factory OdontogramRecord.fromJson(Map<String, dynamic> j) {
    final surfaceRaw = (j['surface_states'] is Map)
        ? (j['surface_states'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final surfaceStates = <String, Map<String, String>>{};
    surfaceRaw.forEach((fdi, v) {
      if (v is Map) {
        surfaceStates[fdi.toString()] =
            v.map((k, s) => MapEntry(k.toString(), s?.toString() ?? ''));
      }
    });

    final perioRaw = (j['perio_data'] is Map)
        ? (j['perio_data'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final perioData = <String, Map<String, dynamic>>{};
    perioRaw.forEach((fdi, v) {
      if (v is Map) {
        perioData[fdi.toString()] = v.cast<String, dynamic>();
      }
    });

    final txRaw = (j['treatments'] is Map)
        ? (j['treatments'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final treatments = <String, List<DentalTreatmentRecord>>{};
    txRaw.forEach((fdi, v) {
      if (v is List) {
        treatments[fdi.toString()] = v
            .whereType<Map>()
            .map((e) => DentalTreatmentRecord.fromJson(
                e.cast<String, dynamic>()))
            .toList();
      }
    });

    return OdontogramRecord(
      surfaceStates: surfaceStates,
      perioData: perioData,
      teethWithIssues: (j['teeth_with_issues'] as num?)?.toInt() ?? 0,
      treatments: treatments,
    );
  }

  bool get isEmpty =>
      surfaceStates.isEmpty && treatments.isEmpty && teethWithIssues == 0;
}

class DentalTreatmentRecord {
  final int? id;
  final String? treatmentCode;
  final List<String> surfaces;
  final String? note;
  final String? performedAt; // "d M Y"
  final String? performer;
  final bool isResolved;

  const DentalTreatmentRecord({
    this.id,
    this.treatmentCode,
    this.surfaces = const [],
    this.note,
    this.performedAt,
    this.performer,
    this.isResolved = false,
  });

  factory DentalTreatmentRecord.fromJson(Map<String, dynamic> j) {
    final surfaces = <String>[];
    final rawSurfaces = j['surfaces'];
    if (rawSurfaces is List) {
      surfaces.addAll(rawSurfaces.map((e) => e.toString()));
    } else if (rawSurfaces is String && rawSurfaces.isNotEmpty) {
      surfaces.addAll(rawSurfaces.split(','));
    }
    return DentalTreatmentRecord(
      id: (j['id'] as num?)?.toInt(),
      treatmentCode: j['treatment_code'] as String?,
      surfaces: surfaces,
      note: j['note'] as String?,
      performedAt: j['performed_at'] as String?,
      performer: j['performer'] as String?,
      isResolved: (j['is_resolved'] as bool?) ?? false,
    );
  }

  /// Pretty-print for the treatment-history list (e.g. "Empaste - 28 Mar 2026").
  String summary() {
    final code = treatmentCode ?? 'Tratamiento';
    final when = performedAt;
    final base = when == null ? code : '$code - $when';
    if (surfaces.isNotEmpty) return '$base (${surfaces.join(', ')})';
    return base;
  }
}

class Profile {
  final PersonalInfo personal;
  final MedicalInfo? medical;
  final Map<String, dynamic> notificationPreferences;

  const Profile({
    required this.personal,
    this.medical,
    this.notificationPreferences = const {},
  });

  factory Profile.fromJson(Map<String, dynamic> j) {
    // Laravel serializes an empty associative array as `[]` (not `{}`), so the
    // field can arrive as either a Map (with real keys) or a List (empty).
    final np = j['notification_preferences'];
    final prefs = np is Map
        ? np.cast<String, dynamic>()
        : const <String, dynamic>{};

    return Profile(
      personal: PersonalInfo.fromJson(
        j['personal'] as Map<String, dynamic>,
      ),
      medical: j['medical'] != null
          ? MedicalInfo.fromJson(j['medical'] as Map<String, dynamic>)
          : null,
      notificationPreferences: prefs,
    );
  }
}
