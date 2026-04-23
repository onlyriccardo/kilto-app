/// Compile-time feature flags. Flip via `--dart-define=<NAME>=true`.
///
/// Keep these lean and stable — if a flag outlives a release, either remove it
/// or promote the behaviour to default.

/// Enables the central Kilto identity flow (POST /api/v2/auth/register,
/// /api/v2/auth/login, My Clinics, QR join, tenant-session tokens).
///
/// When false, the app falls back to the legacy per-tenant login against
/// /api/v1/auth/login with a tenant-slug field.
///
/// Build:
///   flutter run --dart-define=CENTRAL_AUTH=true
const bool kCentralAuth = bool.fromEnvironment(
  'CENTRAL_AUTH',
  defaultValue: false,
);
