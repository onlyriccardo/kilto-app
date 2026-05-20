class ApiConfig {
  /// Base URL ending at `/api` (no version segment). Path prefixes are added
  /// per endpoint family: `/v1/...` for legacy tenant-scoped, `/v2/...`
  /// for the central Kilto identity API.
  ///
  /// Override at build time for prod / staging:
  ///   --dart-define=API_BASE_URL=https://kilto.app/api
  ///
  /// The defaults below assume a local rapydscale-platform on the host machine
  /// (Android emulator: 10.0.2.2; iOS sim: localhost).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8002/api',
  );
  static const String iosBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8002/api',
  );

  /// Path prefix constants used by services and the Dio interceptor
  /// (so the two-token router can pick the right bearer per request).
  ///
  /// `v1` = legacy per-tenant API. `v2` = central Kilto identity.
  static const String v2Prefix = '/v2';
  static const String v1Prefix = '/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
