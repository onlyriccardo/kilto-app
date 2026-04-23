import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_state.dart';
import '../core/auth/auth_providers.dart';
import 'clinic_theme.dart';
import 'demo_mode.dart';
import 'feature_flags.dart';
import '../features/account/screens/account_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/client/home/screens/client_home_screen.dart';
import '../features/client/appointments/screens/appointments_screen.dart';
import '../features/client/appointments/screens/book_appointment_screen.dart';
import '../features/client/documents/screens/documents_screen.dart';
import '../features/client/chat/screens/chat_screen.dart';
import '../features/client/profile/screens/profile_screen.dart';
import '../features/client/notifications/screens/notifications_screen.dart';
import '../features/clinic/dashboard/screens/clinic_dashboard_screen.dart';
import '../features/clinic/agenda/screens/clinic_agenda_screen.dart';
import '../features/clinic/patients/screens/clinic_patients_screen.dart';
import '../features/clinic/messages/screens/clinic_messages_screen.dart';
import '../features/clinic/more/screens/clinic_more_screen.dart';
import '../features/clinics/screens/enter_code_screen.dart';
import '../features/clinics/screens/my_clinics_screen.dart';
import '../features/clinics/screens/scan_clinic_qr_screen.dart';

// ── Demo mode switcher state ──
final demoRoleProvider = StateProvider<String>((ref) => 'client');

// Navigator keys for each shell's inner Navigator. When the user taps a
// bottom-nav tab, we use these to pop any pushed routes (patient detail,
// chat, etc.) that are sitting on top of the shell's stack, otherwise
// the tab tap wouldn't be visible to the user.
final _clientShellNavKey = GlobalKey<NavigatorState>();
final _clinicShellNavKey = GlobalKey<NavigatorState>();

// ── Shell for client bottom nav ──
class ClientShell extends ConsumerWidget {
  final Widget child;
  const ClientShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (location.startsWith('/client/appointments')) index = 1;
    if (location.startsWith('/client/documents')) index = 2;
    if (location.startsWith('/client/profile')) index = 3;

    final accent = ref.watch(clinicAccentProvider);

    return ClinicAccentTheme(
      child: Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          selectedItemColor: accent,
          onTap: (i) {
            // Drop any routes pushed on top of the shell (chat, notifications,
            // book-appointment) so the tab switch is actually visible.
            final nav = _clientShellNavKey.currentState;
            if (nav != null) {
              while (nav.canPop()) {
                nav.pop();
              }
            }
            switch (i) {
              case 0: context.go('/client/home');
              case 1: context.go('/client/appointments');
              case 2: context.go('/client/documents');
              case 3: context.go('/client/profile');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Citas'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_rounded), label: 'Documentos'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

// ── Shell for clinic bottom nav ──
class ClinicShell extends ConsumerWidget {
  final Widget child;
  const ClinicShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (location.startsWith('/clinic/agenda')) index = 1;
    if (location.startsWith('/clinic/patients')) index = 2;
    if (location.startsWith('/clinic/messages')) index = 3;
    if (location.startsWith('/clinic/more')) index = 4;

    final accent = ref.watch(clinicAccentProvider);

    return ClinicAccentTheme(
      child: Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          selectedItemColor: accent,
          onTap: (i) {
            // Patient detail / chat detail / etc. are pushed onto the shell's
            // inner Navigator (not the root), so context.go() changes the
            // GoRouter location but leaves those pages still sitting on top
            // — the tab tap appears to do nothing. Pop them first.
            final nav = _clinicShellNavKey.currentState;
            if (nav != null) {
              while (nav.canPop()) {
                nav.pop();
              }
            }
            switch (i) {
              case 0: context.go('/clinic/dashboard');
              case 1: context.go('/clinic/agenda');
              case 2: context.go('/clinic/patients');
              case 3: context.go('/clinic/messages');
              case 4: context.go('/clinic/more');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Agenda'),
            BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Pacientes'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: 'Mensajes'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'Más'),
          ],
        ),
      ),
    );
  }
}

// ── Router ──
//
// IMPORTANT: do NOT `ref.watch` auth state at the top of this provider.
// Doing so causes the provider to rebuild on every state change, which mints
// a brand-new GoRouter and blows away navigation history (MaterialApp.router
// re-mounts and falls back to `initialLocation`). Instead we use a stable
// refreshListenable plus `ref.read` inside the redirect callback so the
// router instance is constructed once per app lifetime but redirects still
// see fresh state.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: _initialLocation(),
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      if (kDemoMode) return null;

      final path = state.uri.toString();

      if (kCentralAuth) {
        final account = ref.read(accountProvider);
        final tenantSession = ref.read(tenantSessionProvider);
        final loggedIn = account.isLoggedIn;
        final inClinic = tenantSession.isInside;

        final isAuthRoute = path == '/login' || path == '/register';
        final isTenantRoute =
            path.startsWith('/client/') || path.startsWith('/clinic/');

        if (!loggedIn && !isAuthRoute) return '/login';
        if (loggedIn && isAuthRoute) return '/clinics';

        // Tenant shells require an active tenant session.
        if (loggedIn && isTenantRoute && !inClinic) return '/clinics';

        // If we're on /clinics but we're already inside a clinic AND landed
        // here from a deep-link etc., don't redirect — user may be switching.
        return null;
      }

      // Legacy pre-Kilto-central-auth flow
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.isLoggedIn;
      final isLoginRoute = path == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) {
        return authState.userType == 'staff'
            ? '/clinic/dashboard'
            : '/client/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Kilto root-level routes (only meaningful when kCentralAuth is on)
      GoRoute(path: '/clinics', builder: (_, __) => const MyClinicsScreen()),
      GoRoute(
        path: '/clinics/scan',
        builder: (_, __) => const ScanClinicQrScreen(),
      ),
      GoRoute(
        path: '/clinics/enter-code',
        builder: (_, __) => const EnterCodeScreen(),
      ),
      GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),

      // Client routes — bottom-nav shell uses NoTransitionPage so tab switches
      // don't animate (you see no slide/fade between Inicio/Citas/etc.).
      ShellRoute(
        navigatorKey: _clientShellNavKey,
        builder: (_, __, child) => ClientShell(child: child),
        routes: [
          GoRoute(path: '/client/home', pageBuilder: (_, __) => const NoTransitionPage(child: ClientHomeScreen())),
          GoRoute(path: '/client/appointments', pageBuilder: (_, __) => const NoTransitionPage(child: AppointmentsScreen())),
          GoRoute(path: '/client/documents', pageBuilder: (_, __) => const NoTransitionPage(child: DocumentsScreen())),
          GoRoute(path: '/client/profile', pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen())),
        ],
      ),
      // These are pushed on the root Navigator (outside the ShellRoute), so
      // they lose the ClinicAccentTheme that wraps the shell. Re-wrap each
      // one so the clinic accent still applies while inside a clinic.
      GoRoute(path: '/client/book-appointment', builder: (_, __) => const ClinicAccentTheme(child: BookAppointmentScreen())),
      GoRoute(path: '/client/chat', builder: (_, __) => const ClinicAccentTheme(child: ChatScreen())),
      GoRoute(path: '/client/notifications', builder: (_, __) => const ClinicAccentTheme(child: NotificationsScreen())),

      // Clinic routes — same: no transition between tabs in the clinic shell.
      ShellRoute(
        navigatorKey: _clinicShellNavKey,
        builder: (_, __, child) => ClinicShell(child: child),
        routes: [
          GoRoute(path: '/clinic/dashboard', pageBuilder: (_, __) => const NoTransitionPage(child: ClinicDashboardScreen())),
          GoRoute(path: '/clinic/agenda', pageBuilder: (_, __) => const NoTransitionPage(child: ClinicAgendaScreen())),
          GoRoute(path: '/clinic/patients', pageBuilder: (_, __) => const NoTransitionPage(child: ClinicPatientsScreen())),
          GoRoute(path: '/clinic/messages', pageBuilder: (_, __) => const NoTransitionPage(child: ClinicMessagesScreen())),
          GoRoute(path: '/clinic/more', pageBuilder: (_, __) => const NoTransitionPage(child: ClinicMoreScreen())),
        ],
      ),
    ],
  );
});

String _initialLocation() {
  if (kDemoMode) return '/client/home';
  if (kCentralAuth) return '/clinics';
  return '/login';
}

/// Bridges Riverpod state changes into GoRouter's `refreshListenable` so the
/// redirect logic re-runs whenever Kilto root or tenant session state changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(accountProvider, (_, __) => notifyListeners());
    ref.listen(tenantSessionProvider, (_, __) => notifyListeners());
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
