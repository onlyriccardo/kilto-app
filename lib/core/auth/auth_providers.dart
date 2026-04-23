import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';
import 'account.dart';
import 'account_auth_service.dart';
import 'auth_state.dart';
import 'tenant_session_service.dart';

// =======================================================================
// Singletons
// =======================================================================

final secureStorageProvider = Provider<SecureStorageService>(
  (_) => SecureStorageService(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(storage: ref.read(secureStorageProvider));
});

final accountAuthServiceProvider = Provider<AccountAuthService>((ref) {
  return AccountAuthService(
    api: ref.read(apiClientProvider),
    storage: ref.read(secureStorageProvider),
  );
});

final tenantSessionServiceProvider = Provider<TenantSessionService>((ref) {
  return TenantSessionService(
    api: ref.read(apiClientProvider),
    storage: ref.read(secureStorageProvider),
  );
});

// =======================================================================
// Account (root identity) state
// =======================================================================

class AccountState {
  final Account? account;
  final bool bootstrapped;

  const AccountState({this.account, this.bootstrapped = false});

  bool get isLoggedIn => account != null;

  AccountState copyWith({Account? account, bool? bootstrapped, bool clear = false}) =>
      AccountState(
        account: clear ? null : (account ?? this.account),
        bootstrapped: bootstrapped ?? this.bootstrapped,
      );
}

class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier(this._ref) : super(const AccountState());

  final Ref _ref;

  /// Called at app boot — hydrates account from secure storage if a token is
  /// present and still valid on the server.
  Future<void> bootstrap() async {
    if (state.bootstrapped) return;

    final account = await _ref.read(accountAuthServiceProvider).me();
    state = AccountState(account: account, bootstrapped: true);
  }

  Future<void> login({required String email, required String password}) async {
    final account = await _ref
        .read(accountAuthServiceProvider)
        .login(email: email, password: password);
    state = state.copyWith(account: account, bootstrapped: true);
  }

  Future<void> register({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    final account = await _ref.read(accountAuthServiceProvider).register(
          email: email,
          password: password,
          name: name,
          phone: phone,
        );
    state = state.copyWith(account: account, bootstrapped: true);
  }

  Future<void> logout() async {
    await _ref.read(accountAuthServiceProvider).logout();
    // Also drop any tenant session; the dependent notifier listens for this.
    await _ref.read(tenantSessionServiceProvider).leave();
    _ref.read(tenantSessionProvider.notifier).clear();
    _ref.read(authStateProvider.notifier).logout();
    state = const AccountState(bootstrapped: true);
  }
}

final accountProvider =
    StateNotifierProvider<AccountNotifier, AccountState>(
  (ref) => AccountNotifier(ref),
);

// =======================================================================
// Tenant session state (mirror of what we're "inside")
// =======================================================================

class TenantSessionState {
  final ClinicMembership? membership;
  final bool bootstrapped;

  const TenantSessionState({this.membership, this.bootstrapped = false});

  bool get isInside => membership != null;

  TenantSessionState copyWith({ClinicMembership? membership, bool? bootstrapped, bool clear = false}) =>
      TenantSessionState(
        membership: clear ? null : (membership ?? this.membership),
        bootstrapped: bootstrapped ?? this.bootstrapped,
      );
}

class TenantSessionNotifier extends StateNotifier<TenantSessionState> {
  TenantSessionNotifier(this._ref) : super(const TenantSessionState());

  final Ref _ref;

  Future<void> bootstrap() async {
    if (state.bootstrapped) return;

    final svc = _ref.read(tenantSessionServiceProvider);
    if (await svc.hasActiveSession()) {
      final m = await svc.loadCurrentMembership();
      state = TenantSessionState(membership: m, bootstrapped: true);
    } else {
      state = const TenantSessionState(bootstrapped: true);
    }
  }

  Future<void> enter(String slug) async {
    final m = await _ref.read(tenantSessionServiceProvider).enter(slug);
    state = state.copyWith(membership: m, bootstrapped: true);
    // Mirror into legacy AuthState so existing shells (which read
    // authStateProvider) keep functioning without a migration.
    _ref.read(authStateProvider.notifier).login(
          token: 'tenant-session',
          userType: m.role,
          userName: m.displayName,
          userEmail: _ref.read(accountProvider).account?.email ?? '',
          tenantName: m.tenantName,
          tenantSlug: m.tenantSlug,
          activeModules: m.activeModules,
        );
  }

  Future<void> leave() async {
    await _ref.read(tenantSessionServiceProvider).leave();
    clear();
    _ref.read(authStateProvider.notifier).logout();
  }

  void clear() {
    state = const TenantSessionState(bootstrapped: true);
  }
}

final tenantSessionProvider =
    StateNotifierProvider<TenantSessionNotifier, TenantSessionState>(
  (ref) => TenantSessionNotifier(ref),
);
