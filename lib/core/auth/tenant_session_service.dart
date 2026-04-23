import 'dart:convert';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';
import 'account.dart';

/// Mints and refreshes tenant-session tokens via /api/v2/clinics/{slug}/enter.
///
/// The app calls `enter()` when the user taps a clinic in MyClinics. The
/// returned token is short-lived (8h) and scoped to one tenant via Sanctum
/// abilities, so it can ONLY read/write that clinic's data.
class TenantSessionService {
  final ApiClient api;
  final SecureStorageService storage;

  TenantSessionService({required this.api, required this.storage});

  /// Mint a tenant-session token for this clinic. Persists the token + slug +
  /// membership so subsequent /v1/* requests are authenticated automatically
  /// by `ApiClient`'s interceptor.
  Future<ClinicMembership> enter(String slug) async {
    final response = await api.post('/v2/clinics/$slug/enter');
    final data = response.data as Map<String, dynamic>;

    final token = data['token'] as String;
    final expiresAt = data['expires_at'] as String;
    final membership = ClinicMembership.fromJson(
      data['membership'] as Map<String, dynamic>,
    );

    await storage.saveTenantSession(
      token: token,
      expiresAtIso: expiresAt,
      tenantSlug: membership.tenantSlug,
      membershipJson: jsonEncode(membership.toJson()),
    );

    return membership;
  }

  /// Drop the tenant-session token. Leaves the Account logged in.
  Future<void> leave() async {
    await storage.clearTenantSession();
  }

  Future<ClinicMembership?> loadCurrentMembership() async {
    final raw = await storage.getCurrentMembership();
    if (raw == null) return null;

    return ClinicMembership.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  /// True iff we still have a non-expired tenant-session token.
  Future<bool> hasActiveSession() async {
    final token = await storage.getTenantSessionToken();
    final expiresAt = await storage.getTenantSessionExpiresAt();
    if (token == null || expiresAt == null) return false;

    final parsed = DateTime.tryParse(expiresAt);
    if (parsed == null) return false;
    return parsed.isAfter(DateTime.now());
  }
}
