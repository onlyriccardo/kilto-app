import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _tenantSlugKey = 'tenant_slug';
  static const _userTypeKey = 'user_type';
  static const _userDataKey = 'user_data';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveTenantSlug(String slug) => _storage.write(key: _tenantSlugKey, value: slug);
  Future<String?> getTenantSlug() => _storage.read(key: _tenantSlugKey);

  Future<void> saveUserType(String type) => _storage.write(key: _userTypeKey, value: type);
  Future<String?> getUserType() => _storage.read(key: _userTypeKey);

  Future<void> saveUserData(String json) => _storage.write(key: _userDataKey, value: json);
  Future<String?> getUserData() => _storage.read(key: _userDataKey);

  Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _tenantSlugKey);
    await _storage.delete(key: _userTypeKey);
    await _storage.delete(key: _userDataKey);
  }
}
