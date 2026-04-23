import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure, encrypted storage for auth-sensitive values.
///
/// After the v2 rollout the app uses a two-token model:
///   * `account_token` — authenticates the central Account (root identity).
///     Long-lived, no tenant context. Sent ONLY to /api/v2/* requests.
///   * `tenant_session_token` — minted when entering a specific clinic. Short
///     TTL (8h), carries Sanctum abilities `tenant:{id}` + `role:...`. Sent
///     ONLY to /api/v1/* requests.
///
/// Legacy keys (`auth_token`, `tenant_slug`) are kept for one release so
/// auto-login can migrate a signed-in user into the new model.
class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // --- Central Account identity ---
  static const _accountTokenKey = 'account_token';
  static const _accountDataKey = 'account_data'; // json blob

  // --- Tenant session ---
  static const _tenantSessionTokenKey = 'tenant_session_token';
  static const _tenantSessionExpiresAtKey = 'tenant_session_expires_at';
  static const _currentTenantSlugKey = 'current_tenant_slug';
  static const _currentMembershipKey = 'current_membership'; // json blob
  static const _knownTenantsCacheKey = 'known_tenants_cache'; // json array

  // --- Legacy (pre-v2) ---
  static const _tokenKey = 'auth_token';
  static const _tenantSlugKey = 'tenant_slug';
  static const _userTypeKey = 'user_type';
  static const _userDataKey = 'user_data';

  // =======================================================================
  // Account (root)
  // =======================================================================

  Future<void> saveAccountToken(String token) =>
      _storage.write(key: _accountTokenKey, value: token);
  Future<String?> getAccountToken() => _storage.read(key: _accountTokenKey);
  Future<void> clearAccountToken() => _storage.delete(key: _accountTokenKey);

  Future<void> saveAccount(String json) =>
      _storage.write(key: _accountDataKey, value: json);
  Future<String?> getAccount() => _storage.read(key: _accountDataKey);
  Future<void> clearAccount() => _storage.delete(key: _accountDataKey);

  // =======================================================================
  // Tenant session
  // =======================================================================

  Future<void> saveTenantSession({
    required String token,
    required String expiresAtIso,
    required String tenantSlug,
    required String membershipJson,
  }) async {
    await _storage.write(key: _tenantSessionTokenKey, value: token);
    await _storage.write(key: _tenantSessionExpiresAtKey, value: expiresAtIso);
    await _storage.write(key: _currentTenantSlugKey, value: tenantSlug);
    await _storage.write(key: _currentMembershipKey, value: membershipJson);
  }

  Future<String?> getTenantSessionToken() =>
      _storage.read(key: _tenantSessionTokenKey);
  Future<String?> getTenantSessionExpiresAt() =>
      _storage.read(key: _tenantSessionExpiresAtKey);
  Future<String?> getCurrentTenantSlug() =>
      _storage.read(key: _currentTenantSlugKey);
  Future<String?> getCurrentMembership() =>
      _storage.read(key: _currentMembershipKey);

  Future<void> clearTenantSession() async {
    await _storage.delete(key: _tenantSessionTokenKey);
    await _storage.delete(key: _tenantSessionExpiresAtKey);
    await _storage.delete(key: _currentTenantSlugKey);
    await _storage.delete(key: _currentMembershipKey);
  }

  // =======================================================================
  // Clinic list cache (for offline MyClinics)
  // =======================================================================

  Future<void> saveKnownTenantsCache(String json) =>
      _storage.write(key: _knownTenantsCacheKey, value: json);
  Future<String?> getKnownTenantsCache() =>
      _storage.read(key: _knownTenantsCacheKey);

  // =======================================================================
  // Legacy (pre-v2) — kept for migration path
  // =======================================================================

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveTenantSlug(String slug) =>
      _storage.write(key: _tenantSlugKey, value: slug);
  Future<String?> getTenantSlug() => _storage.read(key: _tenantSlugKey);

  Future<void> saveUserType(String type) =>
      _storage.write(key: _userTypeKey, value: type);
  Future<String?> getUserType() => _storage.read(key: _userTypeKey);

  Future<void> saveUserData(String json) =>
      _storage.write(key: _userDataKey, value: json);
  Future<String?> getUserData() => _storage.read(key: _userDataKey);

  // =======================================================================
  // Global clear (logout)
  // =======================================================================

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
