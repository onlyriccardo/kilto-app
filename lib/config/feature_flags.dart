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
///   flutter run --dart-define=CENTRAL_AUTH=false   // opt out
const bool kCentralAuth = bool.fromEnvironment(
  'CENTRAL_AUTH',
  defaultValue: true,
);

/// Gates the client-side chat surface (the "Contactar" tile on the home
/// screen and the /client/chat route). Off by default until the backend
/// exposes /v1/conversations(/:id)(/messages) for the patient role.
const bool kClientChatEnabled = bool.fromEnvironment(
  'CLIENT_CHAT',
  defaultValue: false,
);
