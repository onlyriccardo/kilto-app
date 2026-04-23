import 'dart:convert';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';
import 'account.dart';

/// Wraps /api/v2/auth/* and /api/v2/clinics/*.
///
/// Never persists a tenant-session token — that's the `TenantSessionService`'s
/// job. Keeps the root and tenant flows clearly separated so neither leaks
/// into the other.
class AccountAuthService {
  final ApiClient api;
  final SecureStorageService storage;

  AccountAuthService({required this.api, required this.storage});

  Future<Account> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    final response = await api.post('/v2/auth/register', data: {
      'email': email,
      'password': password,
      if (name != null && name.isNotEmpty) 'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return _persistAndReturn(response.data as Map<String, dynamic>);
  }

  Future<Account> login({
    required String email,
    required String password,
  }) async {
    final response = await api.post('/v2/auth/login', data: {
      'email': email,
      'password': password,
    });
    return _persistAndReturn(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await api.post('/v2/auth/logout');
    } catch (_) {
      // ignored — user is logging out anyway
    }
    await storage.clearAll();
  }

  Future<Account?> me() async {
    final token = await storage.getAccountToken();
    if (token == null) return null;

    try {
      final response = await api.get('/v2/auth/me');
      final data = response.data as Map<String, dynamic>;
      final account = Account.fromJson(data['account'] as Map<String, dynamic>);
      await storage.saveAccount(jsonEncode(account.toJson()));
      return account;
    } catch (_) {
      await storage.clearAccountToken();
      await storage.clearAccount();
      return null;
    }
  }

  Future<List<ClinicMembership>> listClinics() async {
    final response = await api.get('/v2/clinics');
    final data = response.data as Map<String, dynamic>;
    final items = (data['clinics'] as List).cast<Map<String, dynamic>>();
    final list = items.map(ClinicMembership.fromJson).toList();
    await storage.saveKnownTenantsCache(
      jsonEncode(list.map((m) => m.toJson()).toList()),
    );
    return list;
  }

  Future<List<ClinicMembership>> loadCachedClinics() async {
    final raw = await storage.getKnownTenantsCache();
    if (raw == null) return const [];
    final items = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return items.map(ClinicMembership.fromJson).toList();
  }

  Future<ClinicMembership> joinClinic(String code) async {
    final response = await api.post('/v2/clinics/join', data: {
      'code': code,
    });
    final data = response.data as Map<String, dynamic>;
    return ClinicMembership.fromJson(data['membership'] as Map<String, dynamic>);
  }

  // -----------------------------------------------------------------------

  Future<Account> _persistAndReturn(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final account = Account.fromJson(data['account'] as Map<String, dynamic>);

    await storage.saveAccountToken(token);
    await storage.saveAccount(jsonEncode(account.toJson()));

    return account;
  }
}
