import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoggedIn;
  final String? token;
  final String? userType; // 'client' or 'staff'
  final String? userName;
  final String? userEmail;
  final String? tenantName;
  final String? tenantSlug;
  final List<String> activeModules;

  const AuthState({
    this.isLoggedIn = false,
    this.token,
    this.userType,
    this.userName,
    this.userEmail,
    this.tenantName,
    this.tenantSlug,
    this.activeModules = const [],
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? token,
    String? userType,
    String? userName,
    String? userEmail,
    String? tenantName,
    String? tenantSlug,
    List<String>? activeModules,
  }) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        token: token ?? this.token,
        userType: userType ?? this.userType,
        userName: userName ?? this.userName,
        userEmail: userEmail ?? this.userEmail,
        tenantName: tenantName ?? this.tenantName,
        tenantSlug: tenantSlug ?? this.tenantSlug,
        activeModules: activeModules ?? this.activeModules,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void login({
    required String token,
    required String userType,
    required String userName,
    required String userEmail,
    required String tenantName,
    required String tenantSlug,
    required List<String> activeModules,
  }) {
    state = AuthState(
      isLoggedIn: true,
      token: token,
      userType: userType,
      userName: userName,
      userEmail: userEmail,
      tenantName: tenantName,
      tenantSlug: tenantSlug,
      activeModules: activeModules,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
