import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_state.dart';
import 'demo_mode.dart';
import 'theme.dart';
import '../features/auth/screens/login_screen.dart';
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

// ── Demo mode switcher state ──
final demoRoleProvider = StateProvider<String>((ref) => 'client');

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

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
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

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
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
    );
  }
}

// ── Router ──
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: kDemoMode ? '/client/home' : '/login',
    redirect: (context, state) {
      if (kDemoMode) return null;

      final isLoggedIn = authState.isLoggedIn;
      final isLoginRoute = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) {
        return authState.userType == 'staff' ? '/clinic/dashboard' : '/client/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      // Client routes
      ShellRoute(
        builder: (_, __, child) => ClientShell(child: child),
        routes: [
          GoRoute(path: '/client/home', builder: (_, __) => const ClientHomeScreen()),
          GoRoute(path: '/client/appointments', builder: (_, __) => const AppointmentsScreen()),
          GoRoute(path: '/client/documents', builder: (_, __) => const DocumentsScreen()),
          GoRoute(path: '/client/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/client/book-appointment', builder: (_, __) => const BookAppointmentScreen()),
      GoRoute(path: '/client/chat', builder: (_, __) => const ChatScreen()),
      GoRoute(path: '/client/notifications', builder: (_, __) => const NotificationsScreen()),

      // Clinic routes
      ShellRoute(
        builder: (_, __, child) => ClinicShell(child: child),
        routes: [
          GoRoute(path: '/clinic/dashboard', builder: (_, __) => const ClinicDashboardScreen()),
          GoRoute(path: '/clinic/agenda', builder: (_, __) => const ClinicAgendaScreen()),
          GoRoute(path: '/clinic/patients', builder: (_, __) => const ClinicPatientsScreen()),
          GoRoute(path: '/clinic/messages', builder: (_, __) => const ClinicMessagesScreen()),
          GoRoute(path: '/clinic/more', builder: (_, __) => const ClinicMoreScreen()),
        ],
      ),
    ],
  );
});
