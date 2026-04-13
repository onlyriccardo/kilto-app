import 'dart:convert';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';
import 'auth_state.dart';

class AuthService {
  final ApiClient api;
  final SecureStorageService storage;

  AuthService({required this.api, required this.storage});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String tenantSlug,
  }) async {
    final response = await api.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
      'tenant_slug': tenantSlug,
    });

    final data = response.data;
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    final tenant = user['tenant'] as Map<String, dynamic>;

    await storage.saveToken(token);
    await storage.saveTenantSlug(tenant['slug']);
    await storage.saveUserType(user['type']);
    await storage.saveUserData(jsonEncode(user));

    return data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String tenantSlug,
    String? phone,
  }) async {
    // First resolve tenant ID from slug
    final response = await api.dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'tenant_slug': tenantSlug,
    });

    final data = response.data;
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    final tenant = user['tenant'] as Map<String, dynamic>;

    await storage.saveToken(token);
    await storage.saveTenantSlug(tenant['slug']);
    await storage.saveUserType(user['type']);
    await storage.saveUserData(jsonEncode(user));

    return data;
  }

  Future<void> logout() async {
    try {
      await api.post('/auth/logout');
    } catch (_) {
      // Ignore errors on logout
    }
    await storage.clearAll();
  }

  Future<Map<String, dynamic>?> tryAutoLogin() async {
    final token = await storage.getToken();
    if (token == null) return null;

    try {
      final response = await api.get('/auth/me');
      return response.data['user'] as Map<String, dynamic>?;
    } catch (_) {
      await storage.clearAll();
      return null;
    }
  }
}
