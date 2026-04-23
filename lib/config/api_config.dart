class ApiConfig {
  /// Base URL ending at `/api` (no version segment). Path prefixes are added
  /// per endpoint family: `/v1/...` for legacy tenant-scoped, `/v2/...`
  /// for the central Kilto identity API.
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  static const String iosBaseUrl = 'http://localhost:8000/api';

  /// Path prefix constants used by services and the Dio interceptor
  /// (so the two-token router can pick the right bearer per request).
  ///
  /// `v1` = legacy per-tenant API. `v2` = central Kilto identity.
  static const String v2Prefix = '/v2';
  static const String v1Prefix = '/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
