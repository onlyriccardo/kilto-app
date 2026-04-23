import 'package:flutter/material.dart' show Color;

/// Serializable view of a Account returned by /api/v2/auth/*.
class Account {
  final int id;
  final String email;
  final String? name;
  final String? phone;
  final DateTime? emailVerifiedAt;

  const Account({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.emailVerifiedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        emailVerifiedAt: json['email_verified_at'] != null
            ? DateTime.tryParse(json['email_verified_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phone': phone,
        'email_verified_at': emailVerifiedAt?.toIso8601String(),
      };
}

/// One clinic membership returned by /api/v2/clinics.
class ClinicMembership {
  final int tenantId;
  final String tenantName;
  final String tenantSlug;
  final String? logoUrl;
  final Map<String, dynamic>? branding;
  final List<String> activeModules;
  final String role; // 'client' or 'staff'
  final String status;
  final String displayName;

  const ClinicMembership({
    required this.tenantId,
    required this.tenantName,
    required this.tenantSlug,
    this.logoUrl,
    this.branding,
    this.activeModules = const [],
    required this.role,
    required this.status,
    required this.displayName,
  });

  factory ClinicMembership.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>;
    final modules = (tenant['active_modules'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    return ClinicMembership(
      tenantId: tenant['id'] as int,
      tenantName: tenant['name'] as String,
      tenantSlug: tenant['slug'] as String,
      logoUrl: tenant['logo_url'] as String?,
      branding: (tenant['branding'] as Map?)?.cast<String, dynamic>(),
      activeModules: modules,
      role: json['role'] as String? ?? 'client',
      status: json['status'] as String? ?? 'active',
      displayName: json['display_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'tenant': {
          'id': tenantId,
          'name': tenantName,
          'slug': tenantSlug,
          'logo_url': logoUrl,
          'branding': branding,
          'active_modules': activeModules,
        },
        'role': role,
        'status': status,
        'display_name': displayName,
      };

  bool get isStaff => role == 'staff';

  /// Parsed accent color from `branding.primary_color`. Returns null if the
  /// clinic hasn't customized its brand, in which case the caller should fall
  /// back to the default Kilto brand.
  Color? get brandColor {
    final raw = branding?['primary_color'];
    if (raw is! String) return null;
    return _hexToColor(raw);
  }

  static Color? _hexToColor(String hex) {
    var s = hex.trim().replaceFirst('#', '');
    if (s.length == 3) {
      // #RGB -> #RRGGBB
      s = s.split('').map((c) => '$c$c').join();
    }
    if (s.length == 6) s = 'FF$s';
    if (s.length != 8) return null;
    final v = int.tryParse(s, radix: 16);
    return v == null ? null : Color(v);
  }
}
