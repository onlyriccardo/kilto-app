import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../config/api_config.dart';
import '../storage/secure_storage.dart';

/// HTTP client with a path-aware two-token interceptor.
///
/// Rules:
///   * Requests to `/v2/*` are authenticated with the **Kilto root token**
///     (ability `kilto:root`). Long-lived, tenant-agnostic.
///   * Requests to `/v1/*` are authenticated with the **tenant session token**
///     (abilities `tenant:{id}`, `role:...`). Short-lived, scoped to one
///     clinic.
///   * If neither matches (e.g. health checks), no bearer is attached.
///
/// This is the only place that decides which bearer to attach, which means
/// it is the single choke point that prevents an Account token from
/// accidentally acting on tenant data and vice versa.
///
/// The legacy single-token mode (pre-Kilto-central-auth) is preserved by
/// `storage.getToken()` — when `kilto_root_token` is unset, the interceptor
/// falls back to that one, so users on the old flow don't get logged out
/// mid-upgrade.
class ApiClient {
  late final Dio dio;
  final SecureStorageService storage;

  /// Optional callback fired when a /v1/* request returns 401, so higher
  /// layers can trigger a silent `clinics/{slug}/enter` remint + retry.
  void Function()? onTenantTokenExpired;

  /// Optional callback fired when a /v2/* request returns 401 (Kilto root
  /// token is invalid/revoked). Higher layers should clear state + redirect
  /// to /login.
  void Function()? onAccountExpired;

  ApiClient({required this.storage}) {
    final baseUrl = Platform.isIOS ? ApiConfig.iosBaseUrl : ApiConfig.baseUrl;

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;

        if (path.startsWith(ApiConfig.v2Prefix)) {
          final token = await storage.getAccountToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } else if (path.startsWith(ApiConfig.v1Prefix)) {
          final tenantToken = await storage.getTenantSessionToken();
          if (tenantToken != null) {
            options.headers['Authorization'] = 'Bearer $tenantToken';
            // Keep X-Tenant-Slug as a hint for logs/middleware — the server
            // now derives the effective tenant from the token's ability.
            final slug = await storage.getCurrentTenantSlug();
            if (slug != null) options.headers['X-Tenant-Slug'] = slug;
          } else {
            // Legacy fallback: pre-Kilto-central-auth, one token + slug.
            final legacyToken = await storage.getToken();
            if (legacyToken != null) {
              options.headers['Authorization'] = 'Bearer $legacyToken';
            }
            final legacySlug = await storage.getTenantSlug();
            if (legacySlug != null) {
              options.headers['X-Tenant-Slug'] = legacySlug;
            }
          }
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final path = error.requestOptions.path;
          if (path.startsWith(ApiConfig.v2Prefix)) {
            await storage.clearAccountToken();
            onAccountExpired?.call();
          } else if (path.startsWith(ApiConfig.v1Prefix)) {
            await storage.clearTenantSession();
            onTenantTokenExpired?.call();
          }
        }
        handler.next(error);
      },
    ));

    // Verbose request/response logging. Added AFTER the auth interceptor so
    // the request-headers log already includes the Authorization bearer.
    dio.interceptors.add(LogInterceptor(
      request: false,
      requestHeader: true,
      requestBody: false,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('[dio] $obj'),
    ));
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) =>
      dio.delete<T>(path);
}
